import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';
import 'package:tandur/features/kelas/presentation/widgets/lesson_block_widgets.dart';

import '../../fixtures/learning_fixtures.dart';

Widget _bungkus(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('groupLessonBlocks', () {
    test('menggabungkan paragraf ke dalam halaman judulnya', () {
      final lesson = LessonDetail.fromJson(lessonCardJson);
      final pages = groupLessonBlocks(lesson.blocks);

      // Materi C1 unit 1: HEADING, PARAGRAPH, PARAGRAPH, CALLOUT, CALLOUT.
      expect(pages, hasLength(3));
      expect(pages[0].map((b) => b.type), [
        LessonBlockType.heading,
        LessonBlockType.paragraph,
        LessonBlockType.paragraph,
      ]);
      expect(pages[1].single.type, LessonBlockType.callout);
      expect(pages[2].single.type, LessonBlockType.callout);
    });

    test('dua kotak sorotan berurutan tidak digabung', () {
      final pages = groupLessonBlocks(const [
        LessonBlock(type: LessonBlockType.callout, title: 'A', text: 'a'),
        LessonBlock(type: LessonBlockType.callout, title: 'B', text: 'b'),
      ]);

      expect(pages, hasLength(2));
    });

    test('blok tanpa teks diabaikan', () {
      final pages = groupLessonBlocks(const [
        LessonBlock(type: LessonBlockType.paragraph, text: '  '),
        LessonBlock(type: LessonBlockType.paragraph),
      ]);

      expect(pages, isEmpty);
    });

    test('daftar blok kosong menghasilkan nol halaman', () {
      expect(groupLessonBlocks(const []), isEmpty);
    });
  });

  group('LessonBlockView', () {
    testWidgets('kotak sorotan menampilkan judul dan isinya', (tester) async {
      await tester.pumpWidget(
        _bungkus(
          const LessonBlockView(
            block: LessonBlock(
              type: LessonBlockType.callout,
              variant: 'MISTAKE',
              title: 'Sering keliru',
              text: 'Menanam 200 polybag di percobaan pertama.',
            ),
          ),
        ),
      );

      // Judul kotak sorotan sebelumnya hilang sama sekali karena semua blok
      // dirender sebagai teks polos.
      expect(find.text('Sering keliru'), findsOneWidget);
      expect(
        find.text('Menanam 200 polybag di percobaan pertama.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('varian TIP memakai ikon berbeda dari MISTAKE', (tester) async {
      await tester.pumpWidget(
        _bungkus(
          const LessonBlockView(
            block: LessonBlock(
              type: LessonBlockType.callout,
              variant: 'TIP',
              title: 'Ukur dulu tempatnya',
              text: 'Polybag butuh sinar matahari langsung minimal 6 jam.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('judul dan paragraf memakai gaya teks yang berbeda', (
      tester,
    ) async {
      await tester.pumpWidget(
        _bungkus(
          const Column(
            children: [
              LessonBlockView(
                block: LessonBlock(
                  type: LessonBlockType.heading,
                  text: 'Kenapa 30 polybag sudah cukup',
                ),
              ),
              LessonBlockView(
                block: LessonBlock(
                  type: LessonBlockType.paragraph,
                  text: 'Tiga puluh polybag cabai rawit butuh lahan 3 x 4 m.',
                ),
              ),
            ],
          ),
        ),
      );

      final heading = tester.widget<Text>(
        find.text('Kenapa 30 polybag sudah cukup'),
      );
      final paragraph = tester.widget<Text>(
        find.text('Tiga puluh polybag cabai rawit butuh lahan 3 x 4 m.'),
      );

      expect(heading.style!.fontSize, isNot(paragraph.style!.fontSize));
      expect(heading.style!.fontSize, greaterThan(paragraph.style!.fontSize!));
    });

    testWidgets('tipe tak dikenal tetap dirender sebagai paragraf', (
      tester,
    ) async {
      await tester.pumpWidget(
        _bungkus(
          const LessonBlockView(
            block: LessonBlock(
              type: LessonBlockType.unknown,
              text: 'Blok masa depan dari backend.',
            ),
          ),
        ),
      );

      expect(find.text('Blok masa depan dari backend.'), findsOneWidget);
    });
  });

  group('LessonSourceFooter', () {
    testWidgets('menampilkan sumber, peninjau, dan atribusi', (tester) async {
      await tester.pumpWidget(
        _bungkus(
          const LessonSourceFooter(
            sourceReference: 'Balitsa, Petunjuk Teknis Budidaya Cabai Rawit',
            reviewedBy: 'Tim Kurikulum Tandur',
            attribution: 'Sumber: ook tani 93 (YouTube)',
          ),
        ),
      );

      expect(find.text('Sumber: ook tani 93 (YouTube)'), findsOneWidget);
      expect(
        find.text('Sumber: Balitsa, Petunjuk Teknis Budidaya Cabai Rawit'),
        findsOneWidget,
      );
      expect(find.text('Ditinjau oleh: Tim Kurikulum Tandur'), findsOneWidget);
    });

    testWidgets('tanpa data apa pun tidak memakan ruang', (tester) async {
      await tester.pumpWidget(_bungkus(const LessonSourceFooter()));
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });
  });
}
