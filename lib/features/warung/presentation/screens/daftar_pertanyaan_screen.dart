import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/warung/data/warung_mock_data.dart';
import 'package:tandur/features/warung/presentation/widgets/warung_widgets.dart';

/// Daftar Pertanyaan (Warung Tani) — DESAIN.md §4.9, rute `/warung`.
/// Menggabungkan daftar, saring komoditas, urutan, pencarian, dan keadaan
/// kosong dalam satu layar (Figma memisahkannya jadi dua frame, tapi
/// perilakunya sama: daftar yang sama, disaring berbeda).
class DaftarPertanyaanScreen extends StatefulWidget {
  const DaftarPertanyaanScreen({super.key});

  @override
  State<DaftarPertanyaanScreen> createState() => _DaftarPertanyaanScreenState();
}

class _DaftarPertanyaanScreenState extends State<DaftarPertanyaanScreen> {
  List<Question> _questions = List.of(WarungMockData.questions);
  String _commodityFilter = 'Semua';
  QuestionSort _sort = QuestionSort.newest;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  List<Question> get _filtered {
    var list = _questions.where((q) {
      final matchCommodity = _commodityFilter == 'Semua' || q.commodity == _commodityFilter;
      final matchSearch = _searchController.text.isEmpty ||
          q.title.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchCommodity && matchSearch;
    }).toList();
    switch (_sort) {
      case QuestionSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case QuestionSort.top:
        list.sort((a, b) => b.score.compareTo(a.score));
        break;
      case QuestionSort.active:
        list.sort((a, b) => b.replyCount.compareTo(a.replyCount));
        break;
      case QuestionSort.unanswered:
        list = list.where((q) => !q.isAnswered).toList();
        break;
    }
    return list;
  }

  void _vote(Question q, int value) {
    setState(() {
      final delta = value - q.myVote;
      _questions = _questions.map((x) => x.questionId == q.questionId ? x.copyWith(score: x.score + delta, myVote: value) : x).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: AppBar(
        backgroundColor: AppColors.embun,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTypography.isi.copyWith(color: AppColors.tanah),
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan...',
                  hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text('Warung Tani', style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppColors.tanah),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                children: ['Semua', 'CABAI', 'TERONG', 'PADI'].map((c) {
                  final selected = c == _commodityFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: ChoiceChip(
                      label: Text(c == 'Semua' ? 'Semua' : c[0] + c.substring(1).toLowerCase()),
                      selected: selected,
                      onSelected: (_) => setState(() => _commodityFilter = c),
                      backgroundColor: AppColors.kertas,
                      selectedColor: AppColors.daunSamar,
                      labelStyle: AppTypography.isiTebal.copyWith(color: selected ? AppColors.daun : AppColors.tanahLemah),
                      side: BorderSide(color: selected ? AppColors.daun : AppColors.garis),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DropdownButton<QuestionSort>(
                  value: _sort,
                  underline: const SizedBox.shrink(),
                  style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
                  items: const [
                    DropdownMenuItem(value: QuestionSort.newest, child: Text('Terbaru')),
                    DropdownMenuItem(value: QuestionSort.top, child: Text('Teratas')),
                    DropdownMenuItem(value: QuestionSort.active, child: Text('Sedang ramai')),
                    DropdownMenuItem(value: QuestionSort.unanswered, child: Text('Belum terjawab')),
                  ],
                  onChanged: (v) => setState(() => _sort = v ?? _sort),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.garis),
            Expanded(
              child: list.isEmpty
                  ? KeadaanKosong(
                      icon: Icons.forum_outlined,
                      message: 'Belum ada pertanyaan tentang ini',
                      actionLabel: 'Jadi yang pertama bertanya',
                      onAction: () => context.push('/warung/tanya'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.garis),
                      itemBuilder: (context, index) {
                        final q = list[index];
                        return QuestionListTile(
                          question: q,
                          onTap: () => context.push('/warung/p/${q.questionId}'),
                          onVote: (v) => _vote(q, v),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/warung/tanya'),
        backgroundColor: AppColors.terong,
        foregroundColor: AppColors.kertas,
        icon: const Icon(Icons.add),
        label: Text('Tanya', style: AppTypography.isiTebal.copyWith(color: AppColors.kertas)),
      ),
    );
  }
}
