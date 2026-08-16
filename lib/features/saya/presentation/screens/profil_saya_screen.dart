import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_mock_data.dart';
import 'package:tandur/features/saya/presentation/widgets/saya_widgets.dart';

/// Profil Saya (Utama) — rute `/saya`. Pintu masuk ke Ubah Profil, Riwayat XP,
/// Koleksi Lencana, Pusat Notifikasi, dan Pengaturan.
class ProfilSayaScreen extends StatelessWidget {
  const ProfilSayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = SayaMockData.profile;
    final stats = SayaMockData.stats;
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialAvatar(name: profile.fullName, radius: 32),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.fullName, style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah)),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.district ?? '-'} · Reputasi ${profile.reputation}',
                          style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.kertas,
                  borderRadius: BorderRadius.circular(AppRadius.sedang),
                  border: Border.all(color: AppColors.garis),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(icon: Icons.bolt, color: AppColors.padi, value: '${stats.totalXp}', label: 'XP'),
                    _Stat(icon: Icons.local_fire_department, color: AppColors.cabai, value: '${stats.streakDays}', label: 'Runtutan'),
                    _Stat(icon: Icons.workspace_premium, color: AppColors.daun, value: '${stats.badgeCount}', label: 'Lencana'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.kertas,
                  borderRadius: BorderRadius.circular(AppRadius.sedang),
                  border: Border.all(color: AppColors.garis),
                ),
                child: Column(
                  children: [
                    MenuRow(icon: Icons.edit_outlined, label: 'Ubah Profil', onTap: () => context.push('/saya/ubah')),
                    const Divider(height: 1, color: AppColors.garis),
                    MenuRow(icon: Icons.bar_chart, label: 'Riwayat XP', onTap: () => context.push('/saya/xp')),
                    const Divider(height: 1, color: AppColors.garis),
                    MenuRow(icon: Icons.workspace_premium_outlined, label: 'Koleksi Lencana', onTap: () => context.push('/saya/lencana')),
                    const Divider(height: 1, color: AppColors.garis),
                    MenuRow(icon: Icons.notifications_outlined, label: 'Pusat Notifikasi', onTap: () => context.push('/saya/notifikasi')),
                    const Divider(height: 1, color: AppColors.garis),
                    MenuRow(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: () => context.push('/saya/pengaturan')),
                  ],
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
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.angkaBesar.copyWith(color: AppColors.tanah, fontSize: 20)),
        Text(label, style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah)),
      ],
    );
  }
}
