import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_mock_data.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Linimasa Tanaman — DESAIN.md §4.8, rute `/periksa/tanaman/:id`.
class LinimasaTanamanScreen extends StatelessWidget {
  final String plantId;

  const LinimasaTanamanScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    final plant = PeriksaMockData.plants.firstWhere(
      (p) => p.plantId == plantId,
      orElse: () => PeriksaMockData.plants.first,
    );
    final timeline = PeriksaMockData.timelineFor(plantId);

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: ScreenAppBar(title: plant.nickname),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatHst(plant.daysAfterPlanting)} · ${plant.unitCount} ${unitTypeLabel(plant.unitType)}',
                    style: AppTypography.angka.copyWith(color: AppColors.tanahLemah),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.garis),
            Expanded(
              child: timeline.isEmpty
                  ? KeadaanKosong(
                      icon: Icons.timeline,
                      message: 'Belum ada pemeriksaan untuk tanaman ini',
                      actionLabel: 'Periksa sekarang',
                      onAction: () => context.push('/periksa'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      itemCount: timeline.length,
                      itemBuilder: (context, index) => ScanTimelineTile(
                        item: timeline[index],
                        isLast: index == timeline.length - 1,
                        onTap: () => context.push('/periksa/hasil/${timeline[index].scanId}'),
                      ),
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/periksa'),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: const Text('Periksa lagi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.daun,
                      side: const BorderSide(color: AppColors.daun, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                      textStyle: AppTypography.isiTebal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
