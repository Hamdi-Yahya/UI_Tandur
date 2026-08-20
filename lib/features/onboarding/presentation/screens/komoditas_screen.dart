import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:tandur/features/onboarding/data/onboarding_repository.dart';

/// Screen 5 — Pilih Komoditas.
/// Multi-select, minimal 1, CTA disabled sampai ada pilihan.
/// Daftar komoditas diambil dari GET /api/onboarding.
/// Referensi: DESAIN.md sketsa komoditas, PRD.md US-00.
class KomoditasScreen extends ConsumerStatefulWidget {
  const KomoditasScreen({super.key});

  @override
  ConsumerState<KomoditasScreen> createState() => _KomoditasScreenState();
}

class _KomoditasScreenState extends ConsumerState<KomoditasScreen> {
  final Set<String> _selected = {};
  List<OnboardingCommodity> _komoditas = const [];
  bool _isLoading = true;
  String? _error;
  bool _isNavigating = false;

  static const List<OnboardingCommodity> _defaultKomoditas = [
    OnboardingCommodity(
      commodity: Commodity.cabai,
      name: 'Cabai Rawit',
      cycleDays: 90,
      minUnit: '10 polybag',
    ),
    OnboardingCommodity(
      commodity: Commodity.terong,
      name: 'Terong Ungu',
      cycleDays: 75,
      minUnit: '5 polybag',
    ),
    OnboardingCommodity(
      commodity: Commodity.padi,
      name: 'Padi Sawah',
      cycleDays: 115,
      minUnit: '1 petak',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadKomoditas();
  }

  /// Ambil daftar komoditas dari API. Gagal → fallback ke komoditas bawaan.
  Future<void> _loadKomoditas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final content = await ref.read(onboardingRepositoryProvider).getContent();
      if (!mounted) return;
      setState(() {
        _komoditas = content.commodities.isNotEmpty
            ? content.commodities
            : _defaultKomoditas;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _komoditas = _defaultKomoditas;
        _isLoading = false;
        _error = null;
      });
    }
  }

  /// Warna aksen dan ikon placeholder per komoditas. Komoditas baru dari
  /// backend tetap tampil memakai warna daun.
  (Color, Color, IconData) _gayaKomoditas(Commodity commodity) {
    switch (commodity) {
      case Commodity.cabai:
        return (
          AppColors.cabai,
          AppColors.cabaiSamar,
          Icons.local_fire_department_outlined,
        );
      case Commodity.terong:
        return (AppColors.terong, AppColors.terongSamar, Icons.spa_outlined);
      case Commodity.padi:
        return (AppColors.padi, AppColors.padiSamar, Icons.grass_outlined);
      case Commodity.unknown:
        return (AppColors.daun, AppColors.daunSamar, Icons.eco_outlined);
    }
  }

  /// Toggle pilihan komoditas.
  void _togglePilihan(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  /// Lanjut ke screen pengalaman dengan membawa pilihan.
  void _lanjut() {
    if (_selected.isEmpty || _isNavigating) return;
    setState(() => _isNavigating = true);
    // Jeda singkat supaya umpan balik haptic terasa sebelum navigasi
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isNavigating = false);
        context.go(
          '/onboarding/pengalaman',
          extra: {'commodities': _selected.toList()},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Column(
          children: [
            // Header: tombol kembali dan tombol Masuk
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.tanah,
                    onPressed: () => context.go('/onboarding'),
                    tooltip: 'Kembali',
                    iconSize: 24,
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                  Semantics(
                    label: 'Masuk ke akun yang sudah ada',
                    child: TextButton(
                      onPressed: () => context.go('/masuk'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        foregroundColor: AppColors.daun,
                      ),
                      child: Text(
                        'Masuk',
                        style: AppTypography.isiTebal.copyWith(
                          color: AppColors.daun,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null && _komoditas.isEmpty)
                      ? _ErrorState(message: _error!, onRetry: _loadKomoditas)
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.xxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Judul
                              Text(
                                'Mau mulai dari mana?',
                                style: AppTypography.tampilanSedang.copyWith(
                                  color: AppColors.tanah,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              Text(
                                'Bisa pilih lebih dari satu.',
                                style: AppTypography.isiBesar.copyWith(
                                  color: AppColors.tanahLemah,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Grid 2 kolom komoditas
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: AppSpacing.m,
                                  mainAxisSpacing: AppSpacing.m,
                                  childAspectRatio: 0.9,
                                ),
                                itemCount: _komoditas.length,
                                itemBuilder: (context, index) {
                                  final item = _komoditas[index];
                                  final (aksenWarna, aksenLemah, ikonTemp) =
                                      _gayaKomoditas(item.commodity);
                                  final key = item.commodity.apiValue;
                                  final bool isSelected = _selected.contains(key);
                                  return _KomoditasCard(
                                    item: item,
                                    aksenWarna: aksenWarna,
                                    aksenLemah: aksenLemah,
                                    ikonTemp: ikonTemp,
                                    isSelected: isSelected,
                                    onTap: () => _togglePilihan(key),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              // CTA
                              PrimaryButton(
                                label: 'Lanjut',
                                onPressed:
                                    _selected.isNotEmpty && _komoditas.isNotEmpty
                                        ? _lanjut
                                        : null,
                                isLoading: _isNavigating,
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

/// Keadaan gagal memuat daftar komoditas — pesan + tombol coba lagi.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.tanahSamar),
            const SizedBox(height: AppSpacing.m),
            Text(
              message,
              style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),
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

/// Kartu komoditas — selected state sesuai DESAIN.md:
/// border daun 2dp, background daunSamar.
class _KomoditasCard extends StatelessWidget {
  final OnboardingCommodity item;
  final Color aksenWarna;
  final Color aksenLemah;
  final IconData ikonTemp;
  final bool isSelected;
  final VoidCallback onTap;

  const _KomoditasCard({
    required this.item,
    required this.aksenWarna,
    required this.aksenLemah,
    required this.ikonTemp,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String durasi = item.cycleDays != null ? '${item.cycleDays} hari' : '—';
    final String lahanMin = item.minUnit ?? '—';

    return Semantics(
      label: '${item.name}, $durasi, $lahanMin',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.daunSamar : AppColors.kertas,
            borderRadius: BorderRadius.circular(AppRadius.sedang),
            border: Border.all(
              color: isSelected ? AppColors.daun : AppColors.garis,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikon placeholder (diganti SVG aset saat tersedia)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: aksenLemah,
                    borderRadius: BorderRadius.circular(AppRadius.kecil),
                  ),
                  child: Icon(
                    ikonTemp,
                    color: aksenWarna,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  item.name,
                  style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  durasi,
                  style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                ),
                Text(
                  lahanMin,
                  style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
