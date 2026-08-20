import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  final String id;

  const ExerciseScreen({super.key, required this.id});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  ExerciseDetail? _exercise;
  String? _errorMessage;
  int _currentQuestionIndex = 0;
  final Map<String, String> _selectedAnswers = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _exercise = null;
      _errorMessage = null;
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
    });
    try {
      final exercise = await ref
          .read(learningRepositoryProvider)
          .getExercise(widget.id);
      if (!mounted) return;
      setState(() {
        _exercise = exercise;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  bool get _hasAnsweredCurrent =>
      _selectedAnswers.containsKey(_currentQuestion.exerciseId);

  ExerciseQuestion get _currentQuestion =>
      _exercise!.questions[_currentQuestionIndex];

  void _nextQuestion() {
    if (_currentQuestionIndex < _exercise!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  Future<void> _submitAll() async {
    if (_submitting) return;
    final exercise = _exercise;
    if (exercise == null) return;

    setState(() {
      _submitting = true;
    });
    try {
      final result = await ref
          .read(learningRepositoryProvider)
          .submitExercise(
            exercise.lessonId,
            answers: exercise.questions
                .map(
                  (q) => {
                    'exerciseId': q.exerciseId,
                    'answer': _selectedAnswers[q.exerciseId],
                  },
                )
                .toList(),
            durationSeconds: 0,
          );
      if (!mounted) return;
      context.pushReplacement(
        '/kelas/latihan/${exercise.lessonId}/hasil',
        extra: {
          'correctCount': result.correctCount,
          'total': result.totalCount,
          'scorePercent': result.score,
          'xpEarned': result.xpEarned,
          'results': result.results,
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.tanah,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.embun,
        appBar: _buildAppBar(null),
        body: KeadaanGalat(message: _errorMessage!, onRetry: _load),
      );
    }

    final exercise = _exercise;
    if (exercise == null) {
      return Scaffold(
        backgroundColor: AppColors.embun,
        appBar: _buildAppBar(null),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.daun),
        ),
      );
    }

    if (exercise.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.embun,
        appBar: _buildAppBar(exercise),
        body: KeadaanGalat(
          message: 'Soal latihan belum tersedia untuk materi ini.',
          onRetry: _load,
        ),
      );
    }

    final question = exercise.questions[_currentQuestionIndex];
    final isLastQuestion =
        _currentQuestionIndex == exercise.questions.length - 1;
    final selectedKey = _selectedAnswers[question.exerciseId];
    final allAnswered = exercise.questions.every(
      (q) => _selectedAnswers.containsKey(q.exerciseId),
    );

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: _buildAppBar(exercise),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Latihan',
                style: AppTypography.label.copyWith(
                  color: AppColors.tanahLemah,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                question.prompt,
                style: AppTypography.judul.copyWith(color: AppColors.tanah),
              ),
              if (question.imageUrl != null &&
                  question.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.daunSamar,
                    borderRadius: BorderRadius.circular(AppRadius.sedang),
                  ),
                  child: const Center(
                    child: Text(
                      '[GAMBAR_SOAL]',
                      style: TextStyle(fontSize: 12, color: AppColors.daun),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

              Expanded(
                child: ListView(
                  children: [
                    ...question.options.map((option) {
                      final isSelected = option.key == selectedKey;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: InkWell(
                          onTap: _submitting
                              ? null
                              : () {
                                  setState(() {
                                    _selectedAnswers[question.exerciseId] =
                                        option.key;
                                  });
                                },
                          borderRadius: BorderRadius.circular(AppRadius.sedang),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.l),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.daunSamar
                                  : AppColors.kertas,
                              borderRadius: BorderRadius.circular(
                                AppRadius.sedang,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.daun
                                    : AppColors.garis,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              '${option.key}. ${option.text}',
                              style: AppTypography.isi.copyWith(
                                color: AppColors.tanah,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.m),

              if (isLastQuestion && !allAnswered)
                Text(
                  'Masih ada soal belum dijawab: ${exercise.questions.length - _selectedAnswers.length} soal.',
                  textAlign: TextAlign.center,
                  style: AppTypography.kecil.copyWith(
                    color: AppColors.tanahLemah,
                  ),
                ),

              ElevatedButton(
                onPressed: _submitting
                    ? null
                    : (isLastQuestion
                          ? (allAnswered ? _submitAll : null)
                          : (_hasAnsweredCurrent ? _nextQuestion : null)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.daun,
                  foregroundColor: AppColors.kertas,
                  disabledBackgroundColor: AppColors.garis,
                  disabledForegroundColor: AppColors.tanahSamar,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                  ),
                ),
                child: Text(
                  isLastQuestion ? 'Kumpulkan Jawaban' : 'Lanjut',
                  style: AppTypography.isiTebal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ExerciseDetail? exercise) {
    final total = exercise?.questions.length ?? 0;
    final value = total == 0 ? 0.0 : (_currentQuestionIndex + 1) / total;
    return AppBar(
      backgroundColor: AppColors.embun,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.tanahSamar),
        onPressed: () => context.pop(),
      ),
      title: LinearProgressIndicator(
        value: value,
        backgroundColor: AppColors.garis,
        color: AppColors.daun,
        minHeight: 8,
        borderRadius: BorderRadius.circular(AppRadius.penuh),
      ),
    );
  }
}
