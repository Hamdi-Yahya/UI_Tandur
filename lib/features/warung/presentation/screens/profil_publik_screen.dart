import 'package:flutter/material.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/warung/data/warung_mock_data.dart';

/// Profil Publik Pengguna — DESAIN.md rute `/warung/pengguna/:id`,
/// API_DOCS_NEW.md §5.3 Get User Profile.
class ProfilPublikScreen extends StatelessWidget {
  final String userId;

  const ProfilPublikScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final p = WarungMockData.publicProfile;
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Profil'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              InitialAvatar(name: p.author.fullName, radius: 40),
              const SizedBox(height: AppSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p.author.fullName, style: AppTypography.judul.copyWith(color: AppColors.tanah)),
                  if (p.author.isVerified) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.verified, size: 18, color: AppColors.terong),
                  ],
                ],
              ),
              if (p.verifiedNote.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(p.verifiedNote, style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar)),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(label: 'Reputasi', value: '${p.author.reputation}'),
                  _Stat(label: 'Jawaban terbaik', value: '${p.bestAnswerCount}'),
                  _Stat(label: 'Balasan', value: '${p.replyCount}'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const Divider(color: AppColors.garis),
              const SizedBox(height: AppSpacing.l),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Komoditas dikuasai', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
              ),
              const SizedBox(height: AppSpacing.s),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: AppSpacing.s,
                  children: p.topCommodities.map((c) => LabelKomoditas(commodity: c)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.angkaBesar.copyWith(color: AppColors.tanah)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah)),
      ],
    );
  }
}
