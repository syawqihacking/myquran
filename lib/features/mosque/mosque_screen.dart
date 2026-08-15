import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import 'mosque_models.dart';
import 'mosque_providers.dart';

/// Filter chips in the Stitch design's order (null = Semua).
const List<(MosqueAmenity?, String)> _masjidFilters = [
  (null, S.masjidCatSemua),
  (MosqueAmenity.parking, S.masjidCatParkirLuas),
  (MosqueAmenity.toilets, S.masjidCatToilet),
  (MosqueAmenity.ac, S.masjidCatAc),
  (MosqueAmenity.wheelchair, S.masjidCatDisabilitas),
];

/// "500m" below 1 km, "2.1km" above.
String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()}m';
  return '${(meters / 1000).toStringAsFixed(1)}km';
}

/// Masjid Terdekat (Stitch "Nearby Mosque"): real geolocation + live
/// OpenStreetMap data via the Overpass API, shown on a flutter_map with a list
/// of mosque cards. OSM has no rating data — the design's rating row is omitted
/// entirely (no fabricated data). "Buka" status is only shown when an
/// `opening_hours` tag exists; amenity chips only for tags actually present.
class MosqueScreen extends ConsumerStatefulWidget {
  const MosqueScreen({super.key});

  @override
  ConsumerState<MosqueScreen> createState() => _MosqueScreenState();
}

