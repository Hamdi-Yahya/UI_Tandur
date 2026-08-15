import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';

/// Tab untuk memilih komoditas di Peta Kelas
class CommodityTabs extends StatelessWidget {
  final String selectedCommodity;
  final ValueChanged<String> onSelected;

  const CommodityTabs({
    super.key,
    required this.selectedCommodity,
    required this.onSelected,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: commodities.map((commodity) {
          final isSelected = selectedCommodity == commodity;
          
          return InkWell(
            onTap: () => onSelected(commodity),
            borderRadius: BorderRadius.circular(AppRadius.penuh),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.daunSamar : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.penuh),
                border: isSelected 
                    ? Border.all(color: AppColors.daun, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    size: 16,
                    color: isSelected ? AppColors.daun : AppColors.tanahSamar,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    commodity,
                    style: AppTypography.isiTebal.copyWith(
                      color: isSelected ? AppColors.tanah : AppColors.tanahSamar,
                    ),
                  ),
                ],
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
      if (lesson.type == LessonType.video) return Icons.play_circle_fill;
      return Icons.view_carousel; // Untuk tipe kartu
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
                  Text(
                    lesson.duration,
                    style: AppTypography.kecil.copyWith(
                      color: isLocked ? AppColors.tanahSamar : AppColors.tanahLemah,
                    ),
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

