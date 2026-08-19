import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_models.dart';
import 'package:tandur/features/periksa/data/periksa_repository.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Layar Hasil Pindai — DESAIN.md §4.6. Menangani dua status: DONE (dugaan
/// utama + alternatif) dan LOW_CONFIDENCE ("belum yakin"), sesuai kontrak
/// `POST /api/scans` di API_DOCS.md §4.2 v3.2.
///
/// Memuat `GET /api/scans/:id`. `GET /api/scans/:id` hanya membawa
/// label + confidence (tanpa displayName/alias/summary), jadi nama tampilan
/// diturunkan dari label; info model di footer dibaca dari manifes.
class HasilPindaiScreen extends ConsumerStatefulWidget {
  final String scanId;

  const HasilPindaiScreen({super.key, required this.scanId});

  @override
  ConsumerState<HasilPindaiScreen> createState() => _HasilPindaiScreenState();
}

class _HasilPindaiScreenState extends ConsumerState<HasilPindaiScreen> {
  bool _loading = true;
  String? _error;
  ScanResult? _scan;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final scan = await ref.read(periksaRepositoryProvider).getScan(widget.scanId);
      if (!mounted) return;
      setState(() {
        _scan = scan;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

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

  Future<void> _tandaiSalah() async {
    try {
      await ref
          .read(periksaRepositoryProvider)
          .flagScan(widget.scanId, reason: ScanFlagReason.wrongLabel);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih. Laporan ini membantu kami memperbaiki model.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = KeadaanGalat(message: _error!, onRetry: _muat);
    } else {
      body = _buildKonten(context);
    }
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Hasil Periksa'),
      body: SafeArea(child: body),
    );
  }

  Widget _buildKonten(BuildContext context) {
    final scan = _scan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(aspectRatio: 4 / 3, child: PhotoPlaceholder()),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: Text(
                  scan.plantNickname ?? 'Tanaman',
                  style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (scan.daysAfterPlanting != null)
                Text(formatHst(scan.daysAfterPlanting!), style: AppTypography.angka.copyWith(color: AppColors.tanahLemah)),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (scan.status == ScanStatus.done)
            ..._buildDone(context, scan)
          else if (scan.status == ScanStatus.lowConfidence || scan.status == ScanStatus.unknown)
            ..._buildLowConfidence(context, scan),
          const SizedBox(height: AppSpacing.xl),
          const Divider(color: AppColors.garis),
          const SizedBox(height: AppSpacing.m),
          Text(scan.disclaimer, style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar)),
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
              onPressed: _tandaiSalah,
              child: Text('Hasilnya keliru? Tandai', style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDone(BuildContext context, ScanResult scan) {
    final primary = scan.primary;
    if (primary == null) return const [SizedBox.shrink()];
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
      if (scan.canDiscuss) ...[
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
      ],
    ];
  }

  List<Widget> _buildLowConfidence(BuildContext context, ScanResult scan) {
    final guidance = scan.guidance ??
        const LowConfidenceGuidance(
          title: 'Fotonya belum cukup jelas',
          tips: ['Satu helai daun saja', 'Latar polos, misalnya kertas', 'Cahaya dari samping, jangan melawan matahari'],
        );
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