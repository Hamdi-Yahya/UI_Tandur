import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/warung/data/warung_models.dart';
import 'package:tandur/features/warung/data/warung_repository.dart';
import 'package:tandur/features/warung/presentation/widgets/warung_widgets.dart';

/// Detail Pertanyaan & Balasan Berjenjang — DESAIN.md §4.10, rute `/warung/p/:id`.
/// Sumber data: GET /api/community/questions/:id + :id/replies; suara,
/// balasan (termasuk bersarang lewat `parentId`), jawaban terbaik
/// (POST/DELETE /replies/:id/best), laporan, dan muat balasan lanjutan
/// (/replies/:id/children) semuanya ke backend.
class DetailPertanyaanScreen extends ConsumerStatefulWidget {
  final String questionId;

  const DetailPertanyaanScreen({super.key, required this.questionId});

  @override
  ConsumerState<DetailPertanyaanScreen> createState() =>
      _DetailPertanyaanScreenState();
}

class _DetailPertanyaanScreenState
    extends ConsumerState<DetailPertanyaanScreen> {
  final _replyController = TextEditingController();

  CommunityQuestion? _question;
  CommunityReply? _bestAnswer;
  List<CommunityReply> _replies = [];
  String? _error;
  bool _isLoading = true;
  bool _isSubmitting = false;
  QuestionSort _replySort = QuestionSort.top;
  CommunityReply? _replyingTo;
  final Map<String, String> _childrenCursors = {};

  WarungRepository get _repo => ref.read(warungRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    setState(() {
      _isLoading = _question == null;
      _error = null;
    });
    try {
      final question = await _repo.getQuestion(widget.questionId);
      final replies = await _repo.listReplies(
        widget.questionId,
        sort: _replySort,
      );
      if (!mounted) return;
      setState(() {
        _question = question;
        _bestAnswer = replies.bestAnswer;
        // Jawaban terbaik sudah tampil terpisah — hindari duplikasi di pohon.
        _replies = replies.items
            .where(
              (r) =>
                  replies.bestAnswer == null ||
                  r.replyId != replies.bestAnswer!.replyId,
            )
            .toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Perbarui satu balasan di pohon tanpa mutasi — balasan baru dihasilkan
  /// lewat [CommunityReply.copyWith].
  List<CommunityReply> _updateReply(
    List<CommunityReply> replies,
    String replyId,
    CommunityReply Function(CommunityReply) update,
  ) {
    return replies.map((r) {
      if (r.replyId == replyId) return update(r);
      if (r.children.isNotEmpty) {
        return r.copyWith(children: _updateReply(r.children, replyId, update));
      }
      return r;
    }).toList();
  }

  Future<void> _voteQuestion(int value) async {
    final q = _question;
    if (q == null) return;
    try {
      final result = await _repo.voteQuestion(q.questionId, value);
      if (!mounted) return;
      setState(
        () =>
            _question = q.copyWith(score: result.score, myVote: result.myVote),
      );
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  Future<void> _voteReply(CommunityReply reply, int value) async {
    try {
      final result = await _repo.voteReply(reply.replyId, value);
      if (!mounted) return;
      setState(() {
        _replies = _updateReply(
          _replies,
          reply.replyId,
          (r) => r.copyWith(score: result.score, myVote: result.myVote),
        );
        if (_bestAnswer?.replyId == reply.replyId) {
          _bestAnswer = _bestAnswer!.copyWith(
            score: result.score,
            myVote: result.myVote,
          );
        }
      });
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  Future<void> _kirimBalasan() async {
    final body = _replyController.text.trim();
    if (body.length < 10) {
      _snack('Balasan minimal 10 karakter.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _repo.createReply(
        widget.questionId,
        body: body,
        parentId: _replyingTo?.replyId,
      );
      if (!mounted) return;
      _replyController.clear();
      setState(() {
        _isSubmitting = false;
        _replyingTo = null;
      });
      await _muat();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _snack(e.message);
    }
  }

  Future<void> _muatAnak(CommunityReply parent) async {
    try {
      final page = await _repo.loadMoreChildren(
        parent.replyId,
        limit: 10,
        cursor: _childrenCursors[parent.replyId],
      );
      if (!mounted) return;
      setState(() {
        final perbarui = _appendChildren(page);
        _replies = _updateReply(_replies, parent.replyId, perbarui);
        if (_bestAnswer?.replyId == parent.replyId) {
          _bestAnswer = perbarui(_bestAnswer!);
        }
      });
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  CommunityReply Function(CommunityReply) _appendChildren(
    CursorPage<CommunityReply> page,
  ) {
    return (r) {
      if (page.nextCursor == null) {
        _childrenCursors.remove(r.replyId);
        return r.copyWith(
          children: [...r.children, ...page.items],
          childCount: r.childCount + page.items.length,
          hasMoreChildren: false,
        );
      }
      _childrenCursors[r.replyId] = page.nextCursor!;
      return r.copyWith(
        children: [...r.children, ...page.items],
        childCount: r.childCount + page.items.length,
      );
    };
  }

  Future<void> _toggleBest(CommunityReply reply) async {
    try {
      if (reply.isBestAnswer) {
        await _repo.unmarkBest(reply.replyId);
      } else {
        await _repo.markBest(reply.replyId);
      }
      if (!mounted) return;
      await _muat();
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  String _labelAlasan(ReportReason r) {
    switch (r) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Pelecehan';
      case ReportReason.misinformation:
        return 'Informasi salah';
      case ReportReason.offTopic:
        return 'Di luar topik';
      case ReportReason.other:
      case ReportReason.unknown:
        return 'Lainnya';
    }
  }

  Future<void> _bukaLaporan(ReportTargetType target, String targetId) async {
    final reason = await showModalBottomSheet<ReportReason>(
      context: context,
      backgroundColor: AppColors.kertas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.besar),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Text(
                'Laporkan konten ini',
                style: AppTypography.judul.copyWith(color: AppColors.tanah),
              ),
            ),
            ...ReportReason.values
                .where((r) => r != ReportReason.unknown)
                .map(
                  (r) => ListTile(
                    title: Text(
                      _labelAlasan(r),
                      style: AppTypography.isi.copyWith(color: AppColors.tanah),
                    ),
                    onTap: () => Navigator.of(context).pop(r),
                  ),
                ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
    if (reason == null || !mounted) return;
    try {
      await _repo.report(
        targetType: target,
        targetId: targetId,
        reason: reason,
      );
      if (!mounted) return;
      _snack('Laporan terkirim. Tim kami akan meninjau.');
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  Widget _tile(CommunityReply reply) {
    final q = _question;
    return ReplyTile(
      reply: reply,
      onVote: (r, v) => _voteReply(r, v),
      onReply: (r) => setState(() => _replyingTo = r),
      onLoadMore: (r) => _muatAnak(r),
      onToggleBest: q?.canEdit == true ? (r) => _toggleBest(r) : null,
      onReport: (r) => _bukaLaporan(ReportTargetType.reply, r.replyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Pertanyaan'),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.daun),
      );
    }
    final q = _question;
    if (_error != null || q == null) {
      return KeadaanGalat(
        message: _error ?? 'Pertanyaan tidak ditemukan.',
        onRetry: _muat,
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                q.title,
                style: AppTypography.tampilanKecil.copyWith(
                  color: AppColors.tanah,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  LabelKomoditas(commodity: apiKomoditas(q.commodity)),
                  const SizedBox(width: AppSpacing.s),
                  if (q.tags.isNotEmpty)
                    Text(
                      '· ${q.tags.join(', ')}',
                      style: AppTypography.kecil.copyWith(
                        color: AppColors.tanahSamar,
                      ),
                    ),
                  if (q.district != null)
                    Text(
                      ' · ${q.district}',
                      style: AppTypography.kecil.copyWith(
                        color: AppColors.tanahSamar,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${q.author.fullName} · ${waktuRelatif(q.createdAt)}',
                style: AppTypography.kecil.copyWith(
                  color: AppColors.tanahSamar,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                q.body,
                style: AppTypography.isi.copyWith(color: AppColors.tanah),
              ),
              if (q.photos.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: q.photos
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.s),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: PhotoPlaceholder(
                              radius: BorderRadius.circular(AppRadius.kecil),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  KendaliSuara(
                    score: q.score,
                    myVote: q.myVote,
                    onVote: _voteQuestion,
                  ),
                  const SizedBox(width: AppSpacing.l),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.tanahSamar,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${q.replyCount}',
                    style: AppTypography.angka.copyWith(
                      color: AppColors.tanahLemah,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.tanahSamar,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  InkWell(
                    onTap: () =>
                        _bukaLaporan(ReportTargetType.question, q.questionId),
                    child: const Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: AppColors.tanahSamar,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              const Divider(color: AppColors.garis),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Text(
                    'Balasan',
                    style: AppTypography.isiTebal.copyWith(
                      color: AppColors.tanah,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<QuestionSort>(
                    value: _replySort,
                    underline: const SizedBox.shrink(),
                    style: AppTypography.kecil.copyWith(color: AppColors.tanah),
                    items: const [
                      DropdownMenuItem(
                        value: QuestionSort.top,
                        child: Text('Teratas'),
                      ),
                      DropdownMenuItem(
                        value: QuestionSort.newest,
                        child: Text('Terbaru'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _replySort = v);
                      _muat();
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              if (_bestAnswer != null) _tile(_bestAnswer!),
              ..._replies.map(_tile),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyingTo != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Membalas ${_replyingTo!.author.fullName}',
                          style: AppTypography.kecil.copyWith(
                            color: AppColors.daun,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.tanahSamar,
                        ),
                        onPressed: () => setState(() => _replyingTo = null),
                        tooltip: 'Batalkan balasan',
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        style: AppTypography.isi.copyWith(
                          color: AppColors.tanah,
                        ),
                        decoration: InputDecoration(
                          hintText: _replyingTo != null
                              ? 'Tulis balasan...'
                              : 'Tulis balasan...',
                          hintStyle: AppTypography.isi.copyWith(
                            color: AppColors.tanahSamar,
                          ),
                          filled: true,
                          fillColor: AppColors.kertas,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l,
                            vertical: AppSpacing.m,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.penuh,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.garis,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.penuh,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.garis,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.penuh,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.daun,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _kirimBalasan(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.daun,
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.kertas,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward,
                                color: AppColors.kertas,
                              ),
                        onPressed: _isSubmitting ? null : _kirimBalasan,
                        tooltip: 'Kirim',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
