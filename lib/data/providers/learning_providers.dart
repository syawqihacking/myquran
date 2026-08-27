import 'dart:convert' show jsonDecode;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning_data.dart';
import 'database_providers.dart';

// ---- Pusat Belajar progress -------------------------------------------------

/// Persisted progress for one course: the set of completed lesson indices and
/// the epoch-ms of the most recent completion (drives the "Lanjutkan Belajar"
/// hero ordering).
class CourseProgress {
  const CourseProgress({required this.completed, required this.updatedAt});

  final Set<int> completed;
  final int updatedAt;
}

/// Loads/saves per-course learning progress in shared_preferences under
/// `learning_progress_<courseId>` (a JSON string). Follows the amalan_ibadah
/// persistence pattern — survives restarts, no extra dependencies.
class LearningProgressController extends Notifier<Map<String, CourseProgress>> {
  static const _prefix = 'learning_progress_';

  @override
  Map<String, CourseProgress> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final out = <String, CourseProgress>{};
    for (final course in learningCourses) {
      final raw = prefs.getString('$_prefix${course.id}');
      if (raw == null) continue;
      final parsed = _decode(raw);
      if (parsed != null) out[course.id] = parsed;
    }
    return out;
  }

  void _save(String courseId) {
    final prefs = ref.read(sharedPreferencesProvider);
    final p = state[courseId];
    if (p == null) {
      prefs.remove('$_prefix$courseId');
    } else {
      prefs.setString('$_prefix$courseId', _encode(p));
    }
  }

  /// Marks [lessonIndex] of [course] done (or undone when [done] is false).
  void markLesson(Course course, int lessonIndex, {required bool done}) {
    final current =
        state[course.id] ?? const CourseProgress(completed: {}, updatedAt: 0);
    final completed = Set<int>.from(current.completed);
    if (done) {
      completed.add(lessonIndex);
    } else {
      completed.remove(lessonIndex);
    }
    final updated = CourseProgress(
      completed: completed,
      updatedAt: done
          ? DateTime.now().millisecondsSinceEpoch
          : current.updatedAt,
    );
    state = {...state, course.id: updated};
    _save(course.id);
  }

  bool isCompleted(String courseId, int lessonIndex) =>
      state[courseId]?.completed.contains(lessonIndex) ?? false;

  int completedCount(String courseId) => state[courseId]?.completed.length ?? 0;

  /// Index of the first uncompleted lesson in [course] (0 when all done).
  int nextLessonIndex(Course course) {
    final completed = state[course.id]?.completed ?? const <int>{};
    for (var i = 0; i < course.lessons.length; i++) {
      if (!completed.contains(i)) return i;
    }
    return 0;
  }

  /// The most recently updated in-progress course (≥1 lesson done, not all
  /// done). Null when the user has no in-progress course — the hero is then
  /// hidden entirely (honest, no fabricated "continue" state).
  Course? get continueCourse {
    Course? best;
    int? bestAt;
    for (final course in learningCourses) {
      final p = state[course.id];
      if (p == null || p.completed.isEmpty) continue;
      if (p.completed.length >= course.lessons.length) continue;
      if (bestAt == null || p.updatedAt > bestAt) {
        best = course;
        bestAt = p.updatedAt;
      }
    }
    return best;
  }

  static String _encode(CourseProgress p) {
    final lessons = p.completed.toList()..sort();
    return '{"lessons":[${lessons.join(',')}],"updatedAt":${p.updatedAt}}';
  }

  static CourseProgress? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final lessons = decoded['lessons'];
      final updatedAt = decoded['updatedAt'];
      if (lessons is! List || updatedAt is! int) return null;
      final completed = <int>{
        for (final l in lessons)
          if (l is int) l,
      };
      return CourseProgress(completed: completed, updatedAt: updatedAt);
    } catch (e) {
      debugPrint('LearningProgressController._decode: failed to decode progress JSON — $e');
      return null;
    }
  }
}

final learningProgressProvider =
    NotifierProvider<LearningProgressController, Map<String, CourseProgress>>(
      LearningProgressController.new,
    );
