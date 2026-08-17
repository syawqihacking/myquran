import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_constants.dart';
import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../core/quran_scale.dart';
import '../../core/tajwid.dart';
import '../../data/db/quran_database.dart';
import '../../data/db/user_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/user_repositories.dart';
import '../../data/services/audio_service.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/ornament.dart';
import '../widgets/quran_text_view.dart';
import 'zen_mode_provider.dart';

/// Baca Al-Quran (Stitch remodel): a pinned app bar (back / surah title /
/// reading controls), a centered Amiri bismillah, and one card per ayah with
/// the number badge, quick actions, Arabic text and translation. The tafsir
/// panel, zen mode, font scale, current-ayah tracking and keyboard navigation
/// all stay — only the paper column becomes the card surface.
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
  bool _tafsirLoading = false;  double _progress = 0;
  bool _restored = false;

  /// Ayah-number → ayah lookup, rebuilt once per ayahs emission (LOW-3/4).
  final Map<int, Ayah> _ayahByNumber = {};
  List<Ayah>? _cachedAyahs;

  /// Ayah id → decoded tajwid ranges (cached; ranges are theme-independent,
  /// unlike spans which depend on the current theme/step).
  final Map<int, List<TajwidRange>> _tajwidCache = {};

  /// Ayah numbers of tiles currently mounted in the (virtualized) viewport.
  final Set<int> _builtAyahNumbers = {};

  /// Audio (phase-2 seam): latest state from the service + current target.
  /// NoopAudioService emits `idle` forever, so playback stays honest until
  /// phase 2 swaps in a real implementation.
  late final StreamSubscription<AudioPlaybackState> _audioSub;
  AudioPlaybackState _audioState = const AudioPlaybackState.idle();
  Ayah? _audioTarget;
  double _speed = 1.0;

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
    _audioSub = ref.read(audioServiceProvider).stateStream.listen((state) {
      if (!mounted) return;
      setState(() => _audioState = state);
    });
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    unawaited(_audioSub.cancel());
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

  void _enterZen() => ref.read(zenModeProvider.notifier).set(true);

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
    final zen = ref.watch(zenModeProvider);
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
    final murottalState = ref.watch(murottalDownloadProvider)[widget.surahId] ??
        const MurottalDownloadState();

    // Reciter (qari) name for the sticky player; falls back to the hardcoded
    // label while the reciter list is loading or unavailable.
    final selectedReciterId = ref.watch(selectedReciterProvider);
    final reciters = ref.watch(recitersProvider).value;
    String reciterName = S.audioReciter;
    for (final r in reciters ?? const <Reciter>[]) {
      if (r.id == selectedReciterId) {
        reciterName = r.name;
        break;
      }
    }

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
          if (ref.read(zenModeProvider)) {
            ref.read(zenModeProvider.notifier).set(false);
          } else if (_openTafsirAyahNumber != null) {
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
              // Zen mode: the top chrome collapses quietly away (200 ms,
              // easeInOutCubic) so only the ayah cards remain. The scroll
              // offset is never touched — the ListView keeps its position.
              AnimatedSize(
                duration: AppLayout.durBase,
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: zen
                    ? const SizedBox(width: double.infinity)
                    : AnimatedOpacity(
                        duration: AppLayout.durQuick,
                        opacity: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ReaderTopBar(
                              surah: surah,
                              ayahCount: ayahs?.length,
                              fontStep: settings.quranFontStep,
                              showTranslation: settings.showTranslation,
                              tajwidColor: settings.tajwidColor,
                              currentAyahNumber: _currentAyahNumber,
                              isCurrentBookmarked: _currentAyahNumber != null &&
                                  bookmarked.contains(
                                    _ayahIdFor(_currentAyahNumber),
                                  ),
                              isCurrentSajda:
                                  _isSajdaAyah(_currentAyahNumber),
                              isCurrentSajdaDone:
                                  _currentAyahNumber != null &&
                                  sajdaDone.contains(
                                    _ayahIdFor(_currentAyahNumber),
                                  ),
                              onBack: () => Navigator.of(context).maybePop(),
                              onFontSmaller: () => _changeStep(-1),
                              onFontLarger: () => _changeStep(1),
                              onToggleZen: _enterZen,
                              onToggleBookmark: () {
                                final id = _ayahIdFor(_currentAyahNumber);
                                if (id != null) {
                                  ref
                                      .read(bookmarkRepositoryProvider)
                                      .toggleBookmark(id);
                                }
                              },
                              onToggleSajda: () {
                                final ayah = _ayahFor(_currentAyahNumber);
                                if (ayah != null) _toggleSajda(ayah);
                              },
                              onToggleTranslation: () => ref
                                  .read(settingsProvider.notifier)
                                  .setShowTranslation(!settings.showTranslation),
                              onToggleTajwid: () => ref
                                  .read(settingsProvider.notifier)
                                  .setTajwidColor(!settings.tajwidColor),
                              onJump: () {
                                if (ayahs != null && ayahs.isNotEmpty) {
                                  _openJump(ayahs.length);
                                }
                              },
                              murottalState: murottalState,
                              onMurottalTap: () =>
                                  _onMurottalTap(widget.surahId),
                            ),
                            _ProgressBar(progress: _progress),
                          ],
                        ),
                      ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Scrollbar(
                      controller: _scroll,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppConstants.contentColumnMaxWidth,
                          ),
                          child: _buildContent(
                            surah,
                            ayahs,
                            settings,
                            bookmarked,
                            sajdaDone,
                          ),                        ),
                      ),
                    ),
                    if (!zen && ayahs != null && ayahs.isNotEmpty)
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
              // Sticky audio player (Stitch §6): pinned above the bottom edge
              // once the user taps play on any ayah; collapses quietly. Hidden
              // in zen mode so only the ayah cards remain.
              AnimatedSwitcher(
                duration: AppLayout.durBase,
                child: !zen && _audioTarget != null
                    ? _StickyAudioPlayer(
                        key: const ValueKey('audio-player'),
                        state: _audioState,
                        surahName: surah?.nameLatin ?? '',
                        ayahNumber: _audioTarget!.ayahNumber,
                        speed: _speed,
                        reciterName: reciterName,
                        onTogglePlayPause: _togglePlayPause,
                        onPrev: _skipPrev,
                        onNext: _skipNext,
                        onCycleSpeed: _cycleSpeed,
                        onVolume: _showComingSoon,
                        onQueue: _showComingSoon,
                        onClose: _closePlayer,
                      )
                    : const SizedBox(
                        key: ValueKey('no-player'),
                        width: double.infinity,
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

    // Virtualized list: optional bismillah, ayah cards, end block. Only cards
    // near the viewport are built.
    final bismillahIndex = surah.hasBismillah == 1 ? 0 : null;
    final ayahStartIndex = bismillahIndex != null ? 1 : 0;
    final endIndex = ayahStartIndex + ayahs.length;
    final itemCount = endIndex + 1;

    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

    return ListView.builder(
      controller: _scroll,
      key: _viewportKey,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppLayout.sp3 : AppLayout.sp6,
        vertical: AppLayout.sp6,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (bismillahIndex != null && index == bismillahIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppLayout.sp6),
            child: Center(
              child: QTextDisplay(
                text: '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064e\u0647\u0650 '
                    '\u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 '
                    '\u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650',
                step: settings.quranFontStep,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        if (index < endIndex) {
          final ayah = ayahs[index - ayahStartIndex];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == endIndex - 1 ? 0 : AppLayout.sp6,
            ),
            child: _AyahTile(
              key: _tileKeys.putIfAbsent(ayah.ayahNumber, GlobalKey.new),
              ayah: ayah,
              surahName: surah.nameLatin,
              quranSize: quranSize,
              markerSize: markerSize,
              translationSize: tSize,
              showTranslation: settings.showTranslation,
              alignRight: settings.alignArabicRight,
              tajwidRanges: settings.tajwidColor
                  ? _tajwidRangesFor(ayah)
                  : null,
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
              isPlaying: _audioTarget?.id == ayah.id &&
                  (_audioState.status == AudioStatus.playing ||
                      _audioState.status == AudioStatus.buffering),
              onPlay: () => _onTilePlay(ayah),
              onPause: () => ref.read(audioServiceProvider).pause(),
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

  // -------------------------------------------------------------------------
  // Audio (phase-2 seam): sticky player + per-ayah play wiring.
  // -------------------------------------------------------------------------

  static const List<double> _playbackSpeeds = [1.0, 1.25, 1.5, 2.0];

  /// Honest "coming soon" SnackBar, used while NoopAudioService is wired in.
  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(S.comingSoon),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  /// Requests playback of [ayah]. Plays the whole surah continuously from this
  /// ayah onward (the audio service builds a playlist of the remaining ayahs
  /// and auto-advances), so the user does not have to tap each ayah to hear the
  /// next one. NoopAudioService stays idle forever, so if the state has not
  /// flipped within a frame we tell the truth: audio is not implemented yet. A
  /// real service flips to buffering/playing, so the player shows the target
  /// and no SnackBar appears.
  Future<void> _requestPlay(Ayah ayah) async {
    await ref.read(audioServiceProvider).playSurahFrom(widget.surahId, ayah.id);
    if (!mounted) return;
    setState(() => _audioTarget = ayah);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_audioState.isIdle) _showComingSoon();
    });
  }

  /// Card play button: pause if this ayah is the one playing, resume if it is
  /// paused, otherwise start it.
  void _onTilePlay(Ayah ayah) {
    final isActive = _audioTarget?.id == ayah.id;
    if (isActive && _audioState.status == AudioStatus.paused) {
      ref.read(audioServiceProvider).resume();
      return;
    }
    if (isActive &&
        (_audioState.status == AudioStatus.playing ||
            _audioState.status == AudioStatus.buffering)) {
      ref.read(audioServiceProvider).pause();
      return;
    }
    _requestPlay(ayah);
  }

  void _togglePlayPause() {
    final target = _audioTarget;
    if (target == null) return;
    switch (_audioState.status) {
      case AudioStatus.playing:
      case AudioStatus.buffering:
        ref.read(audioServiceProvider).pause();
      case AudioStatus.paused:
        ref.read(audioServiceProvider).resume();
      case AudioStatus.idle:
        _requestPlay(target);
    }
  }

  void _skipPrev() {
    final target = _audioTarget;
    final ayahs = _cachedAyahs;
    if (target == null || ayahs == null) return;
    final index = ayahs.indexWhere((a) => a.id == target.id);
    _requestPlay(index > 0 ? ayahs[index - 1] : target);
  }

  void _skipNext() {
    final target = _audioTarget;
    final ayahs = _cachedAyahs;
    if (target == null || ayahs == null) return;
    final index = ayahs.indexWhere((a) => a.id == target.id);
    if (index >= 0 && index + 1 < ayahs.length) {
      _requestPlay(ayahs[index + 1]);
    } else {
      _requestPlay(target);
    }
  }

  void _cycleSpeed() {
    final index = _playbackSpeeds.indexOf(_speed);
    setState(
      () => _speed = _playbackSpeeds[(index + 1) % _playbackSpeeds.length],
    );
  }

  void _closePlayer() {
    ref.read(audioServiceProvider).stop();
    setState(() {
      _audioTarget = null;
      _audioState = const AudioPlaybackState.idle();
    });
  }

  // -------------------------------------------------------------------------
  // Offline murottal (download the current surah for offline playback).
  // -------------------------------------------------------------------------

  /// Tap handler for the top-bar murottal button, driven by the current state:
  /// not-downloaded/error → start; downloading → cancel; downloaded → delete.
  void _onMurottalTap(int surahId) {
    final state = ref.read(murottalDownloadProvider)[surahId] ??
        const MurottalDownloadState();
    switch (state.status) {
      case MurottalDownloadStatus.downloading:
        ref.read(murottalDownloadProvider.notifier).cancel(surahId);
      case MurottalDownloadStatus.downloaded:
        _confirmDeleteMurottal(surahId);
      case MurottalDownloadStatus.notDownloaded:
      case MurottalDownloadStatus.error:
        _startMurottalDownload(surahId);
    }
  }

  Future<void> _startMurottalDownload(int surahId) async {
    await ref.read(murottalDownloadProvider.notifier).download(surahId);
    if (!mounted) return;
    final state = ref.read(murottalDownloadProvider)[surahId];
    if (state?.status == MurottalDownloadStatus.error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(S.murottalDownloadFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } else if (state?.status == MurottalDownloadStatus.downloaded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(S.murottalDownloadDone),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1800),
          ),
        );
    }
  }

  Future<void> _confirmDeleteMurottal(int surahId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.murottalDeleteConfirmTitle),
        content: const Text(S.murottalDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(S.murottalDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(murottalDownloadProvider.notifier).delete(surahId);
    }
  }

  /// Returns the cached decoded tajwid ranges for an ayah, decoding on first
  /// use. Ranges are theme-independent so they can be cached across rebuilds.
  List<TajwidRange>? _tajwidRangesFor(Ayah ayah) {
    return _tajwidCache.putIfAbsent(
        ayah.id, () => decodeTajwid(ayah.textUthmani));
  }
}

