import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_motion.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/onboarding/data/onboarding_repository.dart';
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
class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;

  /// Data halaman perkenalan. Diisi dari API; kalau gagal, dipakai
  /// [OnboardingPageData.defaultPages] agar aplikasi tetap terbuka.
  List<OnboardingPageData> _pages = OnboardingPageData.defaultPages;

  /// Warna latar ilustrasi, mengikuti urutan warna komoditas DESAIN.md.
  static const List<Color> _warnaIlustrasi = [
    AppColors.daunSamar,
    AppColors.padiSamar,
    AppColors.cabaiSamar,
    AppColors.terongSamar,
  ];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Ambil slide dari GET /api/onboarding. Gagal (backend mati / offline)
  /// → jatuh balik ke konstanta lokal agar alur onboarding tetap jalan.
  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final content = await ref.read(onboardingRepositoryProvider).getContent();
      if (!mounted) return;
      setState(() {
        _pages = _mapSlides(content.slides);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      _fallbackToLocal(e.message);
    } catch (_) {
      _fallbackToLocal('Terjadi galat. Menampilkan konten bawaan.');
    }
  }

  void _fallbackToLocal(String? message) {
    if (!mounted) return;
    setState(() {
      _pages = OnboardingPageData.defaultPages;
      _isLoading = false;
      _error = message;
    });
  }

  /// Konversi slide API ke [OnboardingPageData] yang dipakai widget
  /// perkenalan. Daftar kosong dianggap gagal → konstanta lokal.
  List<OnboardingPageData> _mapSlides(List<OnboardingSlide> slides) {
    if (slides.isEmpty) return OnboardingPageData.defaultPages;
    return [
      for (var i = 0; i < slides.length; i++)
        OnboardingPageData(
          title: slides[i].title,
          subtitle: slides[i].body,
          illustrationLabel: slides[i].title,
          illustrationColor: _warnaIlustrasi[i % _warnaIlustrasi.length],
          imagePath: slides[i].illustration,
        ),
    ];
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.embun,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Hormati reduce motion: jika aktif, gunakan transisi lesap bukan slide
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Column(
          children: [
            // Gagal ambil konten API: tetap tampil, tapi beri tahu + coba lagi.
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.s,
                  AppSpacing.l,
                  0,
                ),
                child: _ErrorBanner(message: _error!, onRetry: _loadContent),
              ),
            Expanded(
              child: PageView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner peringatan saat konten API gagal dimuat, dengan tombol coba lagi.
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.cabaiSamar,
          borderRadius: BorderRadius.circular(AppRadius.kecil),
          border: Border.all(color: AppColors.cabai.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.cabai, size: 16),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                message,
                style: AppTypography.kecil.copyWith(color: AppColors.cabai),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
