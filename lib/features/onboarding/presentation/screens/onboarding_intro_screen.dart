import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_motion.dart';
import 'package:tandur/features/onboarding/domain/onboarding_page_data.dart';
import 'package:tandur/features/onboarding/presentation/widgets/onboarding_widgets.dart';

/// Layar Perkenalan 1–4.
/// Menggunakan PageView agar transisi antar layar konsisten.
/// Setiap halaman berisi:
///   - Tombol Lewati (pojok kanan atas)
///   - Area ilustrasi
///   - Judul (Bricolage Grotesque 26)
///   - Subjudul (Plus Jakarta Sans 16)
///   - Indikator halaman
///   - Tombol Lanjut / Mulai
class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Data untuk empat halaman sesuai DESAIN.md bagian 4.1
  final List<OnboardingPageData> _pages = OnboardingPageData.defaultPages;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Pindah ke halaman berikutnya atau navigasi ke layar pilih komoditas.
  void _onNext() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.perpindahanLayar,
        curve: AppMotion.kurvaPerpindahan,
      );
    } else {
      // Halaman terakhir → ke pilih komoditas
      context.go('/onboarding/komoditas');
    }
  }

  /// Lewati seluruh perkenalan, langsung ke pilih komoditas.
  void _onSkip() {
    HapticFeedback.lightImpact();
    context.go('/onboarding/komoditas');
  }

  @override
  Widget build(BuildContext context) {
    // Hormati reduce motion: jika aktif, gunakan transisi lesap bukan slide
    final bool reduceMotion =
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.embun,
      body: PageView.builder(
        controller: _pageController,
        physics: reduceMotion
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];
          return OnboardingScaffold(
            illustration: OnboardingIllustration(
              imagePath: page.imagePath,
              label: page.illustrationLabel,
              fallbackColor: page.illustrationColor,
            ),
            title: page.title,
            subtitle: page.subtitle,
            currentPage: _currentPage,
            totalPages: _pages.length,
            onNext: _onNext,
            onSkip: _onSkip,
            nextLabel: _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
          );
        },
      ),
    );
  }
}
