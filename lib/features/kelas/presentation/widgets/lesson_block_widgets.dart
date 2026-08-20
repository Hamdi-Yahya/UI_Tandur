import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';

/// Satu halaman materi CARD: kumpulan blok yang dibaca sekaligus.
///
/// Backend mengirim materi sebagai deret blok datar (HEADING, PARAGRAPH,
/// CALLOUT, IMAGE). Menampilkan satu blok per kartu membuat kartu berisi
/// judul saja, jadi blok dikelompokkan dulu lewat [groupLessonBlocks]:
/// HEADING dan CALLOUT memulai halaman baru, PARAGRAPH/IMAGE menempel pada
/// halaman berjalan.
List<List<LessonBlock>> groupLessonBlocks(List<LessonBlock> blocks) {
  final pages = <List<LessonBlock>>[];
  for (final block in blocks) {
    final isRenderable =
        (block.text != null && block.text!.trim().isNotEmpty) ||
        block.type == LessonBlockType.image;
    if (!isRenderable) continue;

    final startsNewPage =
        pages.isEmpty ||
        block.type == LessonBlockType.heading ||
        block.type == LessonBlockType.callout ||
        pages.last.last.type == LessonBlockType.callout;

    if (startsNewPage) {
      pages.add([block]);
    } else {
      pages.last.add(block);
    }
  }
  return pages;
}

/// Warna dan ikon kotak sorotan sesuai `variant` dari backend.
class _CalloutStyle {
  const _CalloutStyle(this.background, this.border, this.accent, this.icon);

  final Color background;
  final Color border;
  final Color accent;
  final IconData icon;

  static _CalloutStyle of(String? variant) {
    switch (variant?.toUpperCase()) {
      case 'MISTAKE':
        return const _CalloutStyle(
          AppColors.cabaiSamar,
          AppColors.cabai,
          AppColors.cabai,
          Icons.error_outline,
        );
      case 'TIP':
        return const _CalloutStyle(
          AppColors.daunSamar,
          AppColors.daunMuda,
          AppColors.daun,
          Icons.lightbulb_outline,
        );
      default:
        return const _CalloutStyle(
          AppColors.padiSamar,
          AppColors.padi,
          AppColors.padi,
          Icons.info_outline,
        );
    }
  }
}

/// Render satu blok materi sesuai tipenya.
///
/// Sebelumnya semua blok ditampilkan sebagai teks tengah berukuran sama,
/// sehingga judul, paragraf, dan kotak sorotan tidak bisa dibedakan dan
/// `title`/`variant` milik CALLOUT hilang begitu saja.
class LessonBlockView extends StatelessWidget {
  const LessonBlockView({super.key, required this.block});

  final LessonBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case LessonBlockType.heading:
        return Text(
          block.text ?? '',
          style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah),
        );

      case LessonBlockType.callout:
        final style = _CalloutStyle.of(block.variant);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(AppRadius.sedang),
            border: Border.all(color: style.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(style.icon, size: 20, color: style.accent),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      block.title ?? '',
                      style: AppTypography.isiTebal.copyWith(
                        color: style.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                block.text ?? '',
                style: AppTypography.isi.copyWith(color: AppColors.tanah),
              ),
            ],
          ),
        );

      case LessonBlockType.image:
        final url = block.url;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              child: url == null || url.isEmpty
                  ? _imagePlaceholder()
                  : Image.network(
                      url,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _imagePlaceholder(),
                    ),
            ),
            if (block.caption != null && block.caption!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                block.caption!,
                style: AppTypography.kecil.copyWith(
                  color: AppColors.tanahLemah,
                ),
              ),
            ],
          ],
        );

      case LessonBlockType.paragraph:
      case LessonBlockType.unknown:
        return Text(
          block.text ?? '',
          style: AppTypography.isiBesar.copyWith(
            color: AppColors.tanah,
            height: 1.6,
          ),
        );
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 160,
      color: AppColors.daunSamar,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.daun, size: 32),
    );
  }
}

/// Catatan sumber dan peninjau materi.
///
/// Kurikulum baru mengisi `sourceReference` dan `reviewedBy` pada tiap materi
/// CARD; keduanya wajib terlihat supaya klaim di dalam materi bisa ditelusuri.
class LessonSourceFooter extends StatelessWidget {
  const LessonSourceFooter({
    super.key,
    this.sourceReference,
    this.reviewedBy,
    this.attribution,
  });

  final String? sourceReference;
  final String? reviewedBy;
  final String? attribution;

  bool get _isEmpty =>
      (sourceReference == null || sourceReference!.isEmpty) &&
      (reviewedBy == null || reviewedBy!.isEmpty) &&
      (attribution == null || attribution!.isEmpty);

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) return const SizedBox.shrink();

    final lines = <String>[
      if (attribution != null && attribution!.isNotEmpty) attribution!,
      if (sourceReference != null && sourceReference!.isNotEmpty)
        'Sumber: $sourceReference',
      if (reviewedBy != null && reviewedBy!.isNotEmpty)
        'Ditinjau oleh: $reviewedBy',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.embun,
        borderRadius: BorderRadius.circular(AppRadius.kecil),
        border: Border.all(color: AppColors.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                line,
                style: AppTypography.kecil.copyWith(
                  color: AppColors.tanahLemah,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
