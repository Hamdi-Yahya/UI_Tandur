import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        const Text('⚡', style: TextStyle(fontSize: 16)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          xp.toString(),
          style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
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
        const Text('🔥', style: TextStyle(fontSize: 16)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          streak.toString(),
          style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
        ),
      ],
    );
  }
}

/// Indikator Nyawa (❤️)
class LivesIndicator extends StatelessWidget {
  final int lives;

  const LivesIndicator({super.key, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('❤️', style: TextStyle(fontSize: 16)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          lives.toString(),
          style: AppTypography.isiTebal.copyWith(color: AppColors.cabai),
        ),
      ],
    );
  }
}

/// Header Gamifikasi utama dengan logo TANDUR di kiri dan stats di kanan.
/// Sesuai desain referensi: "🌱 TANDUR" | ⚡12 💎1.240 ❤️5
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
      color: AppColors.embun,
      child: Row(
        children: [
          // Logo TANDUR di kiri
          _buildLogo(),

          const Spacer(),

          // Stats gamifikasi di kanan
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreakIndicator(streak: streak),
              const SizedBox(width: AppSpacing.m),
              XpIndicator(xp: xp),
              const SizedBox(width: AppSpacing.m),
              LivesIndicator(lives: lives),
            ],
          ),
        ],
      ),
    );
  }

  /// Membangun logo "🌱 TANDUR" di sisi kiri header.
  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ikon tunas tanaman
        const Text('🌱', style: TextStyle(fontSize: 22)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'TANDUR',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.daun,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
