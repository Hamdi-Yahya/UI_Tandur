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
import 'package:tandur/features/kelas/presentation/widgets/lesson_block_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// AppBar materi: judul dari kurikulum bisa panjang, jadi dibatasi satu baris
/// supaya tidak meluber keluar toolbar.
AppBar buildLessonAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: AppColors.embun,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.tanah),
      onPressed: () => context.pop(),
      tooltip: 'Kembali',
    ),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.judul.copyWith(color: AppColors.tanah),
    ),
    centerTitle: true,
  );
}

class LessonVideoScreen extends StatefulWidget {
  final LessonDetail lesson;
  final LearningRepository repository;

  /// Pembuka tautan; dapat diganti pada pengujian.
  final Future<bool> Function(Uri url)? launcher;

  const LessonVideoScreen({
    super.key,
    required this.lesson,
    required this.repository,
    this.launcher,
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
    _elapsedSeconds = widget.lesson.lastPositionSeconds;
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

  /// URL tonton video. Kurikulum baru memakai embed YouTube, sementara materi
  /// lama bisa saja masih memberi berkas video langsung.
  Uri? get _watchUrl {
    final id = widget.lesson.youtubeVideoId;
    if (id != null && id.isNotEmpty) {
      return Uri.parse('https://www.youtube.com/watch?v=$id');
    }
    final direct = widget.lesson.videoUrl720p ?? widget.lesson.videoUrl360p;
    if (direct != null && direct.isNotEmpty) return Uri.tryParse(direct);
    return null;
  }

  Future<void> _openVideo() async {
    final url = _watchUrl;
    if (url == null) return;
    final launcher =
        widget.launcher ??
        (Uri u) => launchUrl(u, mode: LaunchMode.externalApplication);
    final opened = await launcher(url);
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tidak bisa membuka video. Coba lagi nanti.'),
        backgroundColor: AppColors.tanah,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _finish() async {
    _positionTimer?.cancel();
    try {
      final completion = await widget.repository.completeLesson(
        widget.lesson.lessonId,
        watchedPercent: 100,
        durationSeconds: _elapsedSeconds,
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
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    // fire-and-forget: posisi terakhir disimpan best-effort.
    unawaited(_savePosition());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final youtubeId = lesson.youtubeVideoId;
    final hasYoutube = youtubeId != null && youtubeId.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: buildLessonAppBar(context, lesson.title),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          VideoPoster(
            youtubeVideoId: youtubeId,
            onTap: _watchUrl == null ? null : _openVideo,
          ),
          const SizedBox(height: AppSpacing.m),

          if (_watchUrl != null)
            OutlinedButton.icon(
              onPressed: _openVideo,
              icon: const Icon(Icons.open_in_new, size: 18),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.daun,
                side: const BorderSide(color: AppColors.daun),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.penuh),
                ),
              ),
              label: Text(
                hasYoutube ? 'Tonton di YouTube' : 'Buka video',
                style: AppTypography.isiTebal,
              ),
            ),

          if (!lesson.isOfflineCapable) ...[
            const SizedBox(height: AppSpacing.m),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 16,
                  color: AppColors.tanahSamar,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Video ini ditonton di sumbernya, jadi tidak ikut terunduh '
                    'untuk mode offline.',
                    style: AppTypography.kecil.copyWith(
                      color: AppColors.tanahSamar,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (lesson.transcript != null && lesson.transcript!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Transkrip',
              style: AppTypography.judul.copyWith(color: AppColors.tanah),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              lesson.transcript!,
              style: AppTypography.isi.copyWith(color: AppColors.tanah),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          // Atribusi kanal wajib tampil untuk video embed, terlepas ada atau
          // tidaknya transkrip.
          LessonSourceFooter(
            attribution: lesson.attribution,
            sourceReference: lesson.sourceReference,
            reviewedBy: lesson.reviewedBy,
          ),
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

/// Sampul video: thumbnail YouTube bila ada, kalau tidak kotak polos.
class VideoPoster extends StatelessWidget {
  const VideoPoster({
    super.key,
    required this.youtubeVideoId,
    required this.onTap,
  });

  final String? youtubeVideoId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final id = youtubeVideoId;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sedang),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sedang),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (id != null && id.isNotEmpty)
              Image.network(
                'https://img.youtube.com/vi/$id/hqdefault.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => _fallback(),
              )
            else
              _fallback(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.tanah.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.kertas,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.tanah,
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

  late final List<List<LessonBlock>> _pages = groupLessonBlocks(
    widget.lesson.blocks,
  );

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
    if (_currentIndex < _pages.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finish();
    }
  }

  void _previousCard() {
    if (_currentIndex == 0) return;
    setState(() {
      _currentIndex--;
    });
  }

  Widget _selesaiButton() {
    return ElevatedButton(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.embun,
        appBar: buildLessonAppBar(context, widget.lesson.title),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Center(child: _selesaiButton()),
        ),
      );
    }

    final blocks = _pages[_currentIndex];
    final isLastCard = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: buildLessonAppBar(context, widget.lesson.title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _pages.length,
                      backgroundColor: AppColors.garis,
                      color: AppColors.daun,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(AppRadius.penuh),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Text(
                    '${_currentIndex + 1}/${_pages.length}',
                    style: AppTypography.kecil.copyWith(
                      color: AppColors.tanahLemah,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Kartu materi. Paragraf kurikulum bisa panjang, jadi isinya
              // selalu bisa digulir supaya tidak pernah meluber di layar kecil.
              Expanded(
                child: Container(
                  width: double.infinity,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < blocks.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.l),
                          LessonBlockView(block: blocks[i]),
                        ],
                        if (isLastCard) ...[
                          const SizedBox(height: AppSpacing.xl),
                          LessonSourceFooter(
                            sourceReference: widget.lesson.sourceReference,
                            reviewedBy: widget.lesson.reviewedBy,
                            attribution: widget.lesson.attribution,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              Row(
                children: [
                  if (_currentIndex > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting ? null : _previousCard,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.tanahLemah,
                          side: const BorderSide(color: AppColors.garis),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.penuh,
                            ),
                          ),
                        ),
                        child: Text('Kembali', style: AppTypography.isiTebal),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
