import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/learning_data.dart';
import '../../data/providers.dart';
import '../widgets/liquid_glass.dart';
import 'learning_widgets.dart';

/// One lesson: scrollable content + a "Tandai Selesai" action. Marking a
/// lesson done advances to the next lesson (or back to the course detail when
/// it was the last one). Completed lessons show a checkmark and can be marked
/// undone to re-read.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({
    super.key,
    required this.course,
    required this.lessonIndex,
  });

  final Course course;
  final int lessonIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lesson = course.lessons[lessonIndex];
    final controller = ref.read(learningProgressProvider.notifier);
    final completed =
        ref
            .watch(learningProgressProvider)[course.id]
            ?.completed
            .contains(lessonIndex) ??
        false;
    final isLast = lessonIndex == course.lessons.length - 1;
    final paragraphs = lesson.content.split('\n\n');

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Content fills the screen and scrolls behind the floating glass
            // header pills — exactly like the home header.
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.sp6,
                        AppLayout.sp10 + AppLayout.sp5,
                        AppLayout.sp6,
                        AppLayout.sp6,
                      ),
                      children: [
                        Text(
                          '${l10n.learningLangkah} ${lessonIndex + 1} '
                          '${l10n.learningLangkahDari} ${course.lessons.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppLayout.sp2),
                        Text(
                          lesson.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (completed) ...[
                          const SizedBox(height: AppLayout.sp3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppLayout.sp3,
                              vertical: AppLayout.sp1,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                AppLayout.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: scheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: AppLayout.sp1),
                                Text(
                                  l10n.learningSelesai,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (lesson.imageAsset != null) ...[
                          const SizedBox(height: AppLayout.sp4),
                          _LessonImage(assetPath: lesson.imageAsset!),
                          const SizedBox(height: AppLayout.sp4),
                        ],
                        const SizedBox(height: AppLayout.sp5),
                        for (final p in paragraphs) ...[
                          Text(
                            p,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppLayout.sp4),
                        ],
                      ],
                    ),
                  ),
                  _BottomBar(
                    completed: completed,
                    isLast: isLast,
                    onMarkDone: () {
                      controller.markLesson(course, lessonIndex, done: true);
                      if (isLast) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => LessonScreen(
                              course: course,
                              lessonIndex: lessonIndex + 1,
                            ),
                          ),
                        );
                      }
                    },
                    onMarkUndone: () =>
                        controller.markLesson(course, lessonIndex, done: false),
                    onNext: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonScreen(
                          course: course,
                          lessonIndex: lessonIndex + 1,
                        ),
                      ),
                    ),
                    onBackToCourse: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Floating glass header pills, over the content.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LearningAppBar(
                title: course.title,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom action bar: "Tandai Selesai" when not done; when done, a
/// "Tandai Belum Selesai" toggle plus a primary continue action.
class _LessonImage extends ConsumerWidget {
  const _LessonImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final fileAsync = ref.watch(lessonImageFileProvider(assetPath));

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: Container(
        width: double.infinity,
        height: 220,
        color: scheme.surfaceContainerLowest,
        child: fileAsync.when(
          data: (path) {
            if (path == null) {
              return _ImagePlaceholder(
                message: l10n.learningImageUnavailable,
                onRetry: () => ref.invalidate(lessonImageFileProvider(assetPath)),
              );
            }
            final file = File(path);
            if (!file.existsSync()) {
              return _ImagePlaceholder(
                message: l10n.learningImageUnavailable,
                onRetry: () => ref.invalidate(lessonImageFileProvider(assetPath)),
              );
            }
            return assetPath.endsWith('.svg')
                ? SvgPicture.file(file, fit: BoxFit.contain)
                : Image.file(file, fit: BoxFit.contain);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          error: (_, __) => _ImagePlaceholder(
            message: l10n.learningImageUnavailable,
            onRetry: () => ref.invalidate(lessonImageFileProvider(assetPath)),
          ),
        ),
      ),
    );
  }
}

/// Quiet placeholder shown while an image fails to download — with a retry.
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 32, color: scheme.onSurfaceVariant),
          const SizedBox(height: AppLayout.sp2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppLayout.sp2),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10nRetry(context)),
          ),
        ],
      ),
    );
  }

  static String l10nRetry(BuildContext context) =>
      AppLocalizations.of(context)!.retry;
}

/// Bottom action bar: "Tandai Selesai" when not done; when done, a
/// "Tandai Belum Selesai" toggle plus a primary continue action.
class _BottomBar extends StatelessWidget {  const _BottomBar({
    required this.completed,
    required this.isLast,
    required this.onMarkDone,
    required this.onMarkUndone,
    required this.onNext,
    required this.onBackToCourse,
  });

  final bool completed;
  final bool isLast;
  final VoidCallback onMarkDone;
  final VoidCallback onMarkUndone;
  final VoidCallback onNext;
  final VoidCallback onBackToCourse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.sp6,
        AppLayout.sp3,
        AppLayout.sp6,
        AppLayout.sp3,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: completed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LiquidGlassButton.filled(
                    onPressed: isLast ? onBackToCourse : onNext,
                    label: isLast
                        ? l10n.learningBackToCourse
                        : l10n.learningNextLesson,
                    height: 48,
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  LiquidGlassButton.tonal(
                    onPressed: onMarkUndone,
                    label: l10n.learningMarkUndone,
                    height: 48,
                  ),
                ],
              )
            : LiquidGlassButton.filled(
                onPressed: onMarkDone,
                label: l10n.learningMarkDone,
                height: 48,
                width: double.infinity,
              ),
      ),
    );
  }
}