// ---------------------------------------------------------------------------
// Reader top bar (Stitch §1: back / surah title+meta / reading controls)
// ---------------------------------------------------------------------------

class _ReaderTopBar extends StatelessWidget {
  const _ReaderTopBar({
    required this.surah,
    required this.ayahCount,
    required this.fontStep,
    required this.showTranslation,
    required this.tajwidColor,
    required this.currentAyahNumber,
    required this.isCurrentBookmarked,
    required this.isCurrentSajda,
    required this.isCurrentSajdaDone,
    required this.onBack,
    required this.onFontSmaller,
    required this.onFontLarger,
    required this.onToggleZen,
    required this.onToggleBookmark,
    required this.onToggleSajda,
    required this.onToggleTranslation,
    required this.onToggleTajwid,
    required this.onJump,
    required this.murottalState,
    required this.onMurottalTap,
  });

  final Surah? surah;
  final int? ayahCount;
  final int fontStep;
  final bool showTranslation;
  final bool tajwidColor;
  final int? currentAyahNumber;
  final bool isCurrentBookmarked;
  final bool isCurrentSajda;
  final bool isCurrentSajdaDone;
  final VoidCallback onBack;
  final VoidCallback onFontSmaller;
  final VoidCallback onFontLarger;
  final VoidCallback onToggleZen;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleSajda;
  final VoidCallback onToggleTranslation;
  final VoidCallback onToggleTajwid;
  final VoidCallback onJump;
  final MurottalDownloadState murottalState;
  final VoidCallback onMurottalTap;

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
          _BarIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: S.back,
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  surah?.nameLatin ?? '…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                if (ayahCount != null)
                  Text(
                    S.surahMeta(surah?.id ?? 0, ayahCount!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          _BarIconButton(
            icon: Icons.text_decrease_rounded,
            tooltip: S.fontSmaller,
            onPressed: fontStep > AppConstants.minQuranFontStep
                ? onFontSmaller
                : null,
          ),
          _BarIconButton(
            icon: Icons.text_increase_rounded,
            tooltip: S.fontLarger,
            onPressed: fontStep < AppConstants.maxQuranFontStep
                ? onFontLarger
                : null,
          ),
          const SizedBox(width: AppLayout.sp1),
          _BarIconButton(
            icon: Icons.fullscreen_rounded,
            tooltip: S.zenEnter,
            onPressed: onToggleZen,
          ),
          const SizedBox(width: AppLayout.sp1),
          _SettingsMenu(
            showTranslation: showTranslation,
            onToggleTranslation: onToggleTranslation,
            onJump: onJump,
            tajwidColor: tajwidColor,
            onToggleTajwid: onToggleTajwid,
            currentAyahNumber: currentAyahNumber,
            isCurrentBookmarked: isCurrentBookmarked,
            onToggleBookmark: onToggleBookmark,
            isCurrentSajda: isCurrentSajda,
            isCurrentSajdaDone: isCurrentSajdaDone,
            onToggleSajda: onToggleSajda,
            murottalState: murottalState,
            onMurottalTap: onMurottalTap,
          ),
          const SizedBox(width: AppLayout.sp2),
        ],
      ),
    );
  }
}

