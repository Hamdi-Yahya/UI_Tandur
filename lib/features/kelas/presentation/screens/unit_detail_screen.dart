import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';
import 'package:tandur/features/kelas/presentation/widgets/kelas_widgets.dart';

class UnitDetailScreen extends StatelessWidget {
  final String id;

  const UnitDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final unit = UnitDetail.getMock(id);

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: AppBar(
        backgroundColor: AppColors.embun,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.tanah),
          onPressed: () => context.pop(),
        ),
        title: Text(
          unit.title,
          style: AppTypography.judul.copyWith(color: AppColors.tanah),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          // Deskripsi Unit
          Text(
            unit.description,
            style: AppTypography.isiBesar.copyWith(color: AppColors.tanah),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Materi Belajar',
            style: AppTypography.judul.copyWith(color: AppColors.tanah),
          ),
          const SizedBox(height: AppSpacing.m),
          
          // Daftar Materi (Lessons)
          ...unit.lessons.map((lesson) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: LessonCard(
                lesson: lesson,
                onTap: () {
                  if (lesson.status != LessonStatus.locked) {
                    context.push('/kelas/lesson/${lesson.id}');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Materi ini masih terkunci.'),
                        backgroundColor: AppColors.tanah,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            );
          }),
          
          const SizedBox(height: AppSpacing.m),
          
          // Ujian Unit (Latihan)
          _buildUnitQuizCard(context, unit),
        ],
      ),
    );
  }

  Widget _buildUnitQuizCard(BuildContext context, UnitDetail unit) {
    final bool isLocked = unit.quizStatus == FinalTestStatus.locked;
    final bool isCompleted = unit.quizStatus == FinalTestStatus.completed;
    
    return InkWell(
      onTap: isLocked ? null : () => context.push('/kelas/ujian-unit/${unit.id}'),
      borderRadius: BorderRadius.circular(AppRadius.sedang),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: isLocked ? AppColors.garis.withValues(alpha: 0.3) : AppColors.padiSamar,
          borderRadius: BorderRadius.circular(AppRadius.sedang),
          border: Border.all(
            color: isLocked ? AppColors.garis : AppColors.padi,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: isLocked ? AppColors.garis : AppColors.padi,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : (isLocked ? Icons.lock : Icons.assignment),
                color: isLocked ? AppColors.tanahSamar : AppColors.kertas,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ujian Pemahaman Unit',
                    style: AppTypography.isiTebal.copyWith(
                      color: isLocked ? AppColors.tanahSamar : AppColors.tanah,
                    ),
                  ),
                  Text(
                    isLocked 
                        ? 'Selesaikan semua materi untuk membuka.' 
                        : (isCompleted ? 'Sudah diselesaikan' : 'Siap dikerjakan'),
                    style: AppTypography.kecil.copyWith(
                      color: isLocked ? AppColors.tanahSamar : AppColors.tanahLemah,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
