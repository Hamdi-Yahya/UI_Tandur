import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';
import 'package:tandur/features/kelas/presentation/widgets/gamification_widgets.dart';

class FinalTestScreen extends StatefulWidget {
  final String id;

  const FinalTestScreen({super.key, required this.id});

  @override
  State<FinalTestScreen> createState() => _FinalTestScreenState();
}

class _FinalTestScreenState extends State<FinalTestScreen> {
  late FinalTestDetail _test;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  
  // Gamification state
  int _lives = 3; 
  int _correctAnswers = 0;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    _test = FinalTestDetail.getMock(widget.id);
  }

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;
    
    final isCorrect = _selectedAnswerIndex == _test.questions[_currentQuestionIndex].correctAnswerIndex;
    if (isCorrect) {
      _correctAnswers++;
    } else {
      _lives--;
    }

    setState(() {
      _showFeedback = true;
    });

    if (_lives <= 0) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _finishTest();
        }
      });
    }
  }

  void _nextQuestion() {
    if (_lives <= 0) return;

    if (_currentQuestionIndex < _test.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _showFeedback = false;
      });
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    context.pushReplacement(
      '/kelas/ujian/${widget.id}/hasil', 
      extra: {
        'score': _correctAnswers, 
        'total': _test.questions.length,
        'passed': _lives > 0,
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _test.questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswerIndex == question.correctAnswerIndex;

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: AppBar(
        backgroundColor: AppColors.embun,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.tanahSamar),
          onPressed: () => context.pop(),
        ),
        title: LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _test.questions.length,
          backgroundColor: AppColors.garis,
          color: AppColors.daun,
          minHeight: 8,
          borderRadius: BorderRadius.circular(AppRadius.penuh),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Center(
              child: LivesIndicator(lives: _lives, maxLives: 3),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _test.title,
                style: AppTypography.label.copyWith(color: AppColors.tanahLemah),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                question.question,
                style: AppTypography.judul.copyWith(color: AppColors.tanah),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              ...List.generate(question.options.length, (index) {
                final isSelected = _selectedAnswerIndex == index;
                final isCorrectOption = index == question.correctAnswerIndex;
                
                Color borderColor = AppColors.garis;
                Color bgColor = AppColors.kertas;
                
                if (_showFeedback) {
                  if (isSelected && !isCorrectOption) {
                    borderColor = AppColors.cabai;
                    bgColor = AppColors.cabaiSamar;
                  } else if (isCorrectOption) {
                    borderColor = AppColors.daun;
                    bgColor = AppColors.daunSamar;
                  }
                } else if (isSelected) {
                  borderColor = AppColors.daun;
                  bgColor = AppColors.daunSamar;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: InkWell(
                    onTap: _showFeedback ? null : () {
                      setState(() {
                        _selectedAnswerIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppRadius.sedang),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(AppRadius.sedang),
                        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                      ),
                      child: Text(
                        question.options[index],
                        style: AppTypography.isi.copyWith(
                          color: _showFeedback && isSelected && !isCorrectOption 
                              ? AppColors.cabai 
                              : AppColors.tanah,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              const Spacer(),
              
              if (_showFeedback)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  margin: const EdgeInsets.only(bottom: AppSpacing.l),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.daunSamar : AppColors.cabaiSamar,
                    borderRadius: BorderRadius.circular(AppRadius.sedang),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.error,
                        color: isCorrect ? AppColors.daun : AppColors.cabai,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          isCorrect ? 'Tepat sekali!' : 'Jawaban salah. Nyawa -1',
                          style: AppTypography.isiTebal.copyWith(
                            color: isCorrect ? AppColors.daun : AppColors.cabai,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
              ElevatedButton(
                onPressed: _showFeedback 
                    ? (_lives > 0 ? _nextQuestion : null) 
                    : (_selectedAnswerIndex != null ? _submitAnswer : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showFeedback 
                      ? (isCorrect ? AppColors.daun : AppColors.cabai)
                      : AppColors.daun,
                  foregroundColor: AppColors.kertas,
                  disabledBackgroundColor: AppColors.garis,
                  disabledForegroundColor: AppColors.tanahSamar,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                  ),
                ),
                child: Text(
                  _showFeedback 
                      ? (_lives > 0 ? 'Lanjut' : 'Gagal') 
                      : 'Periksa', 
                  style: AppTypography.isiTebal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
