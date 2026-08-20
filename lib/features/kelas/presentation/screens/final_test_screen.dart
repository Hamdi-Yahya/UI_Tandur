import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';

class FinalTestScreen extends ConsumerStatefulWidget {
  final String id;

  const FinalTestScreen({super.key, required this.id});

  @override
  ConsumerState<FinalTestScreen> createState() => _FinalTestScreenState();
}

class _FinalTestScreenState extends ConsumerState<FinalTestScreen> {
  FinalTestDetail? _test;
  String? _errorMessage;
  bool _starting = true;
  bool _submitting = false;
  int _currentQuestionIndex = 0;
  final Map<String, String> _selectedAnswers = {};
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _errorMessage = null;
    });
    try {
      final test = await ref
          .read(learningRepositoryProvider)
          .startFinalTest(widget.id);
      if (!mounted) return;
      setState(() {
        _test = test;
        _starting = false;
      });
      _startCountdown(test);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _starting = false;
      });
    }
  }

  void _startCountdown(FinalTestDetail test) {
    final expiresAt = test.expiresAt;
    if (expiresAt == null) return;
    _remaining = expiresAt.difference(DateTime.now().toUtc());
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = expiresAt.difference(DateTime.now().toUtc());
      if (remaining <= Duration.zero) {
        _countdownTimer?.cancel();
        _remaining = Duration.zero;
        setState(() {});
        _submitAll(); // Waktu habis: kumpulkan apa adanya.
      } else {
        setState(() {
          _remaining = remaining;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  bool get _hasAnsweredCurrent =>
      _selectedAnswers.containsKey(_currentQuestion.questionId);

  QuizQuestion get _currentQuestion => _test!.questions[_currentQuestionIndex];

  void _nextQuestion() {
    if (_currentQuestionIndex < _test!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  Future<void> _submitAll() async {
    if (_submitting) return;
    final test = _test;
    if (test == null) return;

    setState(() {
      _submitting = true;
    });
    try {
      final result = await ref
          .read(learningRepositoryProvider)
          .submitFinalTest(
            widget.id,
            attemptId: test.attemptId,
            answers: test.questions
                .map(
                  (q) => {
                    'questionId': q.questionId,
                    'answer': _selectedAnswers[q.questionId],
                  },
                )
                .toList(),
          );
      if (!mounted) return;
      context.pushReplacement(
        '/kelas/ujian/${widget.id}/hasil',
        extra: {
          'scorePercent': result.score,
          'correctCount': result.correctCount,
          'total': result.totalCount,
          'xpEarned': result.xpEarned,
          'stars': result.stars,
          'passed': result.passed,
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

  String _formatRemaining(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.embun,
        appBar: _buildAppBar(null, 0),
        body: KeadaanGalat(message: _errorMessage!, onRetry: _start),
      );
    }

    final test = _test;
    if (_starting || test == null) {
      return const Scaffold(
        backgroundColor: AppColors.embun,
        body: Center(child: CircularProgressIndicator(color: AppColors.daun)),
      );
    }

    final question = test.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == test.questions.length - 1;
    final selectedKey = _selectedAnswers[question.questionId];
    final allAnswered = test.questions.every(
      (q) => _selectedAnswers.containsKey(q.questionId),
    );

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: _buildAppBar(test, test.questions.length),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ujian Akhir Petak',
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
                          onTap: _submitting || _remaining == Duration.zero
                              ? null
                              : () {
                                  setState(() {
                                    _selectedAnswers[question.questionId] =
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
                  'Masih ada soal belum dijawab: ${test.questions.length - _selectedAnswers.length} soal.',
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

  PreferredSizeWidget _buildAppBar(FinalTestDetail? test, int total) {
    final value = total == 0 ? 0.0 : (_currentQuestionIndex + 1) / total;
    final showCountdown = test?.expiresAt != null && _remaining > Duration.zero;
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
      actions: [
        if (showCountdown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Center(
              child: Text(
                _formatRemaining(_remaining),
                style: AppTypography.isiTebal.copyWith(
                  color: _remaining.inMinutes < 5
                      ? AppColors.cabai
                      : AppColors.daun,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