/// Circular bar icon button (design: 24px icon, onSurfaceVariant, circular
/// surfaceVariant hover).
class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: scheme.onSurfaceVariant,
        disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
        hoverColor: scheme.surfaceContainerHighest,
        minimumSize: const Size(40, 40),
      ),
      icon: Icon(icon, size: 24),
    );
  }
}

/// The bar's settings icon → reading options that don't need a dedicated
/// button (translation toggle, jump to ayah, tajwid, bookmark, sujud, murottal).
class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu({
    required this.showTranslation,
    required this.onToggleTranslation,
    required this.onJump,
    required this.tajwidColor,
    required this.onToggleTajwid,
    required this.currentAyahNumber,
    required this.isCurrentBookmarked,
    required this.onToggleBookmark,
    required this.isCurrentSajda,
    required this.isCurrentSajdaDone,
    required this.onToggleSajda,
    required this.murottalState,
    required this.onMurottalTap,
  });

  final bool showTranslation;
  final VoidCallback onToggleTranslation;
  final VoidCallback onJump;
  final bool tajwidColor;
  final VoidCallback onToggleTajwid;
  final int? currentAyahNumber;
  final bool isCurrentBookmarked;
  final VoidCallback onToggleBookmark;
  final bool isCurrentSajda;
  final bool isCurrentSajdaDone;
  final VoidCallback onToggleSajda;
  final MurottalDownloadState murottalState;
  final VoidCallback onMurottalTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Murottal status → icon + label for the menu row.
    final (IconData murottalIcon, String murottalLabel, Color murottalColor) =
        switch (murottalState.status) {
      MurottalDownloadStatus.downloading => (
          Icons.close_rounded,
          S.murottalCancel,
          scheme.primary,
        ),
      MurottalDownloadStatus.downloaded => (
          Icons.download_done_rounded,
          S.murottalDownloaded,
          scheme.tertiaryFixedDim,
        ),
      MurottalDownloadStatus.error => (
          Icons.error_outline_rounded,
          S.murottalDownloadFailed,
          scheme.error,
        ),
      MurottalDownloadStatus.notDownloaded => (
          Icons.download_rounded,
          S.murottalDownload,
          scheme.onSurfaceVariant,
        ),
    };

    return PopupMenuButton<String>(
      tooltip: S.readerSettings,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: scheme.onSurfaceVariant,
        hoverColor: scheme.surfaceContainerHighest,
      ),
      icon: const Icon(Icons.settings_rounded, size: 24),
      onSelected: (v) {
        if (v == 'translation') onToggleTranslation();
        if (v == 'jump') onJump();
        if (v == 'tajwid') onToggleTajwid();
        if (v == 'bookmark') onToggleBookmark();
        if (v == 'sajda') onToggleSajda();
        if (v == 'murottal') onMurottalTap();
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'translation',
          child: Row(
            children: [
              Icon(
                showTranslation
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppLayout.sp3),
              Text(showTranslation ? S.hideTranslation : S.showTranslationLabel),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'jump',
          child: Row(
            children: [
              Icon(Icons.unfold_more_rounded,
                  size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppLayout.sp3),
              Text(S.jumpToAyah),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'tajwid',
          child: Row(
            children: [
              Icon(
                Icons.palette_rounded,
                size: 20,
                color: tajwidColor
                    ? scheme.tertiaryFixedDim
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppLayout.sp3),
              Expanded(child: Text(S.tajwidColorLabel)),
              if (tajwidColor)
                Icon(Icons.check_rounded, size: 18, color: scheme.tertiary),
            ],
          ),
        ),
        if (currentAyahNumber != null)
          PopupMenuItem(
            value: 'bookmark',
            child: Row(
              children: [
                Icon(
                  isCurrentBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: isCurrentBookmarked
                      ? scheme.tertiaryFixedDim
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: Text(
                    isCurrentBookmarked ? S.removeBookmark : S.bookmarkAyah,
                  ),
                ),
              ],
            ),
          ),
        if (isCurrentSajda)
          PopupMenuItem(
            value: 'sajda',
            child: Row(
              children: [
                Text(
                  '\u06E9', // ۩ — place-of-sajdah glyph
                  style: TextStyle(
                    fontFamily: AppConstants.fontQuran,
                    fontSize: 18,
                    height: 1.0,
                    color: isCurrentSajdaDone
                        ? scheme.tertiary
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: Text(
                    isCurrentSajdaDone ? S.sujudUnmark : S.sujudMark,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'murottal',
          child: Row(
            children: [
              Icon(murottalIcon, size: 20, color: murottalColor),
              const SizedBox(width: AppLayout.sp3),
              Expanded(child: Text(murottalLabel)),
            ],
          ),
        ),
      ],
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
// End block
// ---------------------------------------------------------------------------

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
// Ayah card (Stitch §3)
// ---------------------------------------------------------------------------

class _AyahTile extends StatefulWidget {
  const _AyahTile({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.quranSize,
    required this.markerSize,
    required this.translationSize,
    required this.showTranslation,
    required this.alignRight,
    required this.tajwidRanges,
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
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    this.onMounted,
    this.onUnmounted,
  });

  final Ayah ayah;
  final String surahName;
  final double quranSize;
  final double markerSize;
  final double translationSize;
  final bool showTranslation;
  final bool alignRight;
  final List<TajwidRange>? tajwidRanges;
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
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;

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

  /// No share_plus dependency yet — the share action copies the ayah and
  /// confirms with a SnackBar (same pattern as the home daily verse).
  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(
        text: '${widget.ayah.textUthmani}\n\n"${widget.ayah.translation}"\n'
            '${widget.surahName} : ${widget.ayah.ayahNumber}',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(S.copyAyahDone),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  /// Audio is behind the phase-2 seam: play wiring lives in the parent
  /// (`_onTilePlay`), which keeps the honest "Segera hadir" SnackBar while
  /// NoopAudioService is wired in. This button also acts as pause for the
  /// ayah that is currently playing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ayah = widget.ayah;
    final tGap = translationGap(widget.quranSize);
    final align = widget.alignRight ? TextAlign.right : TextAlign.center;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppLayout.durBase,
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppLayout.sp6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          border: Border.all(
            color: widget.isCurrent
                ? scheme.primary.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: _hovered ? 0.09 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row: number badge left, actions right.
            Row(
              children: [
                _NumberBadge(
                  number: ayah.ayahNumber,
                  isFirst: ayah.ayahNumber == 1,
                ),
                const Spacer(),
                _AyahActionButton(
                  icon: widget.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  tooltip: widget.isPlaying ? S.audioPause : S.playAyah,
                  color: widget.isPlaying
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                  onPressed: widget.isPlaying ? widget.onPause : widget.onPlay,
                ),
                _AyahActionButton(
                  icon: widget.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  tooltip:
                      widget.isBookmarked ? S.removeBookmark : S.bookmarkAyah,
                  color: widget.isBookmarked
                      ? scheme.tertiaryFixedDim
                      : scheme.onSurfaceVariant,
                  onPressed: widget.onToggleBookmark,
                ),
                _AyahActionButton(
                  icon: Icons.share_rounded,
                  tooltip: S.shareAyah,
                  onPressed: _share,
                ),
                _AyahActionButton(
                  icon: Icons.menu_book_rounded,
                  tooltip: S.tafsirAction,
                  onPressed: widget.onOpenTafsir,
                ),
              ],
            ),
            const SizedBox(height: AppLayout.sp4),
            // Arabic text (RTL, end-of-ayah sajda glyph inline).
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: QTextDisplay(
                    text: ayah.textUthmani,
                    step: _stepFor(widget.quranSize),
                    alignment: align,
                    color: scheme.onSurface,
                    tajwidRanges: widget.tajwidRanges,
                  ),
                ),
                if (ayah.sajda == 1) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message: widget.isSajdaDone
                        ? S.sujudUnmark
                        : S.sujudMark,
                    child: InkWell(
                      onTap: widget.onToggleSajda,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          '\u06E9', // ۩ — place-of-sajdah glyph
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: AppConstants.fontQuran,
                            fontSize: widget.markerSize * 0.6,
                            height: 1.0,
                            color: widget.isSajdaDone
                                ? scheme.tertiary
                                : scheme.onSurfaceVariant
                                    .withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (widget.showTranslation) ...[
              SizedBox(height: tGap),
              Text(
                ayah.translation,
                style: TextStyle(
                  fontFamily: AppConstants.fontUi,
                  fontFamilyFallback: const [AppConstants.fontArabic],
                  fontSize: widget.translationSize,
                  height: 1.7,
                  color: scheme.onSurfaceVariant,
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
    );
  }

  int _stepFor(double size) {
    // Recompute step from the current size for accurate line height.
    return kQuranFontSizes.indexWhere((s) => s == size) + 1;
  }
}

/// 40px circular ayah-number badge. The first ayah uses the secondary
/// container (emerald wash); the rest surfaceContainer.
class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.isFirst});

  final int number;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFirst ? scheme.secondaryContainer : scheme.surfaceContainer,
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFirst ? scheme.onSecondaryContainer : scheme.onSurface,
        ),
      ),
    );
  }
}

/// One quick action in the card header: 20px icon, onSurfaceVariant, circular
/// surfaceVariant hover (design §3).
class _AyahActionButton extends StatelessWidget {
  const _AyahActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: color ?? scheme.onSurfaceVariant,
        hoverColor: scheme.surfaceContainerHighest,
        fixedSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky audio player (Stitch §6): 1px progress line + reciter / transport /
// options row. Read-only progress — AudioService has no seek API yet.
// ---------------------------------------------------------------------------

class _StickyAudioPlayer extends StatelessWidget {
  const _StickyAudioPlayer({
    super.key,
    required this.state,
    required this.surahName,
    required this.ayahNumber,
    required this.speed,
    required this.reciterName,
    required this.onTogglePlayPause,
    required this.onPrev,
    required this.onNext,
    required this.onCycleSpeed,
    required this.onVolume,
    required this.onQueue,
    required this.onClose,
  });

  final AudioPlaybackState state;
  final String surahName;
  final int ayahNumber;
  final double speed;
  final String reciterName;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onCycleSpeed;
  final VoidCallback onVolume;
  final VoidCallback onQueue;
  final VoidCallback onClose;

  String get _speedLabel =>
      speed == 1.25 ? '1.25x' : '${speed.toStringAsFixed(1)}x';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    final durationMs = state.duration.inMilliseconds;
    final progress = durationMs > 0
        ? (state.position.inMilliseconds / durationMs).clamp(0.0, 1.0)
        : 0.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(color: scheme.surfaceContainerHighest),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PlayerProgressBar(
                progress: progress,
                fill: scheme.primary,
                track: scheme.surfaceContainerHighest,
                thumb: scheme.tertiaryFixedDim,
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.contentColumnMaxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.sp5,
                      vertical: AppLayout.sp4,
                    ),
                    child: Row(
                      children: [
                        // Reciter info — text collapses to the avatar on mobile.
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppLayout.radiusMd,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 24,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              if (!isMobile) ...[
                                const SizedBox(width: AppLayout.sp3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reciterName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        S.audioCaption(
                                          surahName,
                                          ayahNumber,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          height: 14 / 10,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Transport controls.
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PlayerIconButton(
                              icon: Icons.skip_previous_rounded,
                              size: 28,
                              boxSize: isMobile ? 36 : 40,
                              tooltip: S.audioPrev,
                              onPressed: onPrev,
                            ),
                            const SizedBox(width: AppLayout.sp1),
                            _PlayPauseButton(
                              status: state.status,
                              onPressed: onTogglePlayPause,
                            ),
                            const SizedBox(width: AppLayout.sp1),
                            _PlayerIconButton(
                              icon: Icons.skip_next_rounded,
                              size: 28,
                              boxSize: isMobile ? 36 : 40,
                              tooltip: S.audioNext,
                              onPressed: onNext,
                            ),
                          ],
                        ),
                        // Options — speed label is desktop-only per the design,
                        // and the volume placeholder is omitted on mobile to
                        // keep the row from overflowing narrow screens.
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMobile) ...[
                              TextButton(
                                onPressed: onCycleSpeed,
                                style: TextButton.styleFrom(
                                  foregroundColor: scheme.onSurfaceVariant,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppLayout.sp3,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: const StadiumBorder(),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(
                                  _speedLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppLayout.sp1),
                              _PlayerIconButton(
                                icon: Icons.volume_up_rounded,
                                size: 24,
                                tooltip: S.audioVolume,
                                onPressed: onVolume,
                              ),
                            ],
                            _PlayerIconButton(
                              icon: Icons.queue_music_rounded,
                              size: 24,
                              boxSize: isMobile ? 36 : 40,
                              tooltip: S.audioQueue,
                              onPressed: onQueue,
                            ),
                            _PlayerIconButton(
                              icon: Icons.close_rounded,
                              size: 20,
                              boxSize: isMobile ? 36 : 40,
                              tooltip: S.audioClose,
                              onPressed: onClose,
                            ),
                          ],
                        ),
                      ],
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

/// 4px progress line with a 12px thumb at the fill edge (Stitch §6). Read-only
/// for now: the thumb just tracks position (Noop stays at 0, so it sits at
/// the start).
class _PlayerProgressBar extends StatelessWidget {
  const _PlayerProgressBar({
    required this.progress,
    required this.fill,
    required this.track,
    required this.thumb,
  });

  final double progress;
  final Color fill;
  final Color track;
  final Color thumb;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final fillWidth = width * progress;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: Container(color: track)),
              AnimatedContainer(
                duration: AppLayout.durBase,
                curve: Curves.easeOut,
                width: fillWidth,
                height: 4,
                color: fill,
              ),
              AnimatedPositioned(
                duration: AppLayout.durBase,
                curve: Curves.easeOut,
                left: (fillWidth - 6).clamp(0.0, width - 6),
                top: -4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: thumb,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The 56px primary play/pause circle (Stitch §6), with a buffering spinner.
class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.status, required this.onPressed});

  final AudioStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final buffering = status == AudioStatus.buffering;
    final playing = status == AudioStatus.playing;
    return Tooltip(
      message: playing || buffering ? S.audioPause : S.audioPlay,
      child: Material(
        color: scheme.primary,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: buffering
                  ? SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 32,
                      color: scheme.onPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small circular icon button for the player's transport/option rows.
class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton({
    required this.icon,
    required this.size,
    required this.tooltip,
    required this.onPressed,
    this.boxSize = 40,
  });

  final IconData icon;
  final double size;
  final String tooltip;
  final VoidCallback onPressed;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        foregroundColor: scheme.onSurfaceVariant,
        hoverColor: scheme.surfaceContainerHighest,
        fixedSize: Size.square(boxSize),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon, size: size),
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