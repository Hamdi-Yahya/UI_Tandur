import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';
import 'package:tandur/features/kelas/presentation/widgets/kelas_widgets.dart';

Widget _layar(LessonSummary lesson) {
  return MaterialApp(
    home: Scaffold(
      body: LessonCard(lesson: lesson, onTap: () {}),
    ),
  );
}

void main() {
  group('LessonCard', () {
    testWidgets('latihan memakai ikon berbeda dari materi bacaan', (
      tester,
    ) async {
      await tester.pumpWidget(
        _layar(
          const LessonSummary(
            id: '1',
            title: 'Latihan · Mengenal cabai rawit',
            type: LessonType.latihan,
            duration: '3 menit',
            status: LessonStatus.available,
            xpReward: 25,
          ),
        ),
      );

      expect(find.byIcon(Icons.edit_note), findsOneWidget);
      expect(find.byIcon(Icons.view_carousel), findsNothing);
    });

    testWidgets('materi kartu dan video punya ikon masing-masing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _layar(
          const LessonSummary(
            id: '1',
            title: 'Mulai dari 30 polybag',
            type: LessonType.kartu,
            duration: '4 menit',
            status: LessonStatus.available,
          ),
        ),
      );
      expect(find.byIcon(Icons.view_carousel), findsOneWidget);

      await tester.pumpWidget(
        _layar(
          const LessonSummary(
            id: '2',
            title: 'Menonton satu siklus penuh',
            type: LessonType.video,
            duration: '11 menit',
            status: LessonStatus.available,
          ),
        ),
      );
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
    });

    testWidgets('XP ditampilkan bila tersedia', (tester) async {
      await tester.pumpWidget(
        _layar(
          const LessonSummary(
            id: '1',
            title: 'Latihan',
            type: LessonType.latihan,
            duration: '3 menit',
            status: LessonStatus.available,
            xpReward: 25,
          ),
        ),
      );

      expect(find.text('+25 XP'), findsOneWidget);
      expect(find.text('3 menit'), findsOneWidget);
    });

    testWidgets('XP nol tidak ditampilkan', (tester) async {
      await tester.pumpWidget(
        _layar(
          const LessonSummary(
            id: '1',
            title: 'Materi',
            type: LessonType.kartu,
            duration: '4 menit',
            status: LessonStatus.available,
          ),
        ),
      );

      expect(find.textContaining('XP'), findsNothing);
    });

    testWidgets('materi terkunci menampilkan gembok', (tester) async {
      await tester.pumpWidget(
        _layar(
          const LessonSummary(
            id: '1',
            title: 'Materi terkunci',
            type: LessonType.kartu,
            duration: '4 menit',
            status: LessonStatus.locked,
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
