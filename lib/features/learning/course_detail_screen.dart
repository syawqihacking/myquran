import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/learning_data.dart';
import '../../data/providers.dart';
import 'learning_widgets.dart';
import 'lesson_screen.dart';

/// Course detail: description + overall progress, then the lesson list with
/// completion checkmarks. Tapping a lesson opens the lesson screen; completed
/// lessons stay tappable to re-read.
class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = ref.watch(learningProgressProvider);
    final done = progress[course.id]?.completed.length ?? 0;
    final total = course.lessons.length;
    final pct = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Content fills the screen and scrolls behind the floating glass
            // header pills — exactly like the home header.
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.sp6,
                  AppLayout.sp10 + AppLayout.sp5,
                  AppLayout.sp6,
                  AppLayout.sp6,
                ),
                children: [
                  // Header card: description + progress.
                  Container(
                    padding: const EdgeInsets.all(AppLayout.sp5),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: course.category
                                    .color(scheme)
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(
                                  AppLayout.radiusMd,
                                ),
                              ),
                              child: Icon(
                                course.category.icon,
                                size: 22,
                                color: course.category.onColor(scheme),
                              ),
                            ),
                            const SizedBox(width: AppLayout.sp3),
                            Expanded(
                              child: Text(
                                course.category.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppLayout.sp3),
                        Text(
                          course.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppLayout.sp4),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppLayout.radiusFull,
                                ),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
                                  backgroundColor: scheme.surfaceContainer,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppLayout.sp3),
                            Text(
                              '$done/$total ${l10n.learningLangkah}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp5),
                  Text(
                    l10n.learningDaftarLangkah,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  for (var i = 0; i < total; i++) ...[
                    _LessonTile(course: course, index: i),
                    if (i != total - 1) const SizedBox(height: AppLayout.sp2),
                  ],
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

class _LessonTile extends ConsumerWidget {
  const _LessonTile({required this.course, required this.index});

  final Course course;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final completed =
        ref
            .watch(learningProgressProvider)[course.id]
            ?.completed
            .contains(index) ??
        false;
    final lesson = course.lessons[index];

    return Material(
      color: completed
          ? scheme.primaryContainer.withValues(alpha: 0.18)
          : scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LessonScreen(course: course, lessonIndex: index),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.sp4,
            vertical: AppLayout.sp3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            border: Border.all(
              color: completed
                  ? scheme.primaryContainer
                  : scheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: completed ? scheme.primary : scheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: completed
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: scheme.onPrimary,
                      )
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: AppLayout.sp3),
              Expanded(
                child: Text(
                  lesson.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: completed ? scheme.onSurface : scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
