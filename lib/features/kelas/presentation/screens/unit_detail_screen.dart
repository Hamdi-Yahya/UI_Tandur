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

class UnitDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const UnitDetailScreen({super.key, required this.id});

  @override
  ConsumerState<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends ConsumerState<UnitDetailScreen> {
  UnitLessons? _unit;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _unit = null;
      _errorMessage = null;
    });
    try {
      final unit = await ref
          .read(learningRepositoryProvider)
          .getUnitLessons(widget.id);
      if (!mounted) return;
      setState(() {
        _unit = unit;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  mock.LessonStatus _toLessonStatus(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        return mock.LessonStatus.locked;
      case NodeStatus.completed:
      case NodeStatus.perfect:
        return mock.LessonStatus.completed;
      case NodeStatus.available:
      case NodeStatus.inProgress:
        return mock.LessonStatus.available;
      case NodeStatus.unknown:
        return mock.LessonStatus.locked;
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

  /// Apakah tipe lesson ini berupa latihan (bukan materi bacaan/video).
  bool _isExercise(UnitLessonSummary lesson) {
    switch (lesson.type) {
      case LessonType.exerciseMcq:
      case LessonType.exerciseMatch:
      case LessonType.exerciseOrder:
      case LessonType.exerciseImage:
        return true;
      case LessonType.card:
      case LessonType.video:
      case LessonType.unknown:
        return false;
    }
  }

  /// Label durasi untuk kartu materi.
  String _formatDuration(UnitLessonSummary lesson) {
    final seconds = lesson.durationSeconds;
    if (seconds != null && seconds > 0) {
      final minutes = seconds ~/ 60;
      final rest = seconds % 60;
      return '$minutes:${rest.toString().padLeft(2, '0')}';
    }
    return '${lesson.estimatedMinutes} menit';
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
        ),
        title: Text(
          _unit?.title ?? '',
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

    final unit = _unit;
    if (unit == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.daun),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // Progres Unit
        Text(
          '${unit.progressPercent}% materi terselesaikan',
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
              lesson: mock.LessonSummary(
                id: lesson.lessonId,
                title: lesson.title,
                type: _isExercise(lesson)
                    ? mock.LessonType.latihan
                    : (lesson.type == LessonType.video
                          ? mock.LessonType.video
                          : mock.LessonType.kartu),
                duration: _formatDuration(lesson),
                status: _toLessonStatus(lesson.status),
                xpReward: lesson.xpReward,
              ),
              onTap: () {
                if (_toLessonStatus(lesson.status) ==
                    mock.LessonStatus.locked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Materi ini masih terkunci.'),
                      backgroundColor: AppColors.tanah,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                final route = _isExercise(lesson)
                    ? '/kelas/latihan/${lesson.lessonId}'
                    : '/kelas/lesson/${lesson.lessonId}';
                context.push(route);
              },
            ),
          );
        }),

        // Ujian Unit (Kuis Pemahaman). Kurikulum hanya memasang ujian di
        // sebagian unit, jadi kartunya disembunyikan kalau memang tidak ada
        // — sebelumnya kartu terkunci ini selalu tampil dan menyesatkan.
        if (unit.quiz != null) ...[
          const SizedBox(height: AppSpacing.m),
          _buildUnitQuizCard(context, unit.quiz!),
        ],
      ],
    );
  }

  Widget _buildUnitQuizCard(BuildContext context, UnitQuizSummary quiz) {
    final String quizId = quiz.quizId;
    final mock.FinalTestStatus quizStatus = _toFinalTestStatus(quiz.status);
    final bool isLocked = quizStatus == mock.FinalTestStatus.locked;
    final bool isCompleted = quizStatus == mock.FinalTestStatus.completed;

    return InkWell(
      onTap: isLocked
          ? null
          : () => context.push('/kelas/ujian-unit/$quizId'),
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
                    : (isLocked ? Icons.lock : Icons.assignment),
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
