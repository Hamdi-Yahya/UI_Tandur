import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_mock_data.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Layar Hasil Pindai — DESAIN.md §4.6. Menangani dua status: DONE (dugaan
/// utama + alternatif) dan LOW_CONFIDENCE ("belum yakin"), sesuai kontrak
/// `POST /api/scans` di API_DOCS.md §4.2 v3.2.
///
/// Perubahan v3.2:
/// - Menampilkan `alias` (nama daerah penyakit) jika tersedia
/// - Info versi model + inputSize dari MockManifests di footer disclaimer
/// - Filter alternatif sudah diterapkan di mock data (confidence > 0.10)
class HasilPindaiScreen extends StatelessWidget {
  final String scanId;

  const HasilPindaiScreen({super.key, required this.scanId});

  ScanResult get _scan =>
      scanId == PeriksaMockData.scanLowConfidence.scanId ? PeriksaMockData.scanLowConfidence : PeriksaMockData.scanDone;

  void _kenapaBisaSalah(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kertas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.besar)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kenapa hasilnya bisa salah?', style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah)),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Model dilatih dari citra yang sebagian difoto di kondisi terkendali, gejala awal beberapa '
              'penyakit mirip satu sama lain, dan satu foto tidak menangkap kondisi akar maupun tanah. '
              'Mengakui batas ini menaikkan kepercayaan, bukan menurunkannya.',
              style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
            ),
          ],
        ),
      ),
    );
  }

  void _tandaiSalah(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terima kasih. Laporan ini membantu kami memperbaiki model.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = _scan;
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Hasil Periksa'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AspectRatio(aspectRatio: 4 / 3, child: PhotoPlaceholder()),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  LabelKomoditas(commodity: scan.commodity),
                  const SizedBox(width: AppSpacing.s),
                  Text(formatHst(scan.daysAfterPlanting), style: AppTypography.angka.copyWith(color: AppColors.tanahLemah)),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              if (scan.status == ScanStatus.done) ..._buildDone(context, scan) else ..._buildLowConfidence(context, scan),
              const SizedBox(height: AppSpacing.xl),
              const Divider(color: AppColors.garis),
              const SizedBox(height: AppSpacing.m),
              Text(scan.disclaimer, style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar)),
              // Info model: versi dan inputSize — dari manifest, bukan hardcode.
              // Ditampilkan kecil di footer untuk transparansi, sesuai semangat
              // DESAIN §4.6 "mengakui batas menaikkan kepercayaan".
              Builder(builder: (_) {
                final manifest = MockManifests.forCommodity(scan.commodity);
                return Text(
                  'Model ${manifest.commodity} v${manifest.version} · ${manifest.inputSize}px · ${manifest.quantization}',
                  style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar.withValues(alpha: 0.7)),
                );
              }),
              const SizedBox(height: AppSpacing.s),
              GestureDetector(
                onTap: () => _kenapaBisaSalah(context),
                child: Text(
                  'Kenapa hasilnya bisa salah? →',
                  style: AppTypography.kecil.copyWith(color: AppColors.daun, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _tandaiSalah(context),
                  child: Text('Hasilnya keliru? Tandai', style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDone(BuildContext context, ScanResult scan) {
    final primary = scan.primary!;
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.kertas,
          borderRadius: BorderRadius.circular(AppRadius.sedang),
          border: Border.all(color: AppColors.cabai.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DUGAAN UTAMA', style: AppTypography.label.copyWith(color: AppColors.cabai)),
            const SizedBox(height: AppSpacing.s),
            Text(primary.displayName, style: AppTypography.tampilanSedang.copyWith(color: AppColors.tanah)),
            // Alias adalah nama daerah/umum penyakit, misalnya "bule" untuk
            // Virus Kuning Keriting, atau "blasting" untuk Blas Daun Padi.
            if (primary.alias != null) ...[
              const SizedBox(height: 2),
              Text(
                'dikenal juga: ${primary.alias}',
                style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: AppSpacing.m),
            LencanaKeyakinan(confidence: primary.confidence, color: AppColors.cabai),
            if (primary.summary != null) ...[
              const SizedBox(height: AppSpacing.m),
              Text(primary.summary!, style: AppTypography.isi.copyWith(color: AppColors.tanahLemah)),
            ],
          ],
        ),
      ),
      if (scan.alternatives.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.l),
        Text('KEMUNGKINAN LAIN', style: AppTypography.label.copyWith(color: AppColors.tanahSamar)),
        const SizedBox(height: AppSpacing.s),
        ...scan.alternatives.map(
          (alt) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: Text(alt.displayName, style: AppTypography.isi.copyWith(color: AppColors.tanah))),
                SizedBox(
                  width: 96,
                  child: LencanaKeyakinan(confidence: alt.confidence, color: AppColors.tanahSamar),
                ),
              ],
            ),
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.xl),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => context.push('/periksa/diskusi/${scan.scanId}'),
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: const Text('Tanya soal hasil ini'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.daun,
            foregroundColor: AppColors.kertas,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
            textStyle: AppTypography.isiTebal,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.s),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () => context.push('/warung/tanya', extra: {'fromScanId': scan.scanId, 'commodity': scan.commodity}),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.tanah,
            side: const BorderSide(color: AppColors.garis, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
            textStyle: AppTypography.isiTebal,
          ),
          child: const Text('Tanyakan ke Warung Tani'),
        ),
      ),
    ];
  }

  List<Widget> _buildLowConfidence(BuildContext context, ScanResult scan) {
    final guidance = scan.guidance!;
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.kertas,
          borderRadius: BorderRadius.circular(AppRadius.sedang),
          border: Border.all(color: AppColors.garis),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BELUM YAKIN', style: AppTypography.label.copyWith(color: AppColors.tanahLemah)),
            const SizedBox(height: AppSpacing.s),
            Text(guidance.title, style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah)),
            const SizedBox(height: AppSpacing.m),
            Text('Coba foto ulang dengan:', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
            const SizedBox(height: AppSpacing.s),
            ...guidance.tips.map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('· ', style: AppTypography.isi.copyWith(color: AppColors.tanahLemah)),
                    Expanded(child: Text(t, style: AppTypography.isi.copyWith(color: AppColors.tanahLemah))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.daun,
                  foregroundColor: AppColors.kertas,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                  textStyle: AppTypography.isiTebal,
                ),
                child: const Text('Foto ulang'),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
