import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart' as mock;
import 'package:tandur/features/kelas/data/learning_repository.dart';
import 'package:tandur/features/kelas/presentation/widgets/kelas_widgets.dart';

class PetakDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const PetakDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PetakDetailScreen> createState() => _PetakDetailScreenState();
}

class _PetakDetailScreenState extends ConsumerState<PetakDetailScreen> {
  LevelDetail? _level;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _level = null;
      _errorMessage = null;
    });
    try {
      final level = await ref
          .read(learningRepositoryProvider)
          .getLevel(widget.id);
      if (!mounted) return;
      setState(() {
        _level = level;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  /// Petak terkunci bila tidak ada unit yang bisa dikerjakan.
  bool get _isLocked {
    final level = _level;
    if (level == null) return false;
    return level.units.isNotEmpty &&
        level.units.every((u) => u.status == NodeStatus.locked);
  }

  mock.UnitStatus _toUnitStatus(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        return mock.UnitStatus.locked;
      case NodeStatus.available:
        return mock.UnitStatus.available;
      case NodeStatus.inProgress:
        return mock.UnitStatus.inProgress;
      case NodeStatus.completed:
        return mock.UnitStatus.completed;
      case NodeStatus.perfect:
        return mock.UnitStatus.completed;
      case NodeStatus.unknown:
        return mock.UnitStatus.locked;
    }
  }

  mock.FinalTestStatus _toFinalTestStatus(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        return mock.FinalTestStatus.locked;
      case NodeStatus.completed:
      case NodeStatus.perfect:
        return mock.FinalTestStatus.completed;
      case NodeStatus.available:
      case NodeStatus.inProgress:
        return mock.FinalTestStatus.available;
      case NodeStatus.unknown:
        return mock.FinalTestStatus.locked;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _level?.title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.judul.copyWith(color: AppColors.tanah),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return KeadaanGalat(message: _errorMessage!, onRetry: _load);
    }

    final level = _level;
    if (level == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.daun),
      );
    }

    if (_isLocked) {
      return _buildLockedState(level);
    }
    return _buildAvailableState(context, level);
  }

  Widget _buildLockedState(LevelDetail level) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.tanahSamar,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Petak Terkunci',
              style: AppTypography.tampilanKecil.copyWith(
                color: AppColors.tanah,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              level.finalTest?.lockReason ??
                  'Selesaikan petak sebelumnya terlebih dahulu.',
              textAlign: TextAlign.center,
              style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableState(BuildContext context, LevelDetail level) {
    final completedLessons = level.units.fold<int>(
      0,
      (sum, u) => sum + u.completedCount,
    );
    final totalLessons = level.units.fold<int>(
      0,
      (sum, u) => sum + u.lessonCount,
    );
    final progress = totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

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
          'Estimasi: ${level.estimatedMinutes} menit',
          style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Progress Keseluruhan Petak
        if (progress > 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Keseluruhan',
                style: AppTypography.label.copyWith(
                  color: AppColors.tanahSamar,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.penuh),
                child: LinearProgressIndicator(
                  value: progress,
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
              unit: mock.UnitSummary(
                id: unit.unitId,
                title: unit.title,
                progress: unit.progress,
                status: _toUnitStatus(unit.status),
              ),
              onTap: () {
                if (_toUnitStatus(unit.status) != mock.UnitStatus.locked) {
                  context.push('/kelas/unit/${unit.unitId}');
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
    final finalTest = level.finalTest;
    final mock.FinalTestStatus finalTestStatus = finalTest == null
        ? mock.FinalTestStatus.locked
        : _toFinalTestStatus(finalTest.status);
    final bool isLocked = finalTestStatus == mock.FinalTestStatus.locked;
    final bool isCompleted = finalTestStatus == mock.FinalTestStatus.completed;

    return InkWell(
      onTap: isLocked
          ? null
          : () => context.push('/kelas/ujian/${level.levelId}'),
      borderRadius: BorderRadius.circular(AppRadius.sedang),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.garis.withValues(alpha: 0.3)
              : AppColors.padiSamar,
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
                isCompleted
                    ? Icons.check
                    : (isLocked ? Icons.lock : Icons.star),
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
                        : (isCompleted
                              ? 'Sudah diselesaikan'
                              : 'Siap dikerjakan'),
                    style: AppTypography.kecil.copyWith(
                      color: isLocked
                          ? AppColors.tanahSamar
                          : AppColors.tanahLemah,
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
