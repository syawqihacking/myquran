import 'dart:async';

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
import '../widgets/quran_text_view.dart';
import 'reader_ayah_tile.dart';
import 'reader_audio_player.dart';
import 'reader_end_block.dart';
import 'reader_jump_pill.dart';
import 'reader_progress_bar.dart';
import 'reader_top_bar.dart';
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
                            ReaderTopBar(
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
                            ReaderProgressBar(progress: _progress),
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
                        child: ReaderJumpPill(
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
                    ? ReaderAudioPlayer(
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
            child: ReaderAyahTile(
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
            ReaderEndBlock(
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

  /// Displays an error SnackBar when audio playback fails.
  void _showAudioError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(S.audioError),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2500),
        ),
      );
  }

  /// Requests playback of [ayah]. Plays the whole surah continuously from this
  /// ayah onward (the audio service builds a playlist of the remaining ayahs
  /// and auto-advances).
  Future<void> _requestPlay(Ayah ayah) async {
    setState(() => _audioTarget = ayah);
    try {
      await ref
          .read(audioServiceProvider)
          .playSurahFrom(widget.surahId, ayah.id);
    } catch (e) {
      debugPrint('ReaderScreen._requestPlay: audio playback failed for ayah ${ayah.id} — $e');
      if (!mounted) return;
      _showAudioError();
    }
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