class _MosqueScreenState extends ConsumerState<MosqueScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final MapController _mapController = MapController();
  String _query = '';
  MosqueAmenity? _filter; // null = Semua
  bool _showChips = true;
  String? _selectedId;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<Mosque> _filtered(List<Mosque> all) {
    final q = _query.trim().toLowerCase();
    return [
      for (final m in all)
        if ((_filter == null || m.amenities.contains(_filter!)) &&
            (q.isEmpty ||
                m.name.toLowerCase().contains(q) ||
                m.address.toLowerCase().contains(q)))
          m,
    ];
  }

  void _selectMosque(Mosque m) {
    setState(() => _selectedId = m.id);
    _mapController.move(LatLng(m.lat, m.lon), 15.0);
  }

  Future<void> _openRoute(Mosque m) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${m.lat},${m.lon}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('launchUrl returned false');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(S.masjidRouteError),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _showDetail(Mosque m) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _MosqueDetailSheet(
        mosque: m,
        onRoute: () {
          Navigator.of(context).pop();
          _openRoute(m);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mosquesAsync = ref.watch(mosqueListProvider);
    final location = ref.watch(mosqueLocationProvider).value;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _MasjidAppBar(onBack: () => Navigator.of(context).maybePop()),
            _buildSearch(theme, scheme),
            if (_showChips) _buildChips(theme, scheme),
            Expanded(
              child: mosquesAsync.when(
                loading: () => const _LoadingState(),
                error: (e, _) => _ErrorState(
                  isLocationError: e is MosqueLocationException,
                  errorDetail: e is MosqueFetchException ? e.message : null,
                  onRetry: () {
                    ref.invalidate(mosqueLocationProvider);
                    ref.invalidate(mosqueListProvider);
                  },
                ),
                data: (result) {
                  final mosques = result.mosques;
                  final filtered = _filtered(mosques);
                  final filteredIds = filtered.map((m) => m.id).toSet();
                  return Column(
                    children: [
                      if (result.fromCache) const _CachedNote(),
                      if (location != null) ...[
                        _MapSection(
                          mapController: _mapController,
                          mosques: mosques,
                          filteredIds: filteredIds,
                          userLocation: location,
                          selectedId: _selectedId,
                          onSelect: _selectMosque,
                          onDeselect: () =>
                              setState(() => _selectedId = null),
                          onRecenter: () => _mapController.move(location, 14.0),
                        ),
                        const SizedBox(height: AppLayout.sp4),
                      ],
                      Expanded(
                        child: filtered.isEmpty
                            ? const _EmptyState()
                            : _MosqueList(
                                mosques: filtered,
                                selectedId: _selectedId,
                                onSelect: _selectMosque,
                                onRoute: _openRoute,
                                onDetail: _showDetail,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.sp6,
        AppLayout.sp4,
        AppLayout.sp6,
        AppLayout.sp3,
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: AppLayout.durBase,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                boxShadow: _searchFocus.hasFocus
                    ? [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.15),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: S.masjidSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  prefixIconColor: scheme.outline,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                            _searchFocus.requestFocus();
                          },
                          tooltip: S.cancel,
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: scheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppLayout.sp3,
                    horizontal: AppLayout.sp4,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppLayout.sp3),
          // Tune (filter) button — toggles the chips row.
          Tooltip(
            message: S.masjidFilterHint,
            child: Material(
              color: scheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => setState(() => _showChips = !_showChips),
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sp4),
      child: ScrollConfiguration(
        behavior: _ChipScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp6),
          child: Row(
            children: [
              for (var i = 0; i < _masjidFilters.length; i++) ...[
                if (i > 0) const SizedBox(width: AppLayout.sp3),
                _MasjidFilterChip(
                  label: _masjidFilters[i].$2,
                  selected: _filter == _masjidFilters[i].$1,
                  onTap: () =>
                      setState(() => _filter = _masjidFilters[i].$1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar (same pattern as other feature screens): back + centered title.
// ---------------------------------------------------------------------------

class _MasjidAppBar extends StatelessWidget {
  const _MasjidAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: AppLayout.sp10,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: S.back,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              S.masjidTerdekatTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                height: 28 / 20,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 48), // balances the back button
        ],
      ),
    );
  }
}

/// Hides the horizontal scrollbar but keeps mouse-drag scrolling.
class _ChipScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class _MasjidFilterChip extends StatefulWidget {
  const _MasjidFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_MasjidFilterChip> createState() => _MasjidFilterChipState();
}

class _MasjidFilterChipState extends State<_MasjidFilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = widget.selected;
    final bg = selected
        ? scheme.primaryContainer
        : (_hovered ? scheme.surfaceContainer : scheme.surfaceContainerLow);
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp4,
            vertical: AppLayout.sp2,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            border: Border.all(
              color: selected ? Colors.transparent : scheme.outlineVariant,
            ),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map section: OSM tiles, mosque pins, pulsing location pin, recenter FAB.
// ---------------------------------------------------------------------------

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.mapController,
    required this.mosques,
    required this.filteredIds,
    required this.userLocation,
    required this.selectedId,
    required this.onSelect,
    required this.onDeselect,
    required this.onRecenter,
  });

  final MapController mapController;
  final List<Mosque> mosques;
  final Set<String> filteredIds;
  final LatLng userLocation;
  final String? selectedId;
  final ValueChanged<Mosque> onSelect;
  final VoidCallback onDeselect;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wide =
        MediaQuery.sizeOf(context).width >= AppConstants.mobileBreakpoint;
    final height = wide ? 384.0 : 256.0; // h-96 wide / h-64 mobile

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: userLocation,
                  initialZoom: 14.0,
                  minZoom: 3,
                  maxZoom: 19,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onTap: (_, __) => onDeselect(),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'myquran',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userLocation,
                        width: 24,
                        height: 24,
                        child: const _PulsingLocationPin(),
                      ),
                      for (final m in mosques)
                        Marker(
                          point: LatLng(m.lat, m.lon),
                          width: 140,
                          height: 64,
                          alignment: Alignment.bottomCenter,
                          child: _MosquePin(
                            mosque: m,
                            selected: m.id == selectedId,
                            dimmed: !filteredIds.contains(m.id),
                            onTap: () => onSelect(m),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // Recenter FAB.
              Positioned(
                right: AppLayout.sp4,
                bottom: AppLayout.sp4,
                child: Material(
                  color: scheme.surface,
                  elevation: 2,
                  shadowColor: scheme.primary.withValues(alpha: 0.2),
                  shape: const CircleBorder(),
                  child: Tooltip(
                    message: S.masjidRecenter,
                    child: InkWell(
                      onTap: onRecenter,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.my_location_rounded,
                          size: 24,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mosque pin: a primary circle + mosque icon, with a name label above when
/// selected. Non-matching pins are dimmed while a search/filter is active.
class _MosquePin extends StatelessWidget {
  const _MosquePin({
    required this.mosque,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final Mosque mosque;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = selected ? 36.0 : 28.0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: dimmed ? 0.35 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp2,
                  vertical: 4,
                ),
                constraints: const BoxConstraints(maxWidth: 130),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(AppLayout.radiusSm),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  mosque.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
              ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.mosque_rounded,
                size: selected ? 20 : 16,
                color: scheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Current-location pin: a pulsing secondary circle with a primary dot.
class _PulsingLocationPin extends StatefulWidget {
  const _PulsingLocationPin();

  @override
  State<_PulsingLocationPin> createState() => _PulsingLocationPinState();
}

class _PulsingLocationPinState extends State<_PulsingLocationPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.secondaryContainer.withValues(
              alpha: 0.4 + 0.6 * (1 - t),
            ),
            border: Border.all(color: scheme.surface, width: 2),
            boxShadow: [
              BoxShadow(
                color: scheme.secondary.withValues(alpha: 0.4 * (1 - t)),
                blurRadius: 4 + 8 * t,
                spreadRadius: 1 + 3 * t,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Mosque list (1 col narrow / 2 cols wide).
// ---------------------------------------------------------------------------

class _MosqueList extends StatelessWidget {
  const _MosqueList({
    required this.mosques,
    required this.selectedId,
    required this.onSelect,
    required this.onRoute,
    required this.onDetail,
  });

  final List<Mosque> mosques;
  final String? selectedId;
  final ValueChanged<Mosque> onSelect;
  final ValueChanged<Mosque> onRoute;
  final ValueChanged<Mosque> onDetail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width < 700 ? 1 : 2;
        const gap = AppLayout.sp4;
        final contentWidth = width - AppLayout.sp6 * 2;
        final itemWidth = (contentWidth - gap * (cols - 1)) / cols;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.sp6,
            0,
            AppLayout.sp6,
            AppLayout.sp8,
          ),
          children: [
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final m in mosques)
                  SizedBox(
                    width: itemWidth,
                    child: _MosqueCard(
                      mosque: m,
                      selected: m.id == selectedId,
                      onTap: () => onSelect(m),
                      onRoute: () => onRoute(m),
                      onDetail: () => onDetail(m),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MosqueCard extends StatefulWidget {
  const _MosqueCard({
    required this.mosque,
    required this.selected,
    required this.onTap,
    required this.onRoute,
    required this.onDetail,
  });

  final Mosque mosque;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRoute;
  final VoidCallback onDetail;

  @override
  State<_MosqueCard> createState() => _MosqueCardState();
}

class _MosqueCardState extends State<_MosqueCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final m = widget.mosque;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          transform: _hovered ? Matrix4.translationValues(0, -4, 0) : null,
          padding: const EdgeInsets.all(AppLayout.sp4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(
              color: widget.selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.2),
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: _hovered ? 0.08 : 0.04),
                blurRadius: _hovered ? 32 : 20,
                offset: Offset(0, _hovered ? 12 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            height: 28 / 20,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.address.isEmpty ? S.masjidNoAddress : m.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            height: 20 / 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppLayout.sp2),
                  _DistanceBadge(meters: m.distanceMeters),
                ],
              ),
              if (m.hasAmenity) ...[
                const SizedBox(height: AppLayout.sp3),
                Wrap(
                  spacing: AppLayout.sp2,
                  runSpacing: AppLayout.sp2,
                  children: [
                    for (final a in MosqueAmenity.values)
                      if (m.amenities.contains(a)) _AmenityChip(amenity: a),
                  ],
                ),
              ],
              const SizedBox(height: AppLayout.sp4),
              Row(
                children: [
                  Expanded(
                    child: _RouteButton(onTap: widget.onRoute),
                  ),
                  const SizedBox(width: AppLayout.sp3),
                  Expanded(
                    child: _DetailButton(onTap: widget.onDetail),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.meters});

  final double meters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp2,
        vertical: AppLayout.sp1,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
      ),
      child: Text(
        formatDistance(meters),
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.amenity});

  final MosqueAmenity amenity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(amenity.icon, size: 14, color: scheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            amenity.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 12,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.directions_rounded, size: 18),
      label: const Text(S.masjidRute),
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary),
        padding: const EdgeInsets.symmetric(vertical: AppLayout.sp2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        ),
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  const _DetailButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: AppLayout.sp2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        ),
      ),
      child: const Text(S.masjidDetail),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail bottom sheet — real info from OSM tags only.
// ---------------------------------------------------------------------------

class _MosqueDetailSheet extends StatelessWidget {
  const _MosqueDetailSheet({required this.mosque, required this.onRoute});

  final Mosque mosque;
  final VoidCallback onRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final m = mosque;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.sp6,
          0,
          AppLayout.sp6,
          AppLayout.sp8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    m.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppLayout.sp3),
                _DistanceBadge(meters: m.distanceMeters),
              ],
            ),
            const SizedBox(height: AppLayout.sp5),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: S.masjidDetailAddress,
              value: m.address.isEmpty ? S.masjidNoAddress : m.address,
            ),
            const SizedBox(height: AppLayout.sp3),
            if (m.openingHours != null) ...[
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: S.masjidDetailHours,
                value: m.openingHours!,
              ),
              const SizedBox(height: AppLayout.sp3),
            ],
            Text(
              S.masjidDetailAmenities,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppLayout.sp2),
            if (m.hasAmenity)
              Wrap(
                spacing: AppLayout.sp2,
                runSpacing: AppLayout.sp2,
                children: [
                  for (final a in MosqueAmenity.values)
                    if (m.amenities.contains(a)) _AmenityChip(amenity: a),
                ],
              )
            else
              Text(
                S.masjidNoAmenities,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: AppLayout.sp6),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRoute,
                icon: const Icon(Icons.directions_rounded),
                label: const Text(S.masjidRute),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppLayout.sp3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppLayout.sp2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / error / empty states.
// ---------------------------------------------------------------------------

/// Subtle banner shown when the result came from the offline cache (all live
/// endpoints failed) — honest stale-data indication.
class _CachedNote extends StatelessWidget {
  const _CachedNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppLayout.sp6,
        AppLayout.sp2,
        AppLayout.sp6,
        AppLayout.sp2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp3,
        vertical: AppLayout.sp2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppLayout.sp2),
          Expanded(
            child: Text(
              S.masjidCachedNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppLayout.sp4),
          Text(
            S.masjidLoading,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.isLocationError,
    required this.onRetry,
    this.errorDetail,
  });

  final bool isLocationError;
  final VoidCallback onRetry;

  /// Raw failure summary from [MosqueFetchException] — shown in a muted style
  /// so future failures are diagnosable.
  final String? errorDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    final title =
        isLocationError ? S.masjidLocationUnavailable : S.masjidError;
    final message = isLocationError
        ? (isLinux
            ? S.masjidLocationLinuxHint
            : S.masjidLocationUnavailableHint)
        : S.masjidErrorHint;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLocationError
                  ? Icons.location_off_rounded
                  : Icons.cloud_off_rounded,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppLayout.sp3),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppLayout.sp1),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (errorDetail != null && errorDetail!.isNotEmpty) ...[
              const SizedBox(height: AppLayout.sp2),
              Text(
                errorDetail!,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: scheme.outline,
                ),
              ),
            ],
            const SizedBox(height: AppLayout.sp4),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text(S.masjidRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.sp6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mosque_rounded,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppLayout.sp3),
            Text(S.masjidEmpty, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppLayout.sp1),
            Text(
              S.masjidEmptyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}