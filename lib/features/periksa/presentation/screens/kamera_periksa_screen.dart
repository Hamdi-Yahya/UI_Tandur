import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_mock_data.dart';

/// Layar kamera Periksa Tanaman — DESAIN.md §4.5. "Layar paling sunyi di
/// aplikasi", hampir tanpa warna. Pratinjau kamera diganti placeholder karena
/// belum ada dependency kamera/kompresi gambar (tahap ini murni UI ringan,
/// belum tersambung ke BE/hardware — lihat CATATAN_FE_FLUTTER.md).
class KameraPeriksaScreen extends StatefulWidget {
  const KameraPeriksaScreen({super.key});

  @override
  State<KameraPeriksaScreen> createState() => _KameraPeriksaScreenState();
}

class _KameraPeriksaScreenState extends State<KameraPeriksaScreen> {
  static const _tips = [
    'Satu daun, latar polos, jangan melawan cahaya',
    'Pastikan gejala terlihat jelas di tengah bingkai',
    'Ambil dari jarak dekat, bukan seluruh rumpun',
  ];

  Plant _selectedPlant = PeriksaMockData.plants.first;
  int _tipIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pilihTanaman() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kertas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.besar)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PeriksaMockData.plants
              .map((p) => ListTile(
                    title: Text(p.nickname, style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                    subtitle: Text('HST ${p.daysAfterPlanting}', style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah)),
                    onTap: () {
                      setState(() => _selectedPlant = p);
                      Navigator.of(context).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _ambilFoto() {
    // Klasifikasi berjalan di perangkat lewat model TFLite (PRD §7.3). Di tahap
    // UI ini, hasil langsung memakai data mock DONE dari PeriksaMockData.
    context.push('/periksa/hasil/${PeriksaMockData.scanDone.scanId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.push('/periksa/tanaman'),
                    tooltip: 'Tutup',
                  ),
                  InkWell(
                    onTap: _pilihTanaman,
                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                      child: Row(
                        children: [
                          Text(_selectedPlant.nickname, style: AppTypography.isiTebal.copyWith(color: Colors.white)),
                          const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: CustomPaint(
                      painter: _DashedFramePainter(),
                      child: const Center(
                        child: Icon(Icons.eco_outlined, color: Colors.white24, size: 64),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.l),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: Text(
                  _tips[_tipIndex],
                  key: ValueKey(_tipIndex),
                  textAlign: TextAlign.center,
                  style: AppTypography.isi.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.l),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionIcon(icon: Icons.photo_library_outlined, label: 'galeri', onTap: _ambilFoto),
                  GestureDetector(
                    onTap: _ambilFoto,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  _ActionIcon(icon: Icons.flash_off_outlined, label: 'senter', onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.penuh),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.kecil.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

/// Bingkai panduan garis putus-putus — DESAIN.md §4.5: "bukan bingkai penuh,
/// supaya pengguna tetap melihat sekitar daun".
class _DashedFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(AppRadius.sedang),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
