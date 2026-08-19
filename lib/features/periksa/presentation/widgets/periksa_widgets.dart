import 'package:flutter/material.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_models.dart';

String formatHst(int hst) => 'HST $hst';

String diagnosisLabel(String? raw) {
  if (raw == null) return '-';
  return raw
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}')
      .join(' ');
}

/// Kartu tanaman — dipakai di Daftar Tanaman Saya.
class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantCard({super.key, required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sedang),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.kertas,
          borderRadius: BorderRadius.circular(AppRadius.sedang),
          border: Border.all(color: AppColors.garis),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.daunSamar,
                borderRadius: BorderRadius.circular(AppRadius.kecil),
              ),
              child: const Icon(Icons.eco, color: AppColors.daun),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.nickname, style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      LabelKomoditas(commodity: plant.commodity),
                      const SizedBox(width: AppSpacing.s),
                      Text(formatHst(plant.daysAfterPlanting), style: AppTypography.angka.copyWith(color: AppColors.tanahLemah)),
                    ],
                  ),
                  if (plant.lastDiagnosis != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Terakhir: ${diagnosisLabel(plant.lastDiagnosis)}',
                      style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.tanahSamar),
          ],
        ),
      ),
    );
  }
}

/// Satu butir linimasa pindai — foto kecil, umur, hasil dugaan, keyakinan.
class ScanTimelineTile extends StatelessWidget {
  final ScanTimelineItem item;
  final bool isLast;
  final VoidCallback onTap;

  const ScanTimelineTile({super.key, required this.item, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isSehat = item.label == 'SEHAT';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSehat ? AppColors.daunSamar : AppColors.cabaiSamar,
                      borderRadius: BorderRadius.circular(AppRadius.kecil),
                    ),
                    child: Icon(Icons.image_outlined, color: isSehat ? AppColors.daun : AppColors.cabai, size: 20),
                  ),
                  if (!isLast) Expanded(child: Container(width: 1, color: AppColors.garis)),
                ],
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatHst(item.daysAfterPlanting)} · ${item.createdAt.day}/${item.createdAt.month}',
                        style: AppTypography.angka.copyWith(color: AppColors.tanahLemah),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.displayName} · ${(item.confidence * 100).toStringAsFixed(0)}%',
                        style: AppTypography.isiTebal.copyWith(color: isSehat ? AppColors.daun : AppColors.cabai),
                      ),
                      if (item.flag == 'REPEATED') ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.padi),
                            const SizedBox(width: 4),
                            Text(
                              'Kedua kali dalam 2 minggu',
                              style: AppTypography.kecil.copyWith(color: AppColors.padi, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
