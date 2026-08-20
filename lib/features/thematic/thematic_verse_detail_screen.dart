import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../data/db/quran_database.dart';
import '../../data/models/thematic_quran_data.dart';
import '../../data/providers.dart';
import '../../data/services/audio_service.dart';
import '../reader/reader_screen.dart';
import '../widgets/ayah_number_badge.dart';
import '../widgets/glass_pill.dart';
import '../widgets/quran_text_view.dart';

/// Item holding resolved verse data for thematic display.
class ThematicResolvedVerse {
  const ThematicResolvedVerse({
    required this.ayah,
    required this.surah,
    this.note,
  });

  final Ayah ayah;
  final Surah surah;
  final String? note;
}

class ThematicVerseDetailScreen extends ConsumerStatefulWidget {
  const ThematicVerseDetailScreen({
    super.key,
    this.category,
    this.searchQuery,
  }) : assert(category != null || searchQuery != null);

  final QuranThemeCategory? category;
  final String? searchQuery;

  @override
  ConsumerState<ThematicVerseDetailScreen> createState() =>
      _ThematicVerseDetailScreenState();
}

class _ThematicVerseDetailScreenState
    extends ConsumerState<ThematicVerseDetailScreen> {
  late Future<List<ThematicResolvedVerse>> _futureVerses;

  @override
  void initState() {
    super.initState();
    _futureVerses = _loadVerses();
  }

  Future<List<ThematicResolvedVerse>> _loadVerses() async {
    final ayahRepo = ref.read(ayahRepositoryProvider);
    final surahRepo = ref.read(surahRepositoryProvider);
    final searchRepo = ref.read(searchRepositoryProvider);

    final results = <ThematicResolvedVerse>[];

    if (widget.category != null) {
      final category = widget.category!;
      for (final refItem in category.verses) {
        final ayah = await ayahRepo.getAyahByNumber(
          refItem.surahNumber,
          refItem.ayahNumber,
        );
        if (ayah != null) {
          final surah = await surahRepo.getSurah(ayah.surahId);
          if (surah != null) {
            results.add(
              ThematicResolvedVerse(
                ayah: ayah,
                surah: surah,
                note: refItem.note,
              ),
            );
          }
        }
      }
    } else if (widget.searchQuery != null &&
        widget.searchQuery!.trim().isNotEmpty) {
      final query = widget.searchQuery!.trim();
      final hits = await searchRepo.search(query, limit: 40);
      final surahs = await surahRepo.watchSurahs().first;
      final surahMap = {for (final s in surahs) s.id: s};

      for (final hit in hits) {
        final ayah = await ayahRepo.getAyah(hit.ayahId);
        final surah = surahMap[hit.surahId];
        if (ayah != null && surah != null) {
          results.add(
            ThematicResolvedVerse(
              ayah: ayah,
              surah: surah,
            ),
          );
        }
      }
    }

    return results;
  }

  void _shareVerse(ThematicResolvedVerse item) {
    final text =
        'QS. ${item.surah.nameLatin}: ${item.ayah.ayahNumber}\n\n'
        '${item.ayah.textUthmani}\n\n'
        '"${item.ayah.translation}"\n\n'
        '(Dibagikan via MyQuran)';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ayat berhasil disalin ke papan klip!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final audioState = ref.watch(audioPlaybackStateProvider);
    final audioService = ref.read(audioServiceProvider);
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final bookmarkedIds = <int>{
      for (final e in bookmarksAsync.value ?? const []) e.ayah.id,
    };

    final title = widget.category?.title ?? 'Hasil: "${widget.searchQuery}"';
    final subtitle = widget.category?.description ??
        'Ayat-ayat yang berkaitan dengan kata kunci pencarian.';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -120,
            right: -120,
            child: _AmbientGlow(color: scheme.primary.withValues(alpha: 0.04)),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: _AmbientGlow(color: scheme.primary.withValues(alpha: 0.04)),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: FutureBuilder<List<ThematicResolvedVerse>>(
                    future: _futureVerses,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(AppLayout.sp8),
                          child: Center(
                            child: Text(
                              'Gagal memuat data ayat: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                        );
                      }

                      final verses = snapshot.data ?? const [];

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppLayout.sp6,
                          AppLayout.sp10 + AppLayout.sp5,
                          AppLayout.sp6,
                          AppLayout.sp8,
                        ),
                        children: [
                          // Top info banner
                          _buildThemeHeaderCard(scheme, theme, title, subtitle, verses.length),
                          const SizedBox(height: AppLayout.sp5),

                          if (verses.isEmpty)
                            _buildEmptyState(scheme, theme)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: verses.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppLayout.sp4),
                              itemBuilder: (context, index) {
                                final item = verses[index];
                                final isPlaying = audioState.ayahId == item.ayah.id &&
                                    (audioState.status == AudioStatus.playing ||
                                        audioState.status == AudioStatus.buffering);
                                final isBookmarked =
                                    bookmarkedIds.contains(item.ayah.id);

                                return _MinimalVerseCard(
                                  item: item,
                                  isPlaying: isPlaying,
                                  isBookmarked: isBookmarked,
                                  onTogglePlay: () {
                                    if (isPlaying) {
                                      audioService.pause();
                                    } else {
                                      audioService.playAyah(item.ayah.id);
                                    }
                                  },
                                  onToggleBookmark: () {
                                    ref
                                        .read(bookmarkRepositoryProvider)
                                        .toggleBookmark(item.ayah.id);
                                  },
                                  onOpenReader: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ReaderScreen(
                                          surahId: item.surah.id,
                                          initialAyahId: item.ayah.id,
                                        ),
                                      ),
                                    );
                                  },
                                  onShare: () => _shareVerse(item),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Floating glass header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _ThematicDetailAppBar(
                    title: title,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeHeaderCard(
    ColorScheme scheme,
    ThemeData theme,
    String title,
    String subtitle,
    int count,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp5,
        vertical: AppLayout.sp6,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            ),
            child: Icon(
              widget.category?.icon ?? Icons.manage_search_rounded,
              color: scheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: AppLayout.sp3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            ),
            child: Text(
              '$count Ayat',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.sp8),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: scheme.outline,
            ),
            const SizedBox(height: AppLayout.sp4),
            Text(
              'Tidak ada ayat yang ditemukan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba gunakan kata kunci tema lain seperti "sabar", "rezeki", atau "doa".',
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

class _MinimalVerseCard extends StatelessWidget {
  const _MinimalVerseCard({
    required this.item,
    required this.isPlaying,
    required this.isBookmarked,
    required this.onTogglePlay,
    required this.onToggleBookmark,
    required this.onOpenReader,
    required this.onShare,
  });

  final ThematicResolvedVerse item;
  final bool isPlaying;
  final bool isBookmarked;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleBookmark;
  final VoidCallback onOpenReader;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(
          color: isPlaying
              ? scheme.primary.withValues(alpha: 0.6)
              : scheme.outlineVariant.withValues(alpha: 0.4),
          width: isPlaying ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isPlaying ? 0.08 : 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.sp5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Surah info & actions
            Row(
              children: [
                AyahNumberBadge(
                  number: item.ayah.ayahNumber,
                  size: 32,
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QS. ${item.surah.nameLatin} : ${item.ayah.ayahNumber}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        '${item.surah.nameIndonesian} • Juz ${item.ayah.juz}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    size: 20,
                  ),
                  color: isBookmarked ? scheme.primary : scheme.outline,
                  tooltip: isBookmarked ? 'Hapus Simpanan' : 'Simpan Ayat',
                  onPressed: onToggleBookmark,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 19),
                  color: scheme.outline,
                  tooltip: 'Bagikan Ayat',
                  onPressed: onShare,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            if (item.note != null && item.note!.trim().isNotEmpty) ...[
              const SizedBox(height: AppLayout.sp3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppLayout.sp5),

            // Arabic Text
            Directionality(
              textDirection: TextDirection.rtl,
              child: QTextDisplay(
                text: item.ayah.textUthmani,
                step: 1,
                alignment: TextAlign.right,
              ),
            ),

            const SizedBox(height: AppLayout.sp4),

            // Translation Text
            Text(
              item.ayah.translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: scheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: AppLayout.sp4),
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppLayout.sp3),

            // Bottom Actions: Play audio & Read in Quran
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTogglePlay,
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? scheme.primary.withValues(alpha: 0.12)
                            : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius:
                            BorderRadius.circular(AppLayout.radiusFull),
                        border: Border.all(
                          color: isPlaying
                              ? scheme.primary.withValues(alpha: 0.4)
                              : scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                            color: isPlaying ? scheme.primary : scheme.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPlaying ? 'Jeda Audio' : 'Putar Murottal',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isPlaying
                                  ? scheme.primary
                                  : scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.auto_stories_outlined, size: 17),
                  label: const Text('Buka di Al-Qur\'an'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: scheme.primary,
                  ),
                  onPressed: onOpenReader,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThematicDetailAppBar extends StatelessWidget {
  const _ThematicDetailAppBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GlassHeader(
      title: title,
      titleStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      leading: GlassPill(
        padding: EdgeInsets.zero,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
          color: scheme.onSurface,
          onPressed: onBack,
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
