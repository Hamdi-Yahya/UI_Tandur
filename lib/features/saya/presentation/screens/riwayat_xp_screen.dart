import 'package:flutter/material.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_mock_data.dart';

/// Riwayat XP — rute `/saya/xp`, API_DOCS_NEW.md §3.4 Get XP History.
class RiwayatXpScreen extends StatelessWidget {
  const RiwayatXpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = SayaMockData.xpHistory;
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Riwayat XP'),
      body: SafeArea(
        child: items.isEmpty
            ? KeadaanKosong(icon: Icons.bolt_outlined, message: 'Belum ada riwayat XP', actionLabel: 'Mulai belajar', onAction: () {})
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.garis),
                itemBuilder: (context, index) {
                  final x = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(color: AppColors.padiSamar, shape: BoxShape.circle),
                          child: const Icon(Icons.bolt, color: AppColors.padi, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(xpReasonLabel(x.reason), style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                              Text(
                                '${x.createdAt.day}/${x.createdAt.month} · ${x.createdAt.hour.toString().padLeft(2, '0')}:${x.createdAt.minute.toString().padLeft(2, '0')}',
                                style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar),
                              ),
                            ],
                          ),
                        ),
                        Text('+${x.amount}', style: AppTypography.angka.copyWith(color: AppColors.padi, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
