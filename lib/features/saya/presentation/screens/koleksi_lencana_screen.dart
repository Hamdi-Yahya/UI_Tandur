import 'package:flutter/material.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_mock_data.dart';

/// Koleksi Lencana — rute `/saya/lencana`, API_DOCS_NEW.md §3.4 Get My Badges.
class KoleksiLencanaScreen extends StatelessWidget {
  const KoleksiLencanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = SayaMockData.badges;
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Koleksi Lencana'),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.l),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.m,
            crossAxisSpacing: AppSpacing.m,
            childAspectRatio: 0.95,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final b = badges[index];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: b.isEarned ? AppColors.kertas : AppColors.embun,
                borderRadius: BorderRadius.circular(AppRadius.sedang),
                border: Border.all(color: b.isEarned ? AppColors.padi.withValues(alpha: 0.4) : AppColors.garis),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: b.isEarned ? AppColors.padiSamar : AppColors.garis,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: b.isEarned ? AppColors.padi : AppColors.tanahSamar,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    b.name,
                    textAlign: TextAlign.center,
                    style: AppTypography.isiTebal.copyWith(color: b.isEarned ? AppColors.tanah : AppColors.tanahSamar),
                  ),
                  const SizedBox(height: 4),
                  if (b.isEarned)
                    Text('Didapat ${b.earnedAt!.day}/${b.earnedAt!.month}', style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar))
                  else if (b.progress != null && b.target != null)
                    Text('${b.progress}/${b.target}', style: AppTypography.angka.copyWith(color: AppColors.tanahSamar)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
