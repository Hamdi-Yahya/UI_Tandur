import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';

class DownloadedScreen extends StatelessWidget {
  const DownloadedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DownloadedMockData.items;

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
          'Materi Terunduh',
          style: AppTypography.judul.copyWith(color: AppColors.tanah),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'Belum ada materi yang diunduh.',
                style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.l),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.kertas,
                    borderRadius: BorderRadius.circular(AppRadius.sedang),
                    border: Border.all(color: AppColors.garis),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: AppColors.embun,
                          borderRadius: BorderRadius.circular(AppRadius.kecil),
                        ),
                        child: const Icon(
                          Icons.download_done,
                          color: AppColors.daun,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${item.petakName} • ${item.size}',
                              style: AppTypography.label.copyWith(color: AppColors.tanahLemah),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.cabai),
                        onPressed: () {
                          // TODO: Implement delete logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Materi dihapus')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
