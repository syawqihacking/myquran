import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../data/models/learning_data.dart';
import 'learning_widgets.dart';

/// All courses in one category, each with its lesson count and progress.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key, required this.category});

  final LearningCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final courses = [
      for (final c in learningCourses)
        if (c.category == category) c,
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            LearningAppBar(
              title: category.label,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppLayout.sp6),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: category.color(scheme),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          size: 18,
                          color: category.onColor(scheme),
                        ),
                      ),
                      const SizedBox(width: AppLayout.sp3),
                      Expanded(
                        child: Text(
                          category.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.sp5),
                  for (var i = 0; i < courses.length; i++) ...[
                    CourseTile(course: courses[i]),
                    if (i != courses.length - 1)
                      const SizedBox(height: AppLayout.sp3),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}