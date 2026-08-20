import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/core/network/app_enums.dart';

/// Enum backend TANDUR memakai SCREAMING_SNAKE_CASE (lihat prisma/schema.prisma).
/// Sebelumnya pemetaan hanya melakukan `name.toUpperCase()`, sehingga setiap
/// anggota yang namanya lebih dari satu kata tidak pernah cocok: `EXERCISE_MCQ`,
/// `IN_PROGRESS`, `SELF_HOSTED`, `LOW_CONFIDENCE`, dan seterusnya semuanya
/// diam-diam menjadi `unknown`.
void main() {
  group('enumApiValue', () {
    test('satu kata tetap apa adanya', () {
      expect(enumApiValue('cabai'), 'CABAI');
      expect(enumApiValue('embed'), 'EMBED');
    });

    test('camelCase menjadi SCREAMING_SNAKE_CASE', () {
      expect(enumApiValue('exerciseMcq'), 'EXERCISE_MCQ');
      expect(enumApiValue('inProgress'), 'IN_PROGRESS');
      expect(enumApiValue('selfHosted'), 'SELF_HOSTED');
      expect(enumApiValue('lowConfidence'), 'LOW_CONFIDENCE');
      expect(enumApiValue('meterPersegi'), 'METER_PERSEGI');
      expect(enumApiValue('offTopic'), 'OFF_TOPIC');
      expect(enumApiValue('notALeaf'), 'NOT_A_LEAF');
      expect(enumApiValue('bestAnswerMarked'), 'BEST_ANSWER_MARKED');
      expect(enumApiValue('finalTestPassed'), 'FINAL_TEST_PASSED');
    });
  });

  group('LessonType', () {
    test('membaca seluruh nilai dari backend', () {
      expect(LessonTypeX.fromApi('CARD'), LessonType.card);
      expect(LessonTypeX.fromApi('VIDEO'), LessonType.video);
      expect(LessonTypeX.fromApi('EXERCISE_MCQ'), LessonType.exerciseMcq);
      expect(LessonTypeX.fromApi('EXERCISE_MATCH'), LessonType.exerciseMatch);
      expect(LessonTypeX.fromApi('EXERCISE_ORDER'), LessonType.exerciseOrder);
      expect(LessonTypeX.fromApi('EXERCISE_IMAGE'), LessonType.exerciseImage);
    });

    test('nilai tak dikenal dan null jatuh ke unknown', () {
      expect(LessonTypeX.fromApi('SESUATU_YANG_BARU'), LessonType.unknown);
      expect(LessonTypeX.fromApi(null), LessonType.unknown);
    });

    test('apiValue bolak-balik konsisten', () {
      for (final type in LessonType.values) {
        expect(LessonTypeX.fromApi(type.apiValue), type);
      }
    });
  });

  group('NodeStatus', () {
    test('IN_PROGRESS tidak lagi dianggap unknown', () {
      expect(NodeStatusX.fromApi('IN_PROGRESS'), NodeStatus.inProgress);
      expect(NodeStatusX.fromApi('LOCKED'), NodeStatus.locked);
      expect(NodeStatusX.fromApi('AVAILABLE'), NodeStatus.available);
      expect(NodeStatusX.fromApi('COMPLETED'), NodeStatus.completed);
      expect(NodeStatusX.fromApi('PERFECT'), NodeStatus.perfect);
    });
  });

  group('VideoKind', () {
    test('SELF_HOSTED dan EMBED terbaca', () {
      expect(VideoKindX.fromApi('SELF_HOSTED'), VideoKind.selfHosted);
      expect(VideoKindX.fromApi('EMBED'), VideoKind.embed);
    });
  });

  group('bolak-balik untuk seluruh enum berkata jamak', () {
    test('ScanStatus', () {
      for (final v in ScanStatus.values) {
        expect(ScanStatusX.fromApi(v.apiValue), v);
      }
      expect(ScanStatusX.fromApi('LOW_CONFIDENCE'), ScanStatus.lowConfidence);
    });

    test('UnitType', () {
      for (final v in UnitType.values) {
        expect(UnitTypeX.fromApi(v.apiValue), v);
      }
      expect(UnitTypeX.fromApi('METER_PERSEGI'), UnitType.meterPersegi);
    });

    test('NotificationType', () {
      for (final v in NotificationType.values) {
        expect(NotificationTypeX.fromApi(v.apiValue), v);
      }
      expect(
        NotificationTypeX.fromApi('REPLY_RECEIVED'),
        NotificationType.replyReceived,
      );
    });

    test('XpReason', () {
      for (final v in XpReason.values) {
        expect(XpReasonX.fromApi(v.apiValue), v);
      }
      expect(XpReasonX.fromApi('LESSON_COMPLETED'), XpReason.lessonCompleted);
    });

    test('ScanFlagReason', () {
      for (final v in ScanFlagReason.values) {
        expect(ScanFlagReasonX.fromApi(v.apiValue), v);
      }
      expect(ScanFlagReasonX.fromApi('NOT_A_LEAF'), ScanFlagReason.notALeaf);
    });

    test('ReportReason', () {
      for (final v in ReportReason.values) {
        expect(ReportReasonX.fromApi(v.apiValue), v);
      }
      expect(ReportReasonX.fromApi('OFF_TOPIC'), ReportReason.offTopic);
    });
  });
}
