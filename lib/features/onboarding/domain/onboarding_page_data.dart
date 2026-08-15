import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';

/// Model data untuk setiap halaman perkenalan.
/// Copy dan ilustrasi berdasarkan DESAIN.md bagian 4.1.
class OnboardingPageData {
  final String title;
  final String subtitle;
  final String illustrationLabel;
  final Color illustrationColor;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.illustrationLabel,
    required this.illustrationColor,
  });

  /// Empat halaman perkenalan sesuai tabel di DESAIN.md 4.1.
  static const List<OnboardingPageData> defaultPages = [
    OnboardingPageData(
      title: 'Mulai dari\npekarangan sendiri.',
      subtitle: 'Tiga puluh polybag cabai cukup untuk mulai. Tidak perlu sawah.',
      illustrationLabel: 'Pekarangan dan polybag cabai',
      illustrationColor: AppColors.daunSamar,
    ),
    OnboardingPageData(
      title: 'Belajar sambil\nmenanam.',
      subtitle: 'Kelas Tandur mengajarkan cara bertani langkah demi langkah, dari benih sampai panen.',
      illustrationLabel: 'Peta terasering kelas Tandur',
      illustrationColor: AppColors.padiSamar,
    ),
    OnboardingPageData(
      title: 'Daunnya kenapa?\nFoto saja.',
      subtitle: 'Ambil foto daun, tahu kondisi tanamanmu dalam hitungan detik, tanpa perlu penyuluh.',
      illustrationLabel: 'Ponsel mengarah ke daun bercak',
      illustrationColor: AppColors.cabaiSamar,
    ),
    OnboardingPageData(
      title: 'Ada yang lebih dulu\nmengalami.',
      subtitle: 'Warung Tani: petani lain sudah tanya, sudah dapat jawaban. Cari, atau tanya langsung.',
      illustrationLabel: 'Ilustrasi percakapan Warung Tani',
      illustrationColor: AppColors.terongSamar,
    ),
  ];
}
