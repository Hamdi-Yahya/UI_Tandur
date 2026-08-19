import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String id;

  const LessonScreen({super.key, required this.id});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  LessonDetail? _lesson;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _lesson = null;
      _errorMessage = null;
    });
    try {
      final lesson = await ref
          .read(learningRepositoryProvider)
          .getLesson(widget.id);
      if (!mounted) return;
      setState(() {
        _lesson = lesson;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.embun,
        body: KeadaanGalat(message: _errorMessage!, onRetry: _load),
      );
    }

    final lesson = _lesson;
    if (lesson == null) {
      return const Scaffold(
        backgroundColor: AppColors.embun,
        body: Center(child: CircularProgressIndicator(color: AppColors.daun)),
      );
    }

    if (lesson.type == LessonType.video) {
      return LessonVideoScreen(
        lesson: lesson,
        repository: ref.read(learningRepositoryProvider),
      );
    }
    return LessonCardScreen(
      lesson: lesson,
      repository: ref.read(learningRepositoryProvider),
    );
  }
}

class LessonVideoScreen extends StatefulWidget {
  final LessonDetail lesson;
  final LearningRepository repository;

  const LessonVideoScreen({
    super.key,
    required this.lesson,
    required this.repository,
  });

  @override
  State<LessonVideoScreen> createState() => _LessonVideoScreenState();
}

class _LessonVideoScreenState extends State<LessonVideoScreen> {
  Timer? _positionTimer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _positionTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _elapsedSeconds += 10;
      _savePosition();
    });
  }

  Future<void> _savePosition() async {
    try {
      await widget.repository.saveVideoPosition(
        widget.lesson.lessonId,
        _elapsedSeconds,
      );
    } on ApiException {
      // Abaikan kegagalan penyimpanan posisi; tidak menghalangi belajar.
    }
  }

  Future<void> _finish() async {
    _positionTimer?.cancel();
    try {
      final completion = await widget.repository.completeLesson(
        widget.lesson.lessonId,
        watchedPercent: 100,
        durationSeconds: _elapsedSeconds,
      );
      _savePosition();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+${completion.xpEarned} XP didapat!'),
          backgroundColor: AppColors.daun,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.tanah,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    try {
      widget.repository.saveVideoPosition(
        widget.lesson.lessonId,
        _elapsedSeconds,
      );
    } on ApiException {
      // fire-and-forget: posisi terakhir disimpan best-effort.
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

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
              child: Icon(
                Icons.play_circle_outline,
                color: AppColors.kertas,
                size: 64,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          if (lesson.videoUrl360p != null || lesson.videoUrl720p != null) ...[
            Text(
              'Sumber Video',
              style: AppTypography.label.copyWith(color: AppColors.tanahSamar),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              lesson.videoUrl360p ?? lesson.videoUrl720p ?? '',
              style: AppTypography.kecil.copyWith(color: AppColors.daun),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          if (lesson.transcript != null && lesson.transcript!.isNotEmpty) ...[
            Text(
              'Transkrip',
              style: AppTypography.judul.copyWith(color: AppColors.tanah),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              lesson.transcript!,
              style: AppTypography.isi.copyWith(color: AppColors.tanah),
            ),
            const SizedBox(height: AppSpacing.m),
            if (lesson.attribution != null && lesson.attribution!.isNotEmpty)
              Text(
                lesson.attribution!,
                style: AppTypography.kecil.copyWith(
                  color: AppColors.tanahLemah,
                ),
              ),
            if (lesson.reviewedBy != null && lesson.reviewedBy!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ditinjau oleh: ${lesson.reviewedBy}',
                style: AppTypography.kecil.copyWith(
                  color: AppColors.tanahLemah,
                ),
              ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: ElevatedButton(
            onPressed: _finish,
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
  final LessonDetail lesson;
  final LearningRepository repository;

  const LessonCardScreen({
    super.key,
    required this.lesson,
    required this.repository,
  });

  @override
  State<LessonCardScreen> createState() => _LessonCardScreenState();
}

class _LessonCardScreenState extends State<LessonCardScreen> {
  int _currentIndex = 0;
  bool _submitting = false;

  List<LessonBlock> get _cards => widget.lesson.blocks
      .where((b) => b.text != null || b.type == LessonBlockType.image)
      .toList();

  Future<void> _finish() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
    });
    try {
      final completion = await widget.repository.completeLesson(
        widget.lesson.lessonId,
        watchedPercent: 100,
        durationSeconds: 0,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+${completion.xpEarned} XP didapat!'),
          backgroundColor: AppColors.daun,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
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

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
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
        body: Center(
          child: ElevatedButton(
            onPressed: _submitting ? null : _finish,
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
      );
    }

    final currentCard = _cards[_currentIndex];
    final isLastCard = _currentIndex == _cards.length - 1;

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
              value: (_currentIndex + 1) / _cards.length,
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
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentCard.type == LessonBlockType.image) ...[
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppColors.daunSamar,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '[GAMBAR]',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.daun,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    Text(
                      currentCard.text ?? '',
                      textAlign: TextAlign.center,
                      style: AppTypography.isiBesar.copyWith(
                        color: AppColors.tanah,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            ElevatedButton(
              onPressed: _submitting ? null : _nextCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.daun,
                foregroundColor: AppColors.kertas,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.penuh),
                ),
              ),
              child: Text(
                isLastCard ? 'Selesai Belajar' : 'Lanjut',
                style: AppTypography.isiTebal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
