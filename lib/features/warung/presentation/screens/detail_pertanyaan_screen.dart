import 'package:flutter/material.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/warung/data/warung_mock_data.dart';
import 'package:tandur/features/warung/presentation/widgets/warung_widgets.dart';

/// Detail Pertanyaan & Balasan Berjenjang — DESAIN.md §4.10, rute `/warung/p/:id`.
class DetailPertanyaanScreen extends StatefulWidget {
  final String questionId;

  const DetailPertanyaanScreen({super.key, required this.questionId});

  @override
  State<DetailPertanyaanScreen> createState() => _DetailPertanyaanScreenState();
}

class _DetailPertanyaanScreenState extends State<DetailPertanyaanScreen> {
  late Question _question;
  late List<Reply> _replies;
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _question = WarungMockData.questionById(widget.questionId);
    _replies = List.of(WarungMockData.repliesFor(widget.questionId));
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _voteQuestion(int value) {
    setState(() => _question = _question.copyWith(score: _question.score + (value - _question.myVote), myVote: value));
  }

  void _kirimBalasan() {
    if (_replyController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Balasan minimal 10 karakter.')));
      return;
    }
    setState(() {
      _replies = [
        ..._replies,
        Reply(
          replyId: 'r${DateTime.now().millisecondsSinceEpoch}',
          body: _replyController.text.trim(),
          author: const Author(userId: 'me', fullName: 'Kamu'),
          createdAt: DateTime.now(),
        ),
      ];
      _replyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Pertanyaan'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.l),
                children: [
                  Text(_question.title, style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah)),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      LabelKomoditas(commodity: _question.commodity),
                      const SizedBox(width: AppSpacing.s),
                      if (_question.tags.isNotEmpty)
                        Text('· ${_question.tags.join(', ')}', style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar)),
                      if (_question.district != null)
                        Text(' · ${_question.district}', style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_question.author.fullName} · ${waktuRelatif(_question.createdAt)}',
                    style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(_question.body, style: AppTypography.isi.copyWith(color: AppColors.tanah)),
                  if (_question.photos.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: _question.photos
                          .map((_) => Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.s),
                                child: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: PhotoPlaceholder(radius: BorderRadius.circular(AppRadius.kecil)),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    children: [
                      KendaliSuara(score: _question.score, myVote: _question.myVote, onVote: _voteQuestion),
                      const SizedBox(width: AppSpacing.l),
                      const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.tanahSamar),
                      const SizedBox(width: 4),
                      Text('${_replies.length}', style: AppTypography.angka.copyWith(color: AppColors.tanahLemah)),
                      const Spacer(),
                      const Icon(Icons.share_outlined, size: 18, color: AppColors.tanahSamar),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const Divider(color: AppColors.garis),
                  const SizedBox(height: AppSpacing.m),
                  ..._replies.map((r) => ReplyTile(
                        reply: r,
                        onVote: (_) {},
                        onReply: () {},
                      )),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        style: AppTypography.isi.copyWith(color: AppColors.tanah),
                        decoration: InputDecoration(
                          hintText: 'Tulis balasan...',
                          hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
                          filled: true,
                          fillColor: AppColors.kertas,
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.penuh), borderSide: const BorderSide(color: AppColors.garis)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.penuh), borderSide: const BorderSide(color: AppColors.garis)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.penuh), borderSide: const BorderSide(color: AppColors.daun, width: 2)),
                        ),
                        onSubmitted: (_) => _kirimBalasan(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.daun),
                        icon: const Icon(Icons.arrow_upward, color: AppColors.kertas),
                        onPressed: _kirimBalasan,
                        tooltip: 'Kirim',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
