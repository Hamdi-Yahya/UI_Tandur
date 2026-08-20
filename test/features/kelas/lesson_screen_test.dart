import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';
import 'package:tandur/features/kelas/presentation/screens/lesson_screen.dart';

import '../../fixtures/learning_fixtures.dart';
import '../../support/fake_learning_repository.dart';

/// Layar kecil yang realistis untuk memastikan materi panjang tidak meluber.
const Size _layarKecil = Size(320, 568);

void main() {
  group('LessonCardScreen', () {
    testWidgets('kartu pertama memuat judul dan kedua paragrafnya', (
      tester,
    ) async {
      final lesson = LessonDetail.fromJson(lessonCardJson);
      await tester.pumpWidget(
        MaterialApp(
          home: LessonCardScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
          ),
        ),
      );

      expect(find.text('Kenapa 30 polybag sudah cukup'), findsOneWidget);
      expect(
        find.textContaining('Tiga puluh polybag cabai rawit'),
        findsOneWidget,
      );
      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);
    });

    testWidgets('tombol Lanjut membawa ke kotak sorotan berikutnya', (
      tester,
    ) async {
      final lesson = LessonDetail.fromJson(lessonCardJson);
      await tester.pumpWidget(
        MaterialApp(
          home: LessonCardScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
          ),
        ),
      );

      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('Ukur dulu tempatnya'), findsOneWidget);
      expect(find.text('Kembali'), findsOneWidget);
    });

    testWidgets('kartu terakhir menampilkan sumber dan tombol selesai', (
      tester,
    ) async {
      final lesson = LessonDetail.fromJson(lessonCardJson);
      await tester.pumpWidget(
        MaterialApp(
          home: LessonCardScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
          ),
        ),
      );

      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('3/3'), findsOneWidget);
      expect(find.text('Sering keliru'), findsOneWidget);
      expect(
        find.text('Sumber: Balitsa, Petunjuk Teknis Budidaya Cabai Rawit'),
        findsOneWidget,
      );
      expect(find.text('Selesai Belajar'), findsOneWidget);
    });

    testWidgets('materi panjang tidak meluber di layar 320x568', (
      tester,
    ) async {
      tester.view.physicalSize = _layarKecil;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final lesson = LessonDetail.fromJson(lessonCardJson);
      await tester.pumpWidget(
        MaterialApp(
          home: LessonCardScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tidak ada RenderFlex overflow: isi kartu digulir, bukan dipaksa muat.
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('materi tanpa blok langsung menawarkan tombol selesai', (
      tester,
    ) async {
      const lesson = LessonDetail(
        lessonId: 'kosong',
        type: LessonType.card,
        title: 'Materi tanpa blok',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: LessonCardScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
          ),
        ),
      );

      expect(find.text('Selesai Belajar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LessonVideoScreen', () {
    testWidgets('menampilkan atribusi kanal walau tanpa transkrip', (
      tester,
    ) async {
      final lesson = LessonDetail.fromJson(lessonVideoJson);
      expect(lesson.transcript, isNull);

      await tester.pumpWidget(
        MaterialApp(
          home: LessonVideoScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
            launcher: (_) async => true,
          ),
        ),
      );

      expect(find.text('Sumber: ook tani 93 (YouTube)'), findsOneWidget);
      expect(find.text('Tonton di YouTube'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('menyebut video tidak ikut terunduh untuk mode offline', (
      tester,
    ) async {
      final lesson = LessonDetail.fromJson(lessonVideoJson);
      await tester.pumpWidget(
        MaterialApp(
          home: LessonVideoScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
            launcher: (_) async => true,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('tombol tonton membuka URL YouTube dari youtubeVideoId', (
      tester,
    ) async {
      final lesson = LessonDetail.fromJson(lessonVideoJson);
      final dibuka = <Uri>[];

      await tester.pumpWidget(
        MaterialApp(
          home: LessonVideoScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
            launcher: (url) async {
              dibuka.add(url);
              return true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Tonton di YouTube'));
      await tester.pump();

      expect(dibuka, hasLength(1));
      expect(
        dibuka.single.toString(),
        'https://www.youtube.com/watch?v=${lesson.youtubeVideoId}',
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('video tanpa sumber apa pun tidak menawarkan tombol tonton', (
      tester,
    ) async {
      const lesson = LessonDetail(
        lessonId: 'tanpa-sumber',
        type: LessonType.video,
        title: 'Video belum diisi',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LessonVideoScreen(
            lesson: lesson,
            repository: FakeLearningRepository(),
            launcher: (_) async => true,
          ),
        ),
      );

      expect(find.text('Tonton di YouTube'), findsNothing);
      expect(find.text('Buka video'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
