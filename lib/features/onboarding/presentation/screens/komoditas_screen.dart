import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';

/// Data model tiap kartu komoditas.
/// Sesuai DESAIN.md dan PRD.md tabel komoditas.
class _KomoditasItem {
  final String key;       // enum: CABAI, TERONG, PADI
  final String nama;
  final String durasi;
  final String lahanMin;
  final Color aksenWarna;
  final Color aksenLemah;
  final IconData ikonTemp; // placeholder hingga aset SVG tersedia

  const _KomoditasItem({
    required this.key,
    required this.nama,
    required this.durasi,
    required this.lahanMin,
    required this.aksenWarna,
    required this.aksenLemah,
    required this.ikonTemp,
  });
}

/// Screen 5 — Pilih Komoditas.
/// Multi-select, minimal 1, CTA disabled sampai ada pilihan.
/// Referensi: DESAIN.md sketsa komoditas, PRD.md US-00.
class KomoditasScreen extends StatefulWidget {
  const KomoditasScreen({super.key});

  @override
  State<KomoditasScreen> createState() => _KomoditasScreenState();
}

class _KomoditasScreenState extends State<KomoditasScreen> {
  final Set<String> _selected = {};
  bool _isLoading = false;

  static const List<_KomoditasItem> _komoditas = [
    _KomoditasItem(
      key: 'CABAI',
      nama: 'Cabai Rawit',
      durasi: '90 hari',
      lahanMin: '30 polybag',
      aksenWarna: AppColors.cabai,
      aksenLemah: AppColors.cabaiSamar,
      ikonTemp: Icons.local_fire_department_outlined,
    ),
    _KomoditasItem(
      key: 'TERONG',
      nama: 'Terong',
      durasi: '100 hari',
      lahanMin: '20 polybag',
      aksenWarna: AppColors.terong,
      aksenLemah: AppColors.terongSamar,
      ikonTemp: Icons.spa_outlined,
    ),
    _KomoditasItem(
      key: 'PADI',
      nama: 'Padi',
      durasi: '110 hari',
      lahanMin: 'Perlu sawah',
      aksenWarna: AppColors.padi,
      aksenLemah: AppColors.padiSamar,
      ikonTemp: Icons.grass_outlined,
    ),
  ];

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
    if (_selected.isEmpty || _isLoading) return;
    setState(() => _isLoading = true);
    // Simulated delay sebelum navigasi
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isLoading = false);
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
            // Header: tombol kembali
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
                  onPressed: () => context.go('/onboarding'),
                  tooltip: 'Kembali',
                  iconSize: 24,
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.m,
                        mainAxisSpacing: AppSpacing.m,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _komoditas.length,
                      itemBuilder: (context, index) {
                        final item = _komoditas[index];
                        final bool isSelected = _selected.contains(item.key);
                        return _KomoditasCard(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => _togglePilihan(item.key),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // CTA
                    PrimaryButton(
                      label: 'Lanjut',
                      onPressed: _selected.isNotEmpty ? _lanjut : null,
                      isLoading: _isLoading,
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

/// Kartu komoditas — selected state sesuai DESAIN.md:
/// border daun 2dp, background daunSamar.
class _KomoditasCard extends StatelessWidget {
  final _KomoditasItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _KomoditasCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.nama}, ${item.durasi}, ${item.lahanMin}',
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
                    color: item.aksenLemah,
                    borderRadius: BorderRadius.circular(AppRadius.kecil),
                  ),
                  child: Icon(
                    item.ikonTemp,
                    color: item.aksenWarna,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  item.nama,
                  style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.durasi,
                  style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                ),
                Text(
                  item.lahanMin,
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
