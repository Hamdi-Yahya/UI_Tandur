import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';
import 'package:tandur/features/kelas/presentation/screens/unit_detail_screen.dart';

import '../../fixtures/learning_fixtures.dart';
import '../../support/fake_learning_repository.dart';

Future<void> _pumpUnit(WidgetTester tester, UnitLessons unit) async {
  final repo = FakeLearningRepository()..unitLessons = unit;
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const UnitDetailScreen(id: 'unit-uji'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [learningRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('UnitDetailScreen', () {
    testWidgets('menampilkan seluruh materi unit dari kurikulum', (
      tester,
    ) async {
      await _pumpUnit(tester, UnitLessons.fromJson(unitLessonsJson));

      expect(
        find.text('Mulai dari 30 polybag, bukan dari sawah'),
        findsOneWidget,
      );
      expect(find.text('Latihan · Mengenal cabai rawit'), findsOneWidget);
      expect(find.text('0% materi terselesaikan'), findsOneWidget);
    });

    testWidgets('latihan dikenali sebagai latihan, bukan materi bacaan', (
      tester,
    ) async {
      await _pumpUnit(tester, UnitLessons.fromJson(unitLessonsJson));

      // Bergantung pada LessonType.exerciseMcq yang terbaca benar dari
      // EXERCISE_MCQ. Sebelum perbaikan enum, latihan jatuh ke `unknown`
      // sehingga tampil dan diarahkan sebagai materi kartu biasa.
      expect(find.byIcon(Icons.edit_note), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);
    });

    testWidgets('unit tanpa ujian tidak menampilkan kartu ujian terkunci', (
      tester,
    ) async {
      final unit = UnitLessons.fromJson(unitLessonsJson);
      expect(unit.quiz, isNull);

      await _pumpUnit(tester, unit);

      expect(find.text('Ujian Pemahaman Unit'), findsNothing);
      expect(find.text('Selesaikan semua materi untuk membuka.'), findsNothing);
    });

    testWidgets('unit dengan ujian menampilkan kartunya', (tester) async {
      final dasar = UnitLessons.fromJson(unitLessonsJson);
      final unit = UnitLessons(
        unitId: dasar.unitId,
        title: dasar.title,
        progressPercent: dasar.progressPercent,
        lessons: dasar.lessons,
        quiz: const UnitQuizSummary(
          quizId: 'quiz-1',
          questionCount: 5,
          passThreshold: 70,
          status: NodeStatus.available,
        ),
      );

      await _pumpUnit(tester, unit);

      expect(find.text('Ujian Pemahaman Unit'), findsOneWidget);
      expect(find.text('Siap dikerjakan'), findsOneWidget);
    });
  });
}
