import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_theme.dart';

/// Uji dasar tema dan komponen bersama.
///
/// Berkas ini sebelumnya berisi "Counter increments smoke test" bawaan
/// `flutter create`: mencari teks '0' lalu menekan ikon `+` yang tidak pernah
/// ada di TANDUR. Akibatnya satu-satunya tes di proyek ini selalu gagal.
void main() {
  group('AppTheme', () {
    test('memakai Material 3 dan latar embun', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, AppColors.embun);
    });
  });

  group('KeadaanGalat', () {
    testWidgets('menampilkan pesan galat dan tombol coba lagi', (tester) async {
      var dicoba = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: KeadaanGalat(
              message: 'Lesson terkunci. Selesaikan lesson sebelumnya dulu.',
              onRetry: () => dicoba++,
            ),
          ),
        ),
      );

      expect(
        find.text('Lesson terkunci. Selesaikan lesson sebelumnya dulu.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      expect(dicoba, 1);
    });
  });

  group('KeadaanKosong', () {
    testWidgets('menampilkan pesan dan aksi lanjutan', (tester) async {
      var ditekan = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: KeadaanKosong(
              icon: Icons.eco_outlined,
              message: 'Belum ada tanaman.',
              actionLabel: 'Tambah Tanaman',
              onAction: () => ditekan++,
            ),
          ),
        ),
      );

      expect(find.text('Belum ada tanaman.'), findsOneWidget);
      await tester.tap(find.text('Tambah Tanaman'));
      await tester.pump();
      expect(ditekan, 1);
    });
  });
}
