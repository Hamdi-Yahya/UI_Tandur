import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_client.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:tandur/features/onboarding/data/onboarding_repository.dart';

/// Screen 6 — Pertanyaan Pengalaman.
/// Menanyakan apakah pengguna sudah atau belum pernah menanam.
/// Saat selesai, preferensi dikirim ke POST /api/onboarding/complete dan
/// pengguna diarahkan ke `startRoute` dari respons backend.
/// Referensi: PRD.md US-00.
class PengalamanScreen extends ConsumerStatefulWidget {
  final List<String> selectedCommodities;

  const PengalamanScreen({super.key, required this.selectedCommodities});

  @override
  ConsumerState<PengalamanScreen> createState() => _PengalamanScreenState();
}

class _PengalamanScreenState extends ConsumerState<PengalamanScreen> {
  String? _pilihan; // 'belum' | 'sudah'
  bool _isSubmitting = false;

  void _pilih(String value) {
    HapticFeedback.selectionClick();
    setState(() => _pilihan = value);
  }

  Future<void> _lanjut() async {
    if (_pilihan == null || _isSubmitting) return;
    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    try {
      final token = await ref.read(secureTokenStoreProvider).accessToken();

      // Jika belum login/daftar, bawa preferensi ke halaman Daftar
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        context.go('/daftar', extra: {
          'commodities': widget.selectedCommodities,
          'hasFarmed': _pilihan == 'sudah',
        });
        return;
      }

      final result = await ref
          .read(onboardingRepositoryProvider)
          .completeOnboarding(
            commodities: widget.selectedCommodities,
            hasFarmed: _pilihan == 'sudah',
          );
      if (!mounted) return;
      context.go(_routeTujuan(result.startRoute));
    } on ApiException catch (e) {
      if (!mounted) return;
      // Jika token tidak valid / kedaluwarsa (401), arahkan ke Daftar
      if (e.statusCode == 401 || e.message.toLowerCase().contains('token')) {
        context.go('/daftar', extra: {
          'commodities': widget.selectedCommodities,
          'hasFarmed': _pilihan == 'sudah',
        });
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      context.go('/daftar', extra: {
        'commodities': widget.selectedCommodities,
        'hasFarmed': _pilihan == 'sudah',
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Peta `startRoute` dari backend ke route yang dikenal aplikasi.
  /// Route tidak dikenal dianggap kosong → fallback ke Kelas.
  String _routeTujuan(String startRoute) {
    switch (startRoute) {
      case '/kelas':
      case '/periksa':
      case '/periksa/tanaman':
      case '/warung':
      case '/saya':
        return startRoute;
      default:
        return '/kelas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol kembali
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.tanah,
                  onPressed: () => context.go('/onboarding/komoditas'),
                  tooltip: 'Kembali',
                  iconSize: 24,
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sudah pernah menanam?',
                      style: AppTypography.tampilanSedang.copyWith(
                        color: AppColors.tanah,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Jawabanmu menentukan dari mana kamu mulai — tidak mengunci apa pun.',
                      style: AppTypography.isiBesar.copyWith(
                        color: AppColors.tanahLemah,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Pilihan: Belum pernah
                    _PengalamanCard(
                      title: 'Belum pernah',
                      subtitle: 'Mulai dari dasar — pemilihan benih sampai panen.',
                      value: 'belum',
                      selected: _pilihan == 'belum',
                      onTap: () => _pilih('belum'),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Pilihan: Sudah pernah
                    _PengalamanCard(
                      title: 'Sudah pernah',
                      subtitle: 'Daftarkan tanaman yang sudah berjalan untuk dipantau.',
                      value: 'sudah',
                      selected: _pilihan == 'sudah',
                      onTap: () => _pilih('sudah'),
                    ),

                    const Spacer(),

                    // CTA — hanya aktif setelah memilih
                    PrimaryButton(
                      label: 'Mulai',
                      onPressed: _pilihan != null ? _lanjut : null,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu pilihan pengalaman — sama prinsip visual dengan KomoditasCard:
/// selected = border daun 2dp, latar daunSamar.
class _PengalamanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _PengalamanCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $subtitle',
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: selected ? AppColors.daunSamar : AppColors.kertas,
            borderRadius: BorderRadius.circular(AppRadius.sedang),
            border: Border.all(
              color: selected ? AppColors.daun : AppColors.garis,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Indikator pilihan
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.daun : AppColors.kertas,
                  border: Border.all(
                    color: selected ? AppColors.daun : AppColors.garis,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, color: AppColors.kertas, size: 14)
                    : null,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
