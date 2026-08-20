import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';

/// Tab untuk memilih komoditas di Peta Kelas.
/// Tab yang dipilih: pill hitam/gelap. Tab lain: transparan dengan teks abu.
class CommodityTabs extends StatelessWidget {
  final String selectedCommodity;
  final ValueChanged<String> onSelected;

  const CommodityTabs({
    super.key,
    required this.selectedCommodity,
    required this.onSelected,
  });

  /// Pemetaan komoditas ke emoji yang ditampilkan di dalam tab.
  static const Map<String, String> _commodityEmojis = {
    'Cabai': '🌶️',
    'Terong': '🍆',
    'Padi': '🌾',
  };

  @override
  Widget build(BuildContext context) {
    const commodities = ['Cabai', 'Terong', 'Padi'];

    return Container(
      color: AppColors.embun,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: commodities.map((commodity) {
          final isSelected = selectedCommodity == commodity;
          final emoji = _commodityEmojis[commodity] ?? '';

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s),
            child: GestureDetector(
              onTap: () => onSelected(commodity),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                decoration: BoxDecoration(
                  // Tab terpilih: pill hitam pekat. Lainnya: transparan.
                  color: isSelected ? AppColors.tanah : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.penuh),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      commodity,
                      style: AppTypography.isiTebal.copyWith(
                        color: isSelected ? AppColors.kertas : AppColors.tanahSamar,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Kartu untuk menampilkan Unit di dalam layar Detail Petak
class UnitCard extends StatelessWidget {
  final UnitSummary unit;
  final VoidCallback onTap;

  const UnitCard({
    super.key,
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = unit.status == UnitStatus.locked;
    final bool isCompleted = unit.status == UnitStatus.completed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sedang),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: isLocked ? AppColors.embun : AppColors.kertas,
          borderRadius: BorderRadius.circular(AppRadius.sedang),
          border: Border.all(
            color: isLocked ? AppColors.garis : AppColors.daun,
            width: 1,
          ),
          boxShadow: isLocked ? null : const [
            BoxShadow(
              color: Color(0x14241F1A), // bayanganMelayang from DESAIN.md
              blurRadius: 16,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    unit.title,
                    style: AppTypography.isiTebal.copyWith(
                      color: isLocked ? AppColors.tanahSamar : AppColors.tanah,
                    ),
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: AppColors.daunMuda, size: 20)
                else if (isLocked)
                  const Icon(Icons.lock, color: AppColors.tanahSamar, size: 20),
              ],
            ),
            if (!isLocked) ...[
              const SizedBox(height: AppSpacing.m),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.penuh),
                child: LinearProgressIndicator(
                  value: unit.progress,
                  backgroundColor: AppColors.daunSamar,
                  color: AppColors.daunMuda,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${(unit.progress * 100).toInt()}% Selesai',
                style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// Kartu untuk menampilkan Materi (Lesson) di dalam layar Detail Unit
class LessonCard extends StatelessWidget {
  final LessonSummary lesson;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = lesson.status == LessonStatus.locked;
    final bool isCompleted = lesson.status == LessonStatus.completed;

    IconData getIcon() {
      switch (lesson.type) {
        case LessonType.video:
          return Icons.play_circle_fill;
        case LessonType.latihan:
          return Icons.edit_note;
        case LessonType.kartu:
          return Icons.view_carousel;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sedang),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: isLocked ? AppColors.embun : AppColors.kertas,
          borderRadius: BorderRadius.circular(AppRadius.sedang),
          border: Border.all(
            color: isLocked ? AppColors.garis : AppColors.daun,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: isLocked ? AppColors.garis : AppColors.daunSamar,
                borderRadius: BorderRadius.circular(AppRadius.kecil),
              ),
              child: Icon(
                getIcon(),
                color: isLocked ? AppColors.tanahSamar : AppColors.daun,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppTypography.isiTebal.copyWith(
                      color: isLocked ? AppColors.tanahSamar : AppColors.tanah,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(
                        lesson.duration,
                        style: AppTypography.kecil.copyWith(
                          color: isLocked
                              ? AppColors.tanahSamar
                              : AppColors.tanahLemah,
                        ),
                      ),
                      if (lesson.xpReward > 0) ...[
                        Text(
                          '  ·  ',
                          style: AppTypography.kecil.copyWith(
                            color: AppColors.tanahSamar,
                          ),
                        ),
                        Text(
                          '+${lesson.xpReward} XP',
                          style: AppTypography.kecil.copyWith(
                            color: isLocked ? AppColors.tanahSamar : AppColors.padi,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle, color: AppColors.daunMuda, size: 24)
            else if (isLocked)
              const Icon(Icons.lock, color: AppColors.tanahSamar, size: 24),
          ],
        ),
      ),
    );
  }
}

