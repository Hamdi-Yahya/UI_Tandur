import 'package:flutter/material.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_mock_data.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Layar Diskusi dengan Asisten — DESAIN.md §4.7. Backend sungguhan mengalirkan
/// jawaban lewat SSE (CATATAN_FE_FLUTTER.md §6); di tahap UI ini, balasan
/// asisten memakai data mock dan disimulasikan tampil sekaligus tanpa jaringan.
class DiskusiScreen extends StatefulWidget {
  final String scanId;

  const DiskusiScreen({super.key, required this.scanId});

  @override
  State<DiskusiScreen> createState() => _DiskusiScreenState();
}

class _DiskusiScreenState extends State<DiskusiScreen> {
  late final List<DiscussionMessage> _messages;
  late List<String> _suggestions;
  final _controller = TextEditingController();
  bool _isReplying = false;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _messages = List.of(PeriksaMockData.discussion.messages);
    _suggestions = List.of(PeriksaMockData.discussion.suggestedPrompts);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _kirim(String text) {
    if (text.trim().isEmpty || _isReplying) return;
    setState(() {
      _messages.add(DiscussionMessage(messageId: 'u${_seq++}', role: MessageRole.user, content: text.trim()));
      _controller.clear();
      _isReplying = true;
    });
    // Kuota 15 percakapan/hari dan balasan pertama <3 detik ditegakkan backend
    // (CATATAN_FE_FLUTTER.md §6). Di sini cukup jeda kosmetik singkat.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(DiscussionMessage(
          messageId: 'a${_seq++}',
          role: MessageRole.assistant,
          content:
              'Untuk pertanyaan itu, tetap pantau perkembangan daun beberapa hari ke depan dan bandingkan '
              'dengan riwayat pindai sebelumnya. Kalau gejalanya melebar, pertimbangkan bertanya ke Warung Tani.',
          citations: const [Citation(title: 'Petunjuk Teknis Budidaya Cabai', publisher: 'Balitsa', year: 2023, page: 34)],
        ));
        _suggestions = const ['Berapa lama sampai pulih?'];
        _isReplying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctx = PeriksaMockData.discussion;
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Diskusi'),
      body: SafeArea(
        child: Column(
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
                        '${diagnosisLabel(ctx.diagnosis)} · ${(ctx.confidence * 100).toStringAsFixed(0)}% · ${formatHst(ctx.daysAfterPlanting)}',
                        style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: _messages.length + (_isReplying ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (context, index) {
                  if (index >= _messages.length) {
                    return const GelembungPesan(content: 'Sedang mengetik', isUser: false, isStreaming: true);
                  }
                  final m = _messages[index];
                  return Column(
                    crossAxisAlignment: m.role == MessageRole.user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      GelembungPesan(content: m.content, isUser: m.role == MessageRole.user),
                      if (m.citations.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.78,
                          child: Column(
                            children: m.citations
                                .map((c) => Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                      child: KartuRujukan(title: c.title, publisher: c.publisher, year: c.year, page: c.page),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  );
                },
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
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
