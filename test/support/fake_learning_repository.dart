import 'package:dio/dio.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';

/// Repository palsu untuk uji widget: mencatat panggilan tanpa menyentuh
/// jaringan, sehingga layar bisa dirender apa adanya.
class FakeLearningRepository extends LearningRepository {
  FakeLearningRepository() : super(Dio());

  final List<int> savedPositions = [];
  final List<String> completedLessons = [];

  /// Isi yang dikembalikan [getUnitLessons]; diisi per pengujian.
  UnitLessons? unitLessons;

  @override
  Future<UnitLessons> getUnitLessons(String id) async {
    final unit = unitLessons;
    if (unit == null) {
      throw StateError('unitLessons belum diisi pada FakeLearningRepository');
    }
    return unit;
  }

  @override
  Future<void> saveVideoPosition(String id, int positionSeconds) async {
    savedPositions.add(positionSeconds);
  }

  @override
  Future<LessonCompletion> completeLesson(
    String id, {
    required int watchedPercent,
    int? durationSeconds,
  }) async {
    completedLessons.add(id);
    return const LessonCompletion(
      lessonId: 'lesson-uji',
      xpEarned: 10,
      totalXp: 10,
      streakDays: 1,
      streakExtended: true,
      unitCompleted: false,
      levelCompleted: false,
    );
  }
}
