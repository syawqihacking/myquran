import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/models/learning_data.dart';
import '../../data/providers.dart';
import 'course_detail_screen.dart';
import 'course_list_screen.dart';
import 'learning_widgets.dart';

/// Pusat Belajar (Stitch "Pusat Belajar", Sacred Path): search, the
/// "Lanjutkan Belajar" hero (only when there is a real in-progress course —
/// honest, hidden otherwise), and the three category cards with real course
/// counts. Typing in the search filters courses across categories.
class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Course> get _searchResults {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return [
      for (final c in learningCourses)
        if (c.title.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
          c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final searching = _query.trim().isNotEmpty;
    final results = _searchResults;
    // Watch the state so the hero/progress rebuild on change, then read the
    // derived "continue course" from the controller.
    ref.watch(learningProgressProvider);
    final continueCourse = ref.read(learningProgressProvider.notifier).continueCourse;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            LearningAppBar(
              title: S.learningTitle,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.sp6,
                AppLayout.sp4,
                AppLayout.sp6,
                AppLayout.sp2,
              ),
              child: _SearchField(
                controller: _searchController,
                focusNode: _searchFocus,
                query: _query,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: searching
                  ? _SearchResults(results: results)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppLayout.sp6,
                        AppLayout.sp4,
                        AppLayout.sp6,
                        AppLayout.sp8,
                      ),
                      children: [
                        if (continueCourse != null) ...[
                          _ContinueHero(course: continueCourse),
                          const SizedBox(height: AppLayout.sp6),
                        ],
                        Text(
                          S.learningKategoriTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppLayout.sp3),
                        for (var i = 0;
                            i < LearningCategory.values.length;
                            i++) ...[
                          _CategoryCard(
                            category: LearningCategory.values[i],
                            courseCount: [
                              for (final c in learningCourses)
                                if (c.category == LearningCategory.values[i]) c,
                            ].length,
                          ),
                          if (i != LearningCategory.values.length - 1)
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

// ---------------------------------------------------------------------------
// Search field (rounded-full, per the design).
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: S.learningSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        prefixIconColor: scheme.outline,
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  focusNode.requestFocus();
                },
                tooltip: S.cancel,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppLayout.sp3,
          horizontal: AppLayout.sp4,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusFull),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Lanjutkan Belajar" hero (conditional on real in-progress course).
// ---------------------------------------------------------------------------

class _ContinueHero extends ConsumerWidget {
  const _ContinueHero({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = ref.watch(learningProgressProvider);
    final done = progress[course.id]?.completed.length ?? 0;
    final total = course.lessons.length;
    final nextIndex =
        ref.read(learningProgressProvider.notifier).nextLessonIndex(course);
    final nextLesson = course.lessons[nextIndex];
    final pct = total == 0 ? 0 : (done * 100 / total).round();

    return Material(
      color: scheme.primary,
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CourseDetailScreen(course: course),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          ),
          child: Stack(
            children: [
              // Decorative blurred circles (secondary top-right, tertiary
              // bottom-left) — radial gradients read as soft glows.
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scheme.secondary.withValues(alpha: 0.20),
                        scheme.secondary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -32,
                left: -32,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scheme.tertiary.withValues(alpha: 0.10),
                        scheme.tertiary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 20,
                        color: scheme.primaryFixedDim,
                      ),
                      const SizedBox(width: AppLayout.sp2),
                      Text(
                        S.learningHeroLabel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: scheme.primaryFixedDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.sp3),
                  Text(
                    course.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp1),
                  Text(
                    '${S.learningLangkah} ${nextIndex + 1}: '
                    '${nextLesson.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.primaryFixedDim,
                    ),
                  ),
                  const SizedBox(height: AppLayout.sp4),
                  Row(
                    children: [
                      Text(
                        '$pct% ${S.learningSelesai}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.tertiaryFixed,
                        ),
                      ),
                      const SizedBox(width: AppLayout.sp3),
                      Text(
                        '$done/$total ${S.learningLangkah}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primaryFixedDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.sp2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0.0 : done / total,
                      minHeight: 6,
                      backgroundColor:
                          scheme.primaryFixedDim.withValues(alpha: 0.20),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(scheme.tertiaryFixed),
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

// ---------------------------------------------------------------------------
// Category cards.
// ---------------------------------------------------------------------------

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.courseCount});

  final LearningCategory category;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = category.color(scheme);
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CourseListScreen(category: category),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppLayout.sp4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 24,
                  color: category.onColor(scheme),
                ),
              ),
              const SizedBox(width: AppLayout.sp4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppLayout.sp3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.sp3,
                  vertical: AppLayout.sp1,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppLayout.radiusFull),
                ),
                child: Text(
                  '$courseCount ${S.learningCourseCount}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
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

// ---------------------------------------------------------------------------
// Search results.
// ---------------------------------------------------------------------------

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results});

  final List<Course> results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.sp6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppLayout.sp3),
              Text(
                S.learningSearchEmpty,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppLayout.sp1),
              Text(
                S.learningSearchEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.sp6,
        AppLayout.sp4,
        AppLayout.sp6,
        AppLayout.sp8,
      ),
      children: [
        for (var i = 0; i < results.length; i++) ...[
          CourseTile(course: results[i], showCategory: true),
          if (i != results.length - 1) const SizedBox(height: AppLayout.sp3),
        ],
      ],
    );
  }
}