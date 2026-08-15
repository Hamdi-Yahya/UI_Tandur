import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';

/// Indikator XP (⚡)
class XpIndicator extends StatelessWidget {
  final int xp;
  
  const XpIndicator({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '⚡', 
          style: TextStyle(fontSize: 16),
          semanticsLabel: 'XP',
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          xp.toString(),
          style: AppTypography.judul.copyWith(color: AppColors.padi),
        ),
      ],
    );
  }
}

/// Indikator Streak (🔥)
class StreakIndicator extends StatelessWidget {
  final int streak;
  
  const StreakIndicator({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '🔥',
          style: TextStyle(fontSize: 16),
          semanticsLabel: 'Runtutan Hari',
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          streak.toString(),
          style: AppTypography.judul.copyWith(color: AppColors.padi),
        ),
      ],
    );
  }
}

/// Indikator Nyawa (🌶️ sebagai ganti Hati)
class LivesIndicator extends StatelessWidget {
  final int lives;
  final int maxLives;
  
  const LivesIndicator({
    super.key, 
    required this.lives,
    this.maxLives = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isFilled = index < lives;
        // Jika tidak filled, tampilkan warna abu atau opacity
        return Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Text(
            '🌶️',
            style: TextStyle(
              fontSize: 16,
              color: isFilled ? null : AppColors.garis, 
            ),
            semanticsLabel: isFilled ? 'Nyawa tersisa' : 'Nyawa kosong',
          ),
        );
      }),
    );
  }
}

/// Header Gamifikasi untuk Peta Kelas
class GamificationHeader extends StatelessWidget {
  final int streak;
  final int xp;
  final int lives;

  const GamificationHeader({
    super.key,
    required this.streak,
    required this.xp,
    required this.lives,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l, 
        vertical: AppSpacing.m,
      ),
      decoration: const BoxDecoration(
        color: AppColors.embun,
        border: Border(
          bottom: BorderSide(color: AppColors.garis, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreakIndicator(streak: streak),
          XpIndicator(xp: xp),
          LivesIndicator(lives: lives),
        ],
      ),
    );
  }
}
