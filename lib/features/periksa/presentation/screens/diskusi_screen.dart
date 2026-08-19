import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_models.dart';
import 'package:tandur/features/periksa/data/periksa_repository.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Layar Diskusi dengan Asisten — DESAIN.md §4.7. Backend mengalirkan jawaban
/// lewat SSE (CATATAN_FE_FLUTTER.md §6); kuota 15 percakapan/hari dan jeda
/// model ditegakkan di sisi server.
///
/// Alur muat: `GET /api/scans/:id` dulu untuk konteks + `discussionId` bila
/// percakapan sudah pernah dibuat; kalau belum, `POST /api/scans/:id/discussions`
/// (409 dihindari dengan mengecek `hasDiscussion` dari respons pindai).
class DiskusiScreen extends ConsumerStatefulWidget {
  final String scanId;

  const DiskusiScreen({super.key, required this.scanId});

  @override
  ConsumerState<DiskusiScreen> createState() => _DiskusiScreenState();
}

class _DiskusiScreenState extends ConsumerState<DiskusiScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = true;
  String? _error;
  String _discussionId = '';
  String _diagnosis = '';
  double _confidence = 0;
  int _daysAfterPlanting = 0;
  List<DiscussionMessage> _messages = [];
  List<String> _suggestions = [];
  bool _isReplying = false;
  int? _sisaKuota;
  StreamSubscription<DiscussionSseEvent>? _sub;
  String _streamingMessageId = '';
  String _streamingText = '';
  List<Citation> _pendingCitations = [];
  final Map<String, bool> _rateChoice = {};

  @override
  void initState() {
    super.initState();
    _muatDiskusi();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _muatDiskusi() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(periksaRepositoryProvider);
      final scan = await repo.getScan(widget.scanId);
      _diagnosis = scan.primary?.displayName ?? diagnosisLabel(scan.primary?.label ?? '');
      _confidence = scan.primary?.confidence ?? 0;
      _daysAfterPlanting = scan.daysAfterPlanting ?? 0;

      final bool sudahAda = scan.hasDiscussion && (scan.discussionId?.isNotEmpty ?? false);
      if (sudahAda) {
        final detail = await repo.getDiscussion(scan.discussionId!);
        _discussionId = detail.discussionId;
        _messages = List.of(detail.messages);
      } else {
        final started = await repo.createDiscussion(widget.scanId);
        _discussionId = started.discussionId;
        _suggestions = List.of(started.suggestedPrompts);
      }

      try {
        final quota = await repo.getDiscussionQuota();
        _sisaKuota = quota.remaining;
      } catch (_) {
        // Kuota opsional di UI — gagal dibaca tidak menghalangi chat.
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _kirim(String text) {
    final pesan = text.trim();
    if (pesan.isEmpty || _isReplying || _discussionId.isEmpty || (_sisaKuota ?? 1) <= 0) return;
    setState(() {
      _messages.add(DiscussionMessage(messageId: 'user-${_messages.length + 1}', role: MessageRole.user, content: pesan));
      _controller.clear();
      _isReplying = true;
      _streamingMessageId = '';
      _streamingText = '';
      _pendingCitations = [];
    });
    _gulirKeBawah();

    _sub = ref
        .read(periksaRepositoryProvider)
        .sendMessage(_discussionId, pesan)
        .listen(_terimaSse, onError: (Object e) {
      if (!mounted) return;
      _selesaikanStreaming(
        finalMessage: DiscussionMessage(
          messageId: 'assistant-error',
          role: MessageRole.assistant,
          content: 'Maaf, jawaban tidak sampai. Coba sekali lagi.',
        ),
      );
    }, onDone: () {
      if (!mounted) return;
      _selesaikanStreaming();
    });
  }

  void _terimaSse(DiscussionSseEvent event) {
    switch (event) {
      case SseStartEvent():
        _streamingMessageId = event.messageId;
      case SseChunkEvent():
        if (!mounted) return;
        setState(() {
          _streamingText += event.text;
        });
        if (_messages.length > 1) _gulirKeBawahLembut();
      case SseCitationsEvent():
        _pendingCitations = event.citations;
      case SseSuggestionsEvent():
        if (!mounted) return;
        setState(() {
          _suggestions = event.prompts;
        });
      case SseDoneEvent():
        if (!mounted) return;
        _selesaikanStreaming(
          messageId: event.messageId.isEmpty ? _streamingMessageId : event.messageId,
          grounded: event.grounded,
        );
      case SseErrorEvent():
        if (!mounted) return;
        _selesaikanStreaming(
          finalMessage: DiscussionMessage(
            messageId: 'assistant-error',
            role: MessageRole.assistant,
            content: event.msg,
          ),
        );
    }
  }

  void _selesaikanStreaming({String? messageId, bool? grounded, DiscussionMessage? finalMessage}) {
    if (!_isReplying) return;
    final pesanAkhir = finalMessage ??
        DiscussionMessage(
          messageId: messageId ?? _streamingMessageId,
          role: MessageRole.assistant,
          content: _streamingText,
          citations: _pendingCitations,
          grounded: grounded,
        );
    setState(() {
      _messages = [
        ..._messages,
        pesanAkhir,
      ];
      _isReplying = false;
      _streamingMessageId = '';
      _streamingText = '';
      _pendingCitations = [];
    });
    _gulirKeBawah();
  }

  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _gulirKeBawahLembut() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> _nilai(String messageId, bool helpful) async {
    try {
      await ref.read(periksaRepositoryProvider).rateMessage(messageId, helpful: helpful);
      if (!mounted) return;
      setState(() {
        _rateChoice[messageId] = helpful;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Diskusi'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? KeadaanGalat(message: _error!, onRetry: _muatDiskusi)
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                          decoration: BoxDecoration(
                            color: AppColors.kertas,
                            borderRadius: BorderRadius.circular(AppRadius.sedang),
                            border: Border.all(color: AppColors.garis),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.image_outlined, size: 18, color: AppColors.tanahSamar),
                              const SizedBox(width: AppSpacing.s),
                              Expanded(
                                child: Text(
                                  '$_diagnosis · ${(_confidence * 100).toStringAsFixed(0)}% · ${formatHst(_daysAfterPlanting)}',
                                  style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.l),
                          itemCount: _messages.length + (_isReplying ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                          itemBuilder: (context, index) {
                            if (index >= _messages.length) {
                              return GelembungPesan(
                                content: _streamingText.isEmpty ? 'Sedang mengetik' : _streamingText,
                                isUser: false,
                                isStreaming: true,
                              );
                            }
                            final m = _messages[index];
                            final isUser = m.role == MessageRole.user;
                            return Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                GelembungPesan(content: m.content, isUser: isUser),
                                if (!isUser && m.citations.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.s),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.78,
                                    child: Column(
                                      children: m.citations
                                          .map((c) => Padding(
                                                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                                child: KartuRujukan(
                                                    title: c.title, publisher: c.publisher, year: c.year, page: c.page, url: c.url),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                                if (!isUser && m.messageId.isNotEmpty && !m.messageId.startsWith('assistant-error')) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 18,
                                        icon: Icon(
                                          Icons.thumb_up_outlined,
                                          color: _rateChoice[m.messageId] == true ? AppColors.daun : AppColors.tanahSamar,
                                        ),
                                        onPressed: () => _nilai(m.messageId, true),
                                        tooltip: 'Jawaban membantu',
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 18,
                                        icon: Icon(
                                          Icons.thumb_down_outlined,
                                          color: _rateChoice[m.messageId] == false ? AppColors.cabai : AppColors.tanahSamar,
                                        ),
                                        onPressed: () => _nilai(m.messageId, false),
                                        tooltip: 'Jawaban kurang tepat',
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      if (_sisaKuota != null && _sisaKuota! <= 3)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _sisaKuota! <= 0
                                  ? 'Kuota pertanyaan hari ini habis. Lanjut besok ya.'
                                  : 'Sisa $_sisaKuota pertanyaan hari ini.',
                              style: AppTypography.kecil.copyWith(color: AppColors.cabai),
                            ),
                          ),
                        ),
                      if (_suggestions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: AppSpacing.s,
                              runSpacing: AppSpacing.s,
                              children: _suggestions.map((s) => ChipSaran(label: s, onTap: () => _kirim(s))).toList(),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.l),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: AppTypography.isi.copyWith(color: AppColors.tanah),
                                decoration: InputDecoration(
                                  hintText: 'Tulis pertanyaan...',
                                  hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
                                  filled: true,
                                  fillColor: AppColors.kertas,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.l, vertical: AppSpacing.m),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                                    borderSide: const BorderSide(color: AppColors.garis),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                                    borderSide: const BorderSide(color: AppColors.garis),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                                    borderSide: const BorderSide(color: AppColors.daun, width: 2),
                                  ),
                                ),
                                onSubmitted: _kirim,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: IconButton.filled(
                                style: IconButton.styleFrom(backgroundColor: AppColors.daun),
                                icon: const Icon(Icons.arrow_upward, color: AppColors.kertas),
                                onPressed: () => _kirim(_controller.text),
                                tooltip: 'Kirim',
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