import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';

class LessonScreen extends StatelessWidget {
  final String id;

  const LessonScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final lesson = LessonDetail.getMock(id);

    if (lesson is VideoLessonDetail) {
      return LessonVideoScreen(lesson: lesson);
    } else if (lesson is CardLessonDetail) {
      return LessonCardScreen(lesson: lesson);
    }
    
    return const Scaffold(body: Center(child: Text('Tipe materi tidak dikenal')));
  }
}

class LessonVideoScreen extends StatelessWidget {
  final VideoLessonDetail lesson;

  const LessonVideoScreen({super.key, required this.lesson});

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
          lesson.title,
          style: AppTypography.judul.copyWith(color: AppColors.tanah),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          // Video Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.tanah,
              borderRadius: BorderRadius.circular(AppRadius.sedang),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_outline, color: AppColors.kertas, size: 64),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Transkrip',
            style: AppTypography.judul.copyWith(color: AppColors.tanah),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            lesson.transcript,
            style: AppTypography.isi.copyWith(color: AppColors.tanah),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.daun,
              foregroundColor: AppColors.kertas,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.penuh),
              ),
            ),
            child: Text('Selesai Belajar', style: AppTypography.isiTebal),
          ),
        ),
      ),
    );
  }
}

class LessonCardScreen extends StatefulWidget {
  final CardLessonDetail lesson;

  const LessonCardScreen({super.key, required this.lesson});

  @override
  State<LessonCardScreen> createState() => _LessonCardScreenState();
}

class _LessonCardScreenState extends State<LessonCardScreen> {
  int _currentIndex = 0;

  void _nextCard() {
    if (_currentIndex < widget.lesson.cards.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      context.pop(); // Selesai materi
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = widget.lesson.cards[_currentIndex];
    final isLastCard = _currentIndex == widget.lesson.cards.length - 1;

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
          widget.lesson.title,
          style: AppTypography.judul.copyWith(color: AppColors.tanah),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.lesson.cards.length,
              backgroundColor: AppColors.garis,
              color: AppColors.daun,
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppRadius.penuh),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Kartu
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.kertas,
                  borderRadius: BorderRadius.circular(AppRadius.besar),
                  border: Border.all(color: AppColors.garis),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14241F1A),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration Placeholder
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.daunSamar,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '[ILLUSTRATION_PLACEHOLDER]',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: AppColors.daun),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      currentCard.content,
                      textAlign: TextAlign.center,
                      style: AppTypography.isiBesar.copyWith(color: AppColors.tanah),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            ElevatedButton(
              onPressed: _nextCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.daun,
                foregroundColor: AppColors.kertas,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.penuh),
                ),
              ),
              child: Text(isLastCard ? 'Selesai Belajar' : 'Lanjut', style: AppTypography.isiTebal),
            ),
          ],
        ),
      ),
    );
  }
}
