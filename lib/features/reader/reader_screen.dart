import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../core/quran_palette.dart';
import '../../core/quran_scale.dart';
import '../../data/db/quran_database.dart';
import '../../data/db/user_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/user_repositories.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/ornament.dart';
import '../widgets/quran_text_view.dart';

/// Reader (§15–§18): paper column, ayah tiles, tafsir, current-ayah tracking,
/// jump pill, and the end-of-surah block.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.surahId, this.initialAyahId});

  final int surahId;
  final int? initialAyahId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  final Map<int, GlobalKey> _tileKeys = {};
  final TextEditingController _jumpController = TextEditingController();

  Timer? _scrollDebounce;
  int? _currentAyahNumber;
  int? _openTafsirAyahNumber;
  final Map<int, Tafsir?> _tafsirCache = {};
  bool _tafsirLoading = false;
  double _progress = 0;
  bool _restored = false;

  /// Ayah-number → ayah lookup, rebuilt once per ayahs emission (LOW-3/4).
  final Map<int, Ayah> _ayahByNumber = {};
  List<Ayah>? _cachedAyahs;

  /// Ayah numbers of tiles currently mounted in the (virtualized) viewport.
  final Set<int> _builtAyahNumbers = {};

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Schedule the initial-position restore as soon as ayahs arrive
    // (fireImmediately covers the already-loaded case). Kept out of build()
    // so the restore runs once, not on every rebuild (LOW-1).
    ref.listenManual<AsyncValue<List<Ayah>>>(
      ayahsProvider(widget.surahId),
      (prev, next) {
        final ayahs = next.value;
        if (ayahs == null) return;
        _cacheAyahs(ayahs);
        _scheduleRestore(ayahs);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    final p = max > 0 ? (_scroll.offset / max).clamp(0.0, 1.0) : 0.0;
    if ((p - _progress).abs() > 0.002) {
      setState(() => _progress = p);
    }
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(
      const Duration(milliseconds: 250),
      _recomputeCurrent,
    );
  }

  void _recomputeCurrent() {
    // Scans only mounted (visible/cached) tiles — O(viewport), not O(surah).
    final viewport = _viewportKey.currentContext;
    if (viewport == null) return;
    final viewportTop =
        (viewport.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;
    int? found;
    for (final n in _builtAyahNumbers) {
      final ctx = _tileKeys[n]?.currentContext;
      if (ctx == null) continue;
      final top =
          (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;
      if (top - viewportTop >= -4) {
        if (found == null || n < found) found = n;
      }
    }
    // Nothing at/above the viewport top → bottom-most mounted tile (e.g. the
    // whole surah fits on screen and the end block is showing).
    if (found == null) {
      for (final n in _builtAyahNumbers) {
        if (found == null || n > found) found = n;
      }
    }
    if (found == null || found == _currentAyahNumber) return;
    setState(() => _currentAyahNumber = found);
    _persistLastRead(found);
  }

  void _persistLastRead(int ayahNumber) {
    final ayah = _ayahByNumber[ayahNumber];
    if (ayah == null) return;
    ref.read(lastReadRepositoryProvider).setLastRead(ayah.id);
    ref.read(readingStatsRepositoryProvider)
        .recordRead(ayahId: ayah.id, juz: ayah.juz);
  }

  void _cacheAyahs(List<Ayah> ayahs) {
    if (identical(_cachedAyahs, ayahs)) return;
    _cachedAyahs = ayahs;
    _ayahByNumber
      ..clear()
      ..addEntries(ayahs.map((a) => MapEntry(a.ayahNumber, a)));
  }

  void _registerTile(int ayahNumber) => _builtAyahNumbers.add(ayahNumber);
  void _unregisterTile(int ayahNumber) => _builtAyahNumbers.remove(ayahNumber);

  /// Scrolls so the given ayah sits at the top of the viewport. Direct
  /// [Scrollable.ensureVisible] when the tile is mounted; otherwise estimate
  /// an offset, jump, then converge using real geometry of mounted tiles.
  Future<bool> _scrollToAyah(int ayahNumber, {required bool animate}) async {
    final key = _tileKeys[ayahNumber];
    if (key?.currentContext != null) {
      _ensureVisible(key!, animate);
      return true;
    }
    final ayahs = _cachedAyahs;
    if (ayahs == null) return false;
    final targetIndex = ayahs.indexWhere((a) => a.ayahNumber == ayahNumber);
    if (targetIndex < 0) return false;
    final pos = _scroll.position;
    if (!pos.hasContentDimensions || pos.maxScrollExtent <= 0) return false;

    // First estimate: linear ratio of the (estimated) max scroll extent.
    _scroll.jumpTo(
      (pos.maxScrollExtent * (targetIndex / ayahs.length))
          .clamp(0.0, pos.maxScrollExtent),
    );
    // Converge: after each frame, snap if the target is now mounted; else
    // correct using the nearest mounted tile's real offset + avg height.
    for (var i = 0; i < 4; i++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return false;
      final key2 = _tileKeys[ayahNumber];
      if (key2?.currentContext != null) {
        _ensureVisible(key2!, animate);
        return true;
      }
      final correction = _estimateOffsetForIndex(targetIndex);
      if (correction == null) return false;
      _scroll.jumpTo(correction.clamp(0.0, _scroll.position.maxScrollExtent));
    }
    return false;
  }

  double? _estimateOffsetForIndex(int targetIndex) {
    int? nearest;
    var best = 1 << 30;
    for (final n in _builtAyahNumbers) {
      final d = (n - 1 - targetIndex).abs();
      if (d < best) {
        best = d;
        nearest = n;
      }
    }
    if (nearest == null) return null;
    final ctx = _tileKeys[nearest]?.currentContext;
    final viewportCtx = _viewportKey.currentContext;
    if (ctx == null || viewportCtx == null) return null;
    final tileTop =
        (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy;
    final viewportTop = (viewportCtx.findRenderObject() as RenderBox)
        .localToGlobal(Offset.zero)
        .dy;
    final tileOffset = _scroll.offset + (tileTop - viewportTop);
    final avg = _averageBuiltHeight();
    if (avg <= 0) return null;
    return tileOffset + (targetIndex - (nearest - 1)) * avg;
  }

  double _averageBuiltHeight() {
    var total = 0.0;
    var count = 0;
    for (final n in _builtAyahNumbers) {
      final ctx = _tileKeys[n]?.currentContext;
      if (ctx == null) continue;
      total += (ctx.findRenderObject() as RenderBox).size.height;
      count++;
    }
    return count == 0 ? 0 : total / count;
  }

  void _ensureVisible(GlobalKey key, bool animate) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: animate ? AppLayout.durPage : Duration.zero,
      curve: Curves.easeOutCubic,
      alignment: 0.0,
    );
  }

  void _scheduleRestore(List<Ayah> ayahs) {
    if (_restored) return;
    _restored = true;

    final settings = ref.read(settingsProvider);
    int? targetNumber;
    var animate = false;
    if (widget.initialAyahId != null) {
      for (final a in ayahs) {
        if (a.id == widget.initialAyahId) {
          targetNumber = a.ayahNumber;
          animate = true;
          break;
        }
      }
    } else if (settings.restoreLastRead) {
      final lastRead = ref.read(lastReadProvider).value;
      if (lastRead != null) {
        for (final a in ayahs) {
          if (a.id == lastRead.ayahId) {
            targetNumber = a.ayahNumber;
            break;
          }
        }
      }
    }
    if (targetNumber == null) return;
    final target = targetNumber;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToAyah(target, animate: animate).then((ok) {
        if (!mounted || !ok) return;
        setState(() => _currentAyahNumber = target);
        _persistLastRead(target);
        if (settings.tafsirOpenByDefault) {
          final ayah = _ayahByNumber[target];
          if (ayah != null) _openTafsir(ayah);
        }
      });
    });
  }

  Future<void> _openTafsir(Ayah ayah) async {
    setState(() => _openTafsirAyahNumber = ayah.ayahNumber);
    if (_tafsirCache.containsKey(ayah.id)) return;
    setState(() => _tafsirLoading = true);
    final tafsir = await ref.read(ayahRepositoryProvider).getTafsir(ayah.id);
    if (!mounted) return;
    setState(() {
      _tafsirCache[ayah.id] = tafsir;
      _tafsirLoading = false;
    });
  }

  void _closeTafsir() => setState(() => _openTafsirAyahNumber = null);

  void _changeStep(int delta) {
    final controller = ref.read(settingsProvider.notifier);
    final current = ref.read(settingsProvider).quranFontStep;
    controller.setFontStep(current + delta);
  }

  void _openJump(int ayahCount) {
    _jumpController.text = '${_currentAyahNumber ?? 1}';
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: S.cancel,
      barrierColor: Colors.transparent,
      transitionDuration: AppLayout.durQuick,
      pageBuilder: (ctx, _, __) {
        return Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 104),
            child: Material(
              elevation: 6,
              color: Theme.of(ctx).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(AppLayout.sp3),
                child: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.jumpToAyah,
                        style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppLayout.sp2),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _jumpController,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              onSubmitted: (_) =>
                                  _submitJump(ctx, ayahCount),
                              decoration: InputDecoration(
                                isDense: true,
                                prefixText: '${S.jumpLabel} ',
                                hintText: '1–$ayahCount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppLayout.radiusSm),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppLayout.sp2),
                          FilledButton(
                            onPressed: () => _submitJump(ctx, ayahCount),
                            child: const Text(S.jumpButton),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitJump(BuildContext ctx, int ayahCount) {
    final n = int.tryParse(_jumpController.text.trim());
    if (n == null || n < 1 || n > ayahCount) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(S.jumpOutOfRange)),
      );
      return;
    }
    Navigator.of(ctx).pop();
    _scrollToAyah(n, animate: true).then((ok) {
      if (!mounted || !ok) return;
      setState(() => _currentAyahNumber = n);
      _persistLastRead(n);
    });
  }

  void _openNextSurah(int surahId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(surahId: surahId),
      ),
    );
  }

  void _toggleSajda(Ayah ayah) {
    final repo = ref.read(sajdaRepositoryProvider);
    final done =
        ref.read(sajdaLogProvider).value?.any((e) => e.ayahId == ayah.id) ??
            false;
    if (done) {
      repo.unmarkSajda(ayah.id);
    } else {
      repo.markSajda(ayah.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final ayahsAsync = ref.watch(ayahsProvider(widget.surahId));
    final surahAsync = ref.watch(surahByIdProvider(widget.surahId));
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final bookmarked = <int>{
      for (final e in bookmarksAsync.value ?? const <BookmarkEntry>[]) e.ayah.id,
    };
    final sajdaDone = <int>{
      for (final e in ref.watch(sajdaLogProvider).value ??
          const <SajdaLogEntry>[])
        e.ayahId,
    };
    final quranSize = quranFontSize(settings.quranFontStep);

    final ayahs = ayahsAsync.value;
    final surah = surahAsync.value;
    if (ayahs != null) _cacheAyahs(ayahs);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.equal, control: true): () =>
            _changeStep(1),
        const SingleActivator(LogicalKeyboardKey.add, control: true): () =>
            _changeStep(1),
        const SingleActivator(LogicalKeyboardKey.minus, control: true): () =>
            _changeStep(-1),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_openTafsirAyahNumber != null) {
            _closeTafsir();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              _ReaderTopBar(
                surah: surah,
                ayahCount: ayahs?.length,
                fontStep: settings.quranFontStep,
                currentAyahNumber: _currentAyahNumber,
                isCurrentBookmarked:
                    _currentAyahNumber != null && bookmarked.contains(
                          _ayahIdFor(_currentAyahNumber),
                        ),
                isCurrentSajda: _isSajdaAyah(_currentAyahNumber),
                isCurrentSajdaDone:
                    _currentAyahNumber != null &&
                    sajdaDone.contains(
                      _ayahIdFor(_currentAyahNumber),
                    ),
                onBack: () => Navigator.of(context).maybePop(),
                onFontSmaller: () => _changeStep(-1),
                onFontLarger: () => _changeStep(1),
                onToggleBookmark: () {
                  final id = _ayahIdFor(_currentAyahNumber);
                  if (id != null) {
                    ref.read(bookmarkRepositoryProvider).toggleBookmark(id);
                  }
                },
                onToggleSajda: () {
                  final ayah = _ayahFor(_currentAyahNumber);
                  if (ayah != null) _toggleSajda(ayah);
                },
              ),
              _ProgressBar(progress: _progress),
              Expanded(
                child: Stack(
                  children: [
                    Scrollbar(
                      controller: _scroll,
                      child: Padding(
                        padding: const EdgeInsets.all(AppLayout.sp6),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: readingWidth(quranSize),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.quran.quranSurface,
                                borderRadius: BorderRadius.circular(
                                    AppLayout.radiusLg),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _buildContent(
                                surah,
                                ayahs,
                                settings,
                                bookmarked,
                                sajdaDone,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (ayahs != null && ayahs.isNotEmpty)
                      Positioned(
                        left: 24,
                        bottom: 24,
                        child: _JumpPill(
                          currentAyahNumber: _currentAyahNumber,
                          onTap: () => _openJump(ayahs.length),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    Surah? surah,
    List<Ayah>? ayahs,
    SettingsState settings,
    Set<int> bookmarked,
    Set<int> sajdaDone,
  ) {
    final quranSize = quranFontSize(settings.quranFontStep);
    final markerSize = ayahMarkerSize(quranSize);
    final tSize = translationFontSize(quranSize);

    if (surah == null || ayahs == null) {
      return const Padding(
        padding: EdgeInsets.all(64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Virtualized list (H-1): header, optional bismillah, ayah tiles, end
    // block. Only tiles near the viewport are built.
    final bismillahIndex = surah.hasBismillah == 1 ? 1 : null;
    final ayahStartIndex = bismillahIndex != null ? 2 : 1;
    final endIndex = ayahStartIndex + ayahs.length;
    final itemCount = endIndex + 1;

    return ListView.builder(
      controller: _scroll,
      key: _viewportKey,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp6,
        vertical: AppLayout.sp6,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _SurahHeader(
            surah: surah,
            step: settings.quranFontStep.clamp(1, 8) + (quranSize > 40 ? 0 : 1),
            onContinue: () => _scrollToAyah(1, animate: true),
          );
        }
        if (bismillahIndex != null && index == bismillahIndex) {
          return Padding(
            padding: const EdgeInsets.only(top: AppLayout.sp6),
            child: Center(
              child: QTextDisplay(
                text: '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064e\u0647\u0650 '
                    '\u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 '
                    '\u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650',
                step: settings.quranFontStep,
              ),
            ),
          );
        }
        if (index < endIndex) {
          final ayah = ayahs[index - ayahStartIndex];
          return Padding(
            padding: EdgeInsets.only(
              top: index == ayahStartIndex ? AppLayout.sp4 : 0,
            ),
            child: _AyahTile(
              key: _tileKeys.putIfAbsent(ayah.ayahNumber, GlobalKey.new),
              ayah: ayah,
              quranSize: quranSize,
              markerSize: markerSize,
              translationSize: tSize,
              showTranslation: settings.showTranslation,
              alignRight: settings.alignArabicRight,
              isCurrent: _currentAyahNumber == ayah.ayahNumber,
              isBookmarked: bookmarked.contains(ayah.id),
              isSajdaDone: sajdaDone.contains(ayah.id),
              tafsirOpen: _openTafsirAyahNumber == ayah.ayahNumber,
              tafsir: _tafsirCache[ayah.id],
              tafsirLoading: _tafsirLoading,
              onOpenTafsir: () => _openTafsir(ayah),
              onCloseTafsir: _closeTafsir,
              onToggleBookmark: () => ref
                  .read(bookmarkRepositoryProvider)
                  .toggleBookmark(ayah.id),
              onToggleSajda: () => _toggleSajda(ayah),
              onMounted: _registerTile,
              onUnmounted: _unregisterTile,
            ),
          );
        }
        return Column(
          children: [
            _EndBlock(
              surah: surah,
              hasNext: surah.id < 114,
              onNext: surah.id < 114 ? () => _openNextSurah(surah.id + 1) : null,
              onHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            const SizedBox(height: AppLayout.sp6),
          ],
        );
      },
    );
  }

  int? _ayahIdFor(int? number) => _ayahByNumber[number]?.id;

  Ayah? _ayahFor(int? number) => _ayahByNumber[number];

  bool _isSajdaAyah(int? number) => _ayahFor(number)?.sajda == 1;
}

// ---------------------------------------------------------------------------
// Reader top bar
// ---------------------------------------------------------------------------

class _ReaderTopBar extends StatelessWidget {
  const _ReaderTopBar({
    required this.surah,
    required this.ayahCount,
    required this.fontStep,
    required this.currentAyahNumber,
    required this.isCurrentBookmarked,
    required this.isCurrentSajda,
    required this.isCurrentSajdaDone,
    required this.onBack,
    required this.onFontSmaller,
    required this.onFontLarger,
    required this.onToggleBookmark,
    required this.onToggleSajda,
  });

  final Surah? surah;
  final int? ayahCount;
  final int fontStep;
  final int? currentAyahNumber;
  final bool isCurrentBookmarked;
  final bool isCurrentSajda;
  final bool isCurrentSajdaDone;
  final VoidCallback onBack;
  final VoidCallback onFontSmaller;
  final VoidCallback onFontLarger;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleSajda;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: AppLayout.readerTopBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  surah?.nameLatin ?? '…',
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ayahCount != null)
                  Text(
                    '$ayahCount ${S.ayatCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: fontStep > AppConstants.minQuranFontStep
                ? onFontSmaller
                : null,
            tooltip: S.fontSmaller,
            icon: const Icon(Icons.text_decrease_rounded),
          ),
          IconButton(
            onPressed: fontStep < AppConstants.maxQuranFontStep
                ? onFontLarger
                : null,
            tooltip: S.fontLarger,
            icon: const Icon(Icons.text_increase_rounded),
          ),
          const SizedBox(width: AppLayout.sp1),
          if (currentAyahNumber != null)
            IconButton(
              onPressed: onToggleBookmark,
              tooltip:
                  isCurrentBookmarked ? S.removeBookmark : S.bookmarkAyah,
              icon: Icon(
                isCurrentBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
            ),
          if (isCurrentSajda) ...[
            const SizedBox(width: AppLayout.sp1),
            IconButton(
              onPressed: onToggleSajda,
              tooltip: isCurrentSajdaDone ? S.sujudUnmark : S.sujudMark,
              icon: Text(
                '\u06E9', // ۩ — place-of-sajdah glyph
                style: TextStyle(
                  fontFamily: AppConstants.fontQuran,
                  fontSize: 22,
                  height: 1.0,
                  color: isCurrentSajdaDone
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(width: AppLayout.sp2),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: AppLayout.progressBarHeight,
      color: scheme.surfaceContainerHighest,
      child: LayoutBuilder(
        builder: (ctx, c) => AnimatedContainer(
          duration: AppLayout.durBase,
          curve: Curves.easeOut,
          width: c.maxWidth * progress,
          color: scheme.primary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Surah header + end block
// ---------------------------------------------------------------------------

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.surah,
    required this.step,
    required this.onContinue,
  });

  final Surah surah;
  final int step;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quran = context.quran;
    final meta = surah.revelationType == 0 ? S.makkiyah : S.madaniyah;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.0,
          colors: [
            quran.quranHeaderGlow,
            quran.quranHeaderGlow.withValues(alpha: 0),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp7,
      ),
      child: Column(
        children: [
          QTextDisplay(text: surah.nameArabic, step: step),
          const SizedBox(height: AppLayout.sp3),
          Text(surah.nameLatin, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppLayout.sp1),
          Text(
            surah.nameIndonesian,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp4),
          const OrnamentDivider(),
          const SizedBox(height: AppLayout.sp5),
          Text(
            '${surah.ayahCount} ${S.ayatCount} · $meta · Juz ${surah.firstJuz}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp5),
          FilledButton.tonalIcon(
            onPressed: onContinue,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            label: const Text(S.continueButton),
          ),
        ],
      ),
    );
  }
}

class _EndBlock extends StatelessWidget {
  const _EndBlock({
    required this.surah,
    required this.hasNext,
    required this.onNext,
    required this.onHome,
  });

  final Surah surah;
  final bool hasNext;
  final VoidCallback? onNext;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.sp8),
      child: Column(
        children: [
          const OrnamentDivider(),
          const SizedBox(height: AppLayout.sp6),
          Text('${S.endOfSurah} — ${surah.nameLatin}',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: AppLayout.sp2),
          Text(
            S.nextSurah,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp5),
          if (onNext != null)
            FilledButton.tonal(
              onPressed: onNext,
              child: const Text(S.nextSurah),
            ),
          const SizedBox(height: AppLayout.sp3),
          TextButton.icon(
            onPressed: onHome,
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text(S.backToHome),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ayah tile (§16–§17)
// ---------------------------------------------------------------------------

class _AyahTile extends StatefulWidget {
  const _AyahTile({
    super.key,
    required this.ayah,
    required this.quranSize,
    required this.markerSize,
    required this.translationSize,
    required this.showTranslation,
    required this.alignRight,
    required this.isCurrent,
    required this.isBookmarked,
    required this.isSajdaDone,
    required this.tafsirOpen,
    required this.tafsir,
    required this.tafsirLoading,
    required this.onOpenTafsir,
    required this.onCloseTafsir,
    required this.onToggleBookmark,
    required this.onToggleSajda,
    this.onMounted,
    this.onUnmounted,
  });

  final Ayah ayah;
  final double quranSize;
  final double markerSize;
  final double translationSize;
  final bool showTranslation;
  final bool alignRight;
  final bool isCurrent;
  final bool isBookmarked;
  final bool isSajdaDone;
  final bool tafsirOpen;
  final Tafsir? tafsir;
  final bool tafsirLoading;
  final VoidCallback onOpenTafsir;
  final VoidCallback onCloseTafsir;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleSajda;

  /// Lifecycle hooks so the parent can track which tiles are mounted
  /// (virtualization: only these are scanned for current-ayah tracking).
  final ValueChanged<int>? onMounted;
  final ValueChanged<int>? onUnmounted;

  @override
  State<_AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends State<_AyahTile> {
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    widget.onMounted?.call(widget.ayah.ayahNumber);
  }

  @override
  void dispose() {
    widget.onUnmounted?.call(widget.ayah.ayahNumber);
    super.dispose();
  }

  Color get _bg {
    final quran = context.quran;
    if (widget.isCurrent && widget.isBookmarked) return quran.quranBookmarkTint;
    if (widget.isCurrent) return quran.quranHighlight;
    if (widget.isBookmarked) return quran.quranBookmarkTint;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final quran = context.quran;
    final theme = Theme.of(context);
    final ayah = widget.ayah;
    final gap = ayahGap(widget.quranSize);
    final tGap = translationGap(widget.quranSize);
    final align =
        widget.alignRight ? TextAlign.right : TextAlign.center;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        color: _bg,
        padding: EdgeInsets.only(bottom: gap),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 16,
              bottom: 16 + gap,
              child: AnimatedOpacity(
                duration: AppLayout.durQuick,
                opacity: widget.isCurrent ? 1 : 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic line + end marker (marker at the visual end/left).
                  Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: QTextDisplay(
                          text: ayah.textUthmani,
                          step: _stepFor(widget.quranSize),
                          alignment: align,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (ayah.sajda == 1) ...[
                        Tooltip(
                          message: widget.isSajdaDone
                              ? S.sujudUnmark
                              : S.sujudMark,
                          child: Text(
                            '\u06E9', // ۩ — place-of-sajdah glyph
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: AppConstants.fontQuran,
                              fontSize: widget.markerSize * 0.6,
                              height: 1.0,
                              color: widget.isSajdaDone
                                  ? quran.quranAccent
                                  : quran.quranInkSecondary
                                      .withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AyahNumberBadge(
                          number: ayah.ayahNumber,
                          size: widget.markerSize,
                        ),
                      ),
                    ],
                  ),
                  if (widget.showTranslation) ...[
                    SizedBox(height: tGap),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${ayah.ayahNumber}. ',
                            style: TextStyle(
                              fontFamily: AppConstants.fontUi,
                              fontSize: widget.translationSize,
                              height: 1.7,
                              color: quran.quranAccent,
                            ),
                          ),
                          TextSpan(
                            text: ayah.translation,
                            style: TextStyle(
                              fontFamily: AppConstants.fontUi,
                              fontFamilyFallback: const [
                                AppConstants.fontArabic,
                              ],
                              fontSize: widget.translationSize,
                              height: 1.7,
                              color: quran.quranInkSecondary,
                            ),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ],
                  if (widget.tafsirOpen) ...[
                    const SizedBox(height: AppLayout.sp4),
                    _TafsirPanel(
                      ayahNumber: ayah.ayahNumber,
                      tafsir: widget.tafsir,
                      loading: widget.tafsirLoading,
                      onClose: widget.onCloseTafsir,
                    ),
                  ],
                ],
              ),
            ),
            // Hover wash (over tints, but below actions).
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: AppLayout.durBase,
                  color: _hovered
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.03)
                      : Colors.transparent,
                ),
              ),
            ),
            if (_hovered)
              Positioned(
                top: 8,
                left: 8,
                child: _TileActions(
                  isBookmarked: widget.isBookmarked,
                  isSajdaDone: widget.isSajdaDone,
                  isSajda: widget.ayah.sajda == 1,
                  onBookmark: widget.onToggleBookmark,
                  onSajda: widget.onToggleSajda,
                  onTafsir: widget.onOpenTafsir,
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _stepFor(double size) {
    // Recompute step from the current size for accurate line height.
    return kQuranFontSizes.indexWhere((s) => s == size) + 1;
  }
}

class _TileActions extends StatelessWidget {
  const _TileActions({
    required this.isBookmarked,
    required this.isSajda,
    required this.isSajdaDone,
    required this.onBookmark,
    required this.onSajda,
    required this.onTafsir,
  });

  final bool isBookmarked;
  final bool isSajda;
  final bool isSajdaDone;
  final VoidCallback onBookmark;
  final VoidCallback onSajda;
  final VoidCallback onTafsir;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onBookmark,
            tooltip: isBookmarked ? S.removeBookmark : S.bookmarkAyah,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: 18,
            ),
          ),
          if (isSajda)
            IconButton(
              onPressed: onSajda,
              tooltip: isSajdaDone ? S.sujudUnmark : S.sujudMark,
              visualDensity: VisualDensity.compact,
              icon: Text(
                '\u06E9', // ۩ — place-of-sajdah glyph
                style: TextStyle(
                  fontFamily: AppConstants.fontQuran,
                  fontSize: 18,
                  height: 1.0,
                  color: isSajdaDone
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          TextButton(
            onPressed: onTafsir,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp3),
            ),
            child: const Text(S.tafsirAction),
          ),
        ],
      ),
    );
  }
}

class _TafsirPanel extends StatelessWidget {
  const _TafsirPanel({
    required this.ayahNumber,
    required this.tafsir,
    required this.loading,
    required this.onClose,
  });

  final int ayahNumber;
  final Tafsir? tafsir;
  final bool loading;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppLayout.sp4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$ayahNumber — ${S.tafsirHeader}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: S.cancel,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: AppLayout.sp2),
          if (loading)
            const LinearProgressIndicator(minHeight: 2)
          else if (tafsir == null)
            Text(
              'Tafsir tidak tersedia untuk ayat ini.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Text(
              (tafsir!.textLong.isNotEmpty ? tafsir!.textLong : tafsir!.textShort),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Jump pill
// ---------------------------------------------------------------------------

class _JumpPill extends StatelessWidget {
  const _JumpPill({required this.currentAyahNumber, required this.onTap});

  final int? currentAyahNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp4,
            vertical: AppLayout.sp2 + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${S.jumpLabel} ${toArabicIndic(currentAyahNumber ?? 1)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: AppLayout.sp1),
              Icon(
                Icons.unfold_more_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
