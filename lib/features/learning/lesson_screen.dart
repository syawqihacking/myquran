import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/learning_data.dart';
import '../../data/providers.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lesson = course.lessons[lessonIndex];
    final controller = ref.read(learningProgressProvider.notifier);
    final completed =
        ref.watch(learningProgressProvider)[course.id]?.completed
                .contains(lessonIndex) ??
            false;
    final isLast = lessonIndex == course.lessons.length - 1;
    final paragraphs = lesson.content.split('\n\n');

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            LearningAppBar(
              title: course.title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppLayout.sp6),
                children: [
                  Text(
                    '${S.learningLangkah} ${lessonIndex + 1} '
                    '${S.learningLangkahDari} ${course.lessons.length}',
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
                        borderRadius:
                            BorderRadius.circular(AppLayout.radiusFull),
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
                            S.learningSelesai,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        color: scheme.surfaceContainerLowest,
                        child: SvgPicture.asset(
                          lesson.imageAsset!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
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
    );
  }
}

/// Bottom action bar: "Tandai Selesai" when not done; when done, a
/// "Tandai Belum Selesai" toggle plus a primary continue action.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
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
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: completed
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onMarkUndone,
                      child: const Text(S.learningMarkUndone),
                    ),
                  ),
                  const SizedBox(width: AppLayout.sp3),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: isLast ? onBackToCourse : onNext,
                      child: Text(
                        isLast
                            ? S.learningBackToCourse
                            : S.learningNextLesson,
                      ),
                    ),
                  ),
                ],
              )
            : FilledButton(
                onPressed: onMarkDone,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(S.learningMarkDone),
              ),
      ),
    );
  }
}