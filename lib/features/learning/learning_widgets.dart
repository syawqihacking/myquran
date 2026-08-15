import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/learning_data.dart';
import '../../data/providers.dart';
import 'course_detail_screen.dart';

/// Shared app bar for the Pusat Belajar screens: back button + centered title
/// (house pattern from the mosque/personality screens).
class LearningAppBar extends StatelessWidget {
  const LearningAppBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
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
              title,
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

/// One course row: title, description, optional category label, a progress bar
/// and "X/Y Langkah". Tapping opens the course detail. Used by the search
/// results (Pusat Belajar) and the course list per category.
class CourseTile extends ConsumerWidget {
  const CourseTile({super.key, required this.course, this.showCategory = false});

  final Course course;
  final bool showCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = ref.watch(learningProgressProvider);
    final done = progress[course.id]?.completed.length ?? 0;
    final total = course.lessons.length;
    final pct = total == 0 ? 0.0 : done / total;

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CourseDetailScreen(course: course),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showCategory) ...[
                          Text(
                            course.category.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              color: course.category.color(scheme),
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          course.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppLayout.sp3),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.sp3),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainer,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppLayout.sp3),
                  Text(
                    '$done/$total ${S.learningLangkah}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
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