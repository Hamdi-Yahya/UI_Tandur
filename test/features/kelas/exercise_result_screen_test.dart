import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';
import 'package:tandur/features/kelas/presentation/screens/exercise_result_screen.dart';

import '../../fixtures/learning_fixtures.dart';

Widget _layar(ExerciseResult hasil) {
  return MaterialApp(
    home: ExerciseResultScreen(
      id: 'lesson-latihan',
      correctCount: hasil.correctCount,
      total: hasil.totalCount,
      scorePercent: hasil.score,
      xpEarned: hasil.xpEarned,
      results: hasil.results,
    ),
  );
}

void main() {
  group('ExerciseResultScreen', () {
    testWidgets('menyebut jumlah benar, bukan angka persen', (tester) async {
      // Backend mengirim score=67 untuk 2 dari 3 benar. Versi lama memakai
      // score sebagai jumlah benar sehingga tertulis "67 dari 3 pertanyaan"
      // dan dianggap tidak lulus (67/3 = 22%).
      const hasil = ExerciseResult(
        score: 67,
        correctCount: 2,
        totalCount: 3,
        xpEarned: 25,
        results: [],
      );

      await tester.pumpWidget(_layar(hasil));

      expect(
        find.text('Kamu menjawab benar 2 dari 3 soal (67%).'),
        findsOneWidget,
      );
      // 67% masih di bawah ambang 70%, jadi statusnya belum lulus. Versi lama
      // menghitung 67/3 = 22% sehingga angkanya juga salah.
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('nilai di bawah 70 persen dianggap belum lulus', (
      tester,
    ) async {
      const hasil = ExerciseResult(
        score: 33,
        correctCount: 1,
        totalCount: 3,
        xpEarned: 8,
        results: [],
      );

      await tester.pumpWidget(_layar(hasil));

      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.text('Ulangi Latihan'), findsOneWidget);
    });

    testWidgets('XP yang ditampilkan berasal dari backend', (tester) async {
      const hasil = ExerciseResult(
        score: 100,
        correctCount: 3,
        totalCount: 3,
        xpEarned: 38,
        results: [],
      );

      await tester.pumpWidget(_layar(hasil));

      // Sebelumnya nilai ini dikeraskan menjadi "+20 XP".
      expect(find.text('+38 XP'), findsOneWidget);
      expect(find.text('+20 XP'), findsNothing);
    });

    testWidgets('tanpa XP, lencana XP tidak ditampilkan', (tester) async {
      const hasil = ExerciseResult(
        score: 0,
        correctCount: 0,
        totalCount: 3,
        xpEarned: 0,
        results: [],
      );

      await tester.pumpWidget(_layar(hasil));

      expect(find.textContaining('XP'), findsNothing);
    });

    testWidgets('pembahasan soal salah ditampilkan lengkap', (tester) async {
      final hasil = ExerciseResult.fromJson(exerciseResultJson);

      await tester.pumpWidget(_layar(hasil));
      await tester.pumpAndSettle();

      expect(find.text('Pembahasan'), findsOneWidget);
      expect(find.text('Jawaban benar: B'), findsOneWidget);
      expect(
        find.textContaining('kecambah muncul di hari ke-5 sampai ke-7'),
        findsOneWidget,
      );
    });

    testWidgets('semua jawaban benar berarti tidak ada pembahasan', (
      tester,
    ) async {
      const hasil = ExerciseResult(
        score: 100,
        correctCount: 2,
        totalCount: 2,
        xpEarned: 30,
        results: [
          ExerciseAnswerResult(
            exerciseId: 'a',
            correct: true,
            correctAnswer: 'A',
          ),
          ExerciseAnswerResult(
            exerciseId: 'b',
            correct: true,
            correctAnswer: 'B',
          ),
        ],
      );

      await tester.pumpWidget(_layar(hasil));

      expect(find.text('Pembahasan'), findsNothing);
    });
  });
}
