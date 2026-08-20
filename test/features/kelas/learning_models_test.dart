import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';

import '../../fixtures/learning_fixtures.dart';

/// Kontrak parsing model Kelas Tandur terhadap respons backend yang sebenarnya.
///
/// Kurikulum "materi" baru mengirim field yang sebelumnya tidak pernah terisi
/// (blocks bertipe CALLOUT, videoKind EMBED, youtubeVideoId, attribution,
/// sourceReference, reviewedBy, explanation). Tes ini yang menjaga agar
/// perubahan bentuk respons ketahuan di sini, bukan di layar pengguna.
void main() {
  group('LearningMap', () {
    test('membaca stats dan seluruh node peta', () {
      final map = LearningMap.fromJson(learningMapJson);

      expect(map.lives, 5);
      expect(map.totalXp, 0);
      expect(map.nodes, hasLength(4));
      expect(map.nodes.map((n) => n.code), containsAll(['C1', 'C2']));
    });

    test('respons tanpa field commodity tidak melempar', () {
      // Backend menghilangkan `commodity` ketika peta diminta tanpa filter.
      expect(learningMapJson.containsKey('commodity'), isFalse);

      final map = LearningMap.fromJson(learningMapJson);
      expect(map.commodity, Commodity.unknown);
    });

    test('node terkunci membawa alasan yang bisa ditampilkan', () {
      final map = LearningMap.fromJson(learningMapJson);
      final locked = map.nodes.firstWhere((n) => n.code == 'C2');

      expect(locked.status, NodeStatus.locked);
      expect(locked.lockReason, isNotNull);
      expect(locked.lockReason, isNotEmpty);
    });
  });

  group('LevelDetail', () {
    test('membaca daftar unit dan ujian akhir petak', () {
      final level = LevelDetail.fromJson(levelDetailJson);

      expect(level.code, 'C1');
      expect(level.units, hasLength(7));
      expect(level.units.first.status, NodeStatus.available);
      expect(level.units[1].status, NodeStatus.locked);
      expect(level.finalTest, isNotNull);
    });

    test('progres unit dihitung dari jumlah lesson', () {
      final level = LevelDetail.fromJson(levelDetailJson);
      final unit = level.units.first;

      expect(unit.lessonCount, greaterThan(0));
      expect(unit.progress, unit.completedCount / unit.lessonCount);
    });
  });

  group('UnitLessons', () {
    test('memetakan seluruh tipe lesson kurikulum baru', () {
      final unit = UnitLessons.fromJson(unitLessonsJson);

      expect(unit.lessons, hasLength(4));
      expect(unit.lessons.map((l) => l.type), [
        LessonType.card,
        LessonType.card,
        LessonType.video,
        LessonType.exerciseMcq,
      ]);
    });

    test('video kurikulum ditandai tidak bisa offline', () {
      final unit = UnitLessons.fromJson(unitLessonsJson);
      final video = unit.lessons.firstWhere((l) => l.type == LessonType.video);

      expect(video.isOfflineCapable, isFalse);
      expect(video.xpReward, 15);
    });

    test('unit tanpa ujian mengembalikan quiz null', () {
      final unit = UnitLessons.fromJson(unitLessonsJson);
      expect(unit.quiz, isNull);
    });
  });

  group('LessonDetail', () {
    test('materi CARD membawa blok, sumber, dan peninjau', () {
      final lesson = LessonDetail.fromJson(lessonCardJson);

      expect(lesson.type, LessonType.card);
      expect(lesson.blocks, hasLength(5));
      expect(lesson.sourceReference, isNotEmpty);
      expect(lesson.reviewedBy, isNotEmpty);
    });

    test('blok CALLOUT membawa judul dan varian', () {
      final lesson = LessonDetail.fromJson(lessonCardJson);
      final callouts = lesson.blocks
          .where((b) => b.type == LessonBlockType.callout)
          .toList();

      expect(callouts, hasLength(2));
      expect(callouts.map((c) => c.variant), containsAll(['TIP', 'MISTAKE']));
      for (final callout in callouts) {
        expect(callout.title, isNotNull);
        expect(callout.title, isNotEmpty);
      }
    });

    test('urutan blok pertama adalah HEADING lalu PARAGRAPH', () {
      final lesson = LessonDetail.fromJson(lessonCardJson);

      expect(lesson.blocks.first.type, LessonBlockType.heading);
      expect(lesson.blocks[1].type, LessonBlockType.paragraph);
    });

    test('materi VIDEO memakai embed YouTube plus atribusi kanal', () {
      final lesson = LessonDetail.fromJson(lessonVideoJson);

      expect(lesson.type, LessonType.video);
      expect(lesson.videoKind, VideoKind.embed);
      expect(lesson.youtubeVideoId, isNotEmpty);
      expect(lesson.attribution, contains('YouTube'));
      expect(lesson.isOfflineCapable, isFalse);

      // Kurikulum baru tidak lagi mengirim berkas video langsung.
      expect(lesson.videoUrl360p, isNull);
      expect(lesson.videoUrl720p, isNull);
    });
  });

  group('Latihan', () {
    test('soal latihan membawa pilihan berkunci A/B/C', () {
      final exercise = ExerciseDetail.fromJson(exerciseJson);

      expect(
        exercise.type,
        LessonType.unknown,
        reason: 'backend tidak mengirim type pada paket latihan',
      );
      expect(exercise.questions, hasLength(3));
      expect(exercise.questions.first.options.map((o) => o.key), [
        'A',
        'B',
        'C',
      ]);
    });

    test('hasil latihan memisahkan skor persen dari jumlah benar', () {
      final result = ExerciseResult.fromJson(exerciseResultJson);

      expect(result.totalCount, 3);
      expect(result.correctCount, 0);
      // `score` adalah persentase 0-100, bukan jumlah jawaban benar.
      expect(result.score, 0);
      expect(result.results, hasLength(3));
    });

    test('setiap butir salah membawa jawaban benar dan pembahasan', () {
      final result = ExerciseResult.fromJson(exerciseResultJson);

      for (final answer in result.results) {
        expect(answer.correctAnswer, isNotEmpty);
        expect(answer.explanation, isNotNull);
        expect(answer.explanation, isNotEmpty);
      }
    });
  });
}
