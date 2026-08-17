import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/doa_setelah_sholat_data.dart';
import 'spiritual_reader_screen.dart';

/// Picker screen for Doa Setelah Sholat: 5 interactive cards — one per prayer
/// time (Subuh, Dhuhur, Asar, Maghrib, Isya). Each card navigates to the
/// SpiritualReaderScreen with that prayer's specific doa list.
class DoaSetelahSholatScreen extends StatelessWidget {
  const DoaSetelahSholatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.sp5,
                  AppLayout.sp4,
                  AppLayout.sp5,
                  AppLayout.sp8,
                ),
                children: [
                  // Header
                  _HeaderCard(),
                  const SizedBox(height: AppLayout.sp6),

                  // Section label
                  Text(
                    'PILIH WAKTU SHOLAT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.tertiary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp3),

                  // 5 prayer cards in a grid layout (2 per row, last one full width)
                  Row(
                    children: [
                      Expanded(
                        child: _PrayerCard(info: doaSholatList[0], index: 0),
                      ),
                      const SizedBox(width: AppLayout.sp3),
                      Expanded(
                        child: _PrayerCard(info: doaSholatList[1], index: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  Row(
                    children: [
                      Expanded(
                        child: _PrayerCard(info: doaSholatList[2], index: 2),
                      ),
                      const SizedBox(width: AppLayout.sp3),
                      Expanded(
                        child: _PrayerCard(info: doaSholatList[3], index: 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  _PrayerCard(info: doaSholatList[4], index: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      height: AppLayout.sp10,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: S.back,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: AppLayout.sp2),
          Expanded(
            child: Text(
              S.doaSetelahSholatTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header card ──────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative watermark
          Positioned(
            right: -28,
            bottom: -32,
            child: Transform.rotate(
              angle: -12 * math.pi / 180,
              child: Icon(
                Icons.front_hand_rounded,
                size: 120,
                color: scheme.onPrimary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                    ),
                    child: Icon(
                      Icons.front_hand_rounded,
                      size: 22,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppLayout.sp3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.doaSetelahSholatTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          S.doaSetelahSholatCaption,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.sp4),
              // Small stat row
              Row(
                children: [
                  _HeaderChip(
                    icon: Icons.access_time_rounded,
                    label: '5 Waktu',
                    color: scheme.onPrimary,
                  ),
                  const SizedBox(width: AppLayout.sp2),
                  _HeaderChip(
                    icon: Icons.auto_stories_rounded,
                    label: '${doaSholatList.first.items.length}+ Doa',
                    color: scheme.onPrimary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp3,
        vertical: AppLayout.sp1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Prayer time card ─────────────────────────────────────────────────────


const List<IconData> _prayerIcons = [
  Icons.wb_twilight_rounded, // Subuh
  Icons.wb_sunny_rounded, // Dhuhur
  Icons.cloud_rounded, // Asar
  Icons.nights_stay_rounded, // Maghrib
  Icons.dark_mode_rounded, // Isya
];

class _PrayerCard extends StatefulWidget {
  const _PrayerCard({
    required this.info,
    required this.index,
  });

  final DoaSholatInfo info;
  final int index;

  @override
  State<_PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<_PrayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final info = widget.info;
    final icon = _prayerIcons[widget.index];

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SpiritualReaderScreen(
                title: 'Doa Setelah ${info.name}',
                subtitle: info.timeHint,
                items: info.items,
                icon: icon,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              if (_pressed)
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Arabic watermark in background
              Positioned(
                right: -8,
                bottom: -8,
                child: Text(
                  info.arabicName,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary.withValues(alpha: 0.05),
                    height: 1,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                    ),
                    child: Icon(icon, size: 24, color: scheme.primary),
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  // Text content
                  Text(
                    'Sholat ${info.name}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.timeHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  // Item count chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.sp2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    ),
                    child: Text(
                      '${info.items.length} doa & dzikir',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
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

/// Workaround: AnimatedBuilder is just an alias for AnimatedWidget's builder
/// pattern. We use the standard Flutter [AnimatedBuilder] here.
