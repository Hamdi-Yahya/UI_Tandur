import 'package:flutter/material.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/warung/data/warung_models.dart';

String waktuRelatif(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}

/// Nilai string komoditas untuk ditampilkan (mis. ke [LabelKomoditas]);
/// `unknown` ditampilkan sebagai "Umum".
String apiKomoditas(Commodity c) =>
    c == Commodity.unknown ? 'UMUM' : c.apiValue;

/// Baris pertanyaan padat — DESAIN.md §4.9. Kendali suara di kiri, judul,
/// meta komoditas/label/jumlah balasan, dan penanda "Belum terjawab"/"Terjawab".
class QuestionListTile extends StatelessWidget {
  final CommunityQuestion question;
  final VoidCallback onTap;
  final ValueChanged<int> onVote;

  const QuestionListTile({
    super.key,
    required this.question,
    required this.onTap,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KendaliSuara(
              score: question.score,
              myVote: question.myVote,
              onVote: onVote,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.title,
                    style: AppTypography.isiTebal.copyWith(
                      color: AppColors.tanah,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      LabelKomoditas(
                        commodity: apiKomoditas(question.commodity),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      if (question.tags.isNotEmpty)
                        Expanded(
                          child: Text(
                            '${question.tags.join(', ')} · ${question.replyCount} balasan',
                            style: AppTypography.kecil.copyWith(
                              color: AppColors.tanahSamar,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            '${question.replyCount} balasan',
                            style: AppTypography.kecil.copyWith(
                              color: AppColors.tanahSamar,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    question.isAnswered
                        ? '✓ Terjawab · ${waktuRelatif(question.createdAt)}'
                        : 'Belum terjawab · ${waktuRelatif(question.createdAt)}',
                    style: AppTypography.kecil.copyWith(
                      color: question.isAnswered
                          ? AppColors.terong
                          : AppColors.padi,
                      fontWeight: FontWeight.w600,
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

/// Satu balasan dalam pohon berjenjang — DESAIN.md §4.10.
/// Callback membawa [CommunityReply] yang bersangkutan supaya pohon balasan
/// bersarang tetap menyasar balasan yang benar.
class ReplyTile extends StatelessWidget {
  final CommunityReply reply;
  final void Function(CommunityReply reply, int value) onVote;
  final ValueChanged<CommunityReply> onReply;
  final ValueChanged<CommunityReply>? onLoadMore;
  final ValueChanged<CommunityReply>? onToggleBest;
  final ValueChanged<CommunityReply>? onReport;

  const ReplyTile({
    super.key,
    required this.reply,
    required this.onVote,
    required this.onReply,
    this.onLoadMore,
    this.onToggleBest,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final indent = reply.depth * AppSpacing.xl;
    final content = Container(
      margin: EdgeInsets.only(left: indent, bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: reply.isBestAnswer ? AppColors.terongSamar : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.kecil),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reply.isBestAnswer)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppColors.terong,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'JAWABAN TERBAIK',
                    style: AppTypography.label.copyWith(
                      color: AppColors.terong,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            reply.body,
            style: AppTypography.isi.copyWith(color: AppColors.tanah),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Text(
                reply.author.fullName,
                style: AppTypography.isiTebal.copyWith(
                  color: AppColors.tanah,
                  fontSize: 13,
                ),
              ),
              if (reply.author.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 14, color: AppColors.terong),
              ],
              const SizedBox(width: AppSpacing.s),
              InkWell(
                onTap: () => onVote(reply, reply.myVote == 1 ? 0 : 1),
                child: Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: reply.myVote == 1
                      ? AppColors.daun
                      : AppColors.tanahSamar,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${reply.score}',
                style: AppTypography.angka.copyWith(
                  color: AppColors.tanahLemah,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => onVote(reply, reply.myVote == -1 ? 0 : -1),
                child: Icon(
                  Icons.arrow_downward,
                  size: 14,
                  color: reply.myVote == -1
                      ? AppColors.cabai
                      : AppColors.tanahSamar,
                ),
              ),
              if (onToggleBest != null) ...[
                const SizedBox(width: AppSpacing.m),
                InkWell(
                  onTap: () => onToggleBest!(reply),
                  child: Icon(
                    reply.isBestAnswer
                        ? Icons.verified
                        : Icons.workspace_premium_outlined,
                    size: 15,
                    color: reply.isBestAnswer
                        ? AppColors.terong
                        : AppColors.tanahSamar,
                  ),
                ),
              ],
              if (onReport != null) ...[
                const SizedBox(width: AppSpacing.m),
                InkWell(
                  onTap: () => onReport!(reply),
                  child: const Icon(
                    Icons.flag_outlined,
                    size: 14,
                    color: AppColors.tanahSamar,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.m),
              InkWell(
                onTap: () => onReply(reply),
                child: Text(
                  'Balas',
                  style: AppTypography.kecil.copyWith(
                    color: AppColors.daun,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (reply.hasMoreChildren && onLoadMore != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: InkWell(
                onTap: () => onLoadMore!(reply),
                child: Text(
                  'Muat lebih banyak balasan',
                  style: AppTypography.kecil.copyWith(
                    color: AppColors.daun,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (reply.children.isEmpty) return content;

    // Balasan berjenjang maksimal tiga tingkat, sisanya dilipat (DESAIN.md §4.10).
    if (reply.depth >= 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          Padding(
            padding: EdgeInsets.only(left: indent + AppSpacing.xl),
            child: Text(
              '${reply.children.length} balasan lagi ▾',
              style: AppTypography.kecil.copyWith(color: AppColors.daun),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        ...reply.children.map(
          (c) => ReplyTile(
            reply: c,
            onVote: onVote,
            onReply: onReply,
            onLoadMore: onLoadMore,
            onToggleBest: onToggleBest,
            onReport: onReport,
          ),
        ),
      ],
    );
  }
}
