import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';
import 'package:tandur/features/kelas/presentation/widgets/kelas_widgets.dart';

class PetakDetailScreen extends StatelessWidget {
  final String id;

  const PetakDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // Fetch mock data
    final level = KelasMockData.getLevelDetail(id);

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: AppBar(
        backgroundColor: AppColors.embun,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.tanah),
          onPressed: () => context.pop(),
          tooltip: 'Kembali',
        ),
        title: Text(
          level.title,
          style: AppTypography.judul.copyWith(color: AppColors.tanah),
        ),
        centerTitle: true,
      ),
      body: level.status == TerraceNodeStatus.locked
          ? _buildLockedState(level)
          : _buildAvailableState(context, level),
    );
  }

  Widget _buildLockedState(LevelDetail level) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.tanahSamar),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Petak Terkunci',
              style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              level.lockReason ?? 'Selesaikan petak sebelumnya terlebih dahulu.',
              textAlign: TextAlign.center,
              style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableState(BuildContext context, LevelDetail level) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // Deskripsi Petak
        Text(
          level.description,
          style: AppTypography.isiBesar.copyWith(color: AppColors.tanah),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Estimasi: ${level.estimatedTime}',
          style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
        ),
        const SizedBox(height: AppSpacing.xl),
        
        // Progress Keseluruhan Petak
        if (level.status == TerraceNodeStatus.inProgress || level.status == TerraceNodeStatus.completed)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Keseluruhan',
                style: AppTypography.label.copyWith(color: AppColors.tanahSamar),
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.penuh),
                child: LinearProgressIndicator(
                  value: level.progress,
                  backgroundColor: AppColors.garis,
                  color: AppColors.daun,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),

        // Daftar Unit
        Text(
          'Daftar Unit',
          style: AppTypography.judul.copyWith(color: AppColors.tanah),
        ),
        const SizedBox(height: AppSpacing.m),
        ...level.units.map((unit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.m),
            child: UnitCard(
              unit: unit,
              onTap: () {
                if (unit.status != UnitStatus.locked) {
                  context.push('/kelas/unit/${unit.id}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unit ini masih terkunci.'),
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

        // Ujian Akhir Petak
        _buildFinalTestCard(context, level),
      ],
    );
  }

  Widget _buildFinalTestCard(BuildContext context, LevelDetail level) {
    final bool isLocked = level.finalTestStatus == FinalTestStatus.locked;
    final bool isCompleted = level.finalTestStatus == FinalTestStatus.completed;
    
    return InkWell(
      onTap: isLocked ? null : () => context.push('/kelas/ujian/${level.id}'),
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
                isCompleted ? Icons.check : (isLocked ? Icons.lock : Icons.star),
                color: isLocked ? AppColors.tanahSamar : AppColors.kertas,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ujian Akhir Petak',
                    style: AppTypography.isiTebal.copyWith(
                      color: isLocked ? AppColors.tanahSamar : AppColors.tanah,
                    ),
                  ),
                  Text(
                    isLocked 
                        ? 'Selesaikan semua unit untuk membuka.' 
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
