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
import 'package:tandur/features/warung/data/warung_models.dart';
import 'package:tandur/features/warung/data/warung_repository.dart';
import 'package:tandur/features/warung/presentation/widgets/warung_widgets.dart';

/// Daftar Pertanyaan (Warung Tani) — DESAIN.md §4.9, rute `/warung`.
/// Menggabungkan daftar (paginasasi kursor), saring komoditas, urutan,
/// pencarian, dan keadaan kosong dalam satu layar. Pencarian memakai
/// GET /api/community/search; selain itu GET /api/community/questions
/// dengan kursor (`nextCursor: null` = halaman terakhir).
class DaftarPertanyaanScreen extends ConsumerStatefulWidget {
  const DaftarPertanyaanScreen({super.key});

  @override
  ConsumerState<DaftarPertanyaanScreen> createState() =>
      _DaftarPertanyaanScreenState();
}

class _DaftarPertanyaanScreenState
    extends ConsumerState<DaftarPertanyaanScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  List<CommunityQuestion> _questions = [];
  List<CommunitySearchResult> _searchResults = [];
  String? _nextCursor;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String _commodityFilter = 'Semua';
  QuestionSort _sort = QuestionSort.newest;
  bool _isSearching = false;

  bool get _searchActive => _searchController.text.trim().isNotEmpty;

  WarungRepository get _repo => ref.read(warungRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _muat();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searchActive || _nextCursor == null || _isLoadingMore || _isLoading) {
      return;
    }
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) _muat(reset: false);
  }

  /// Ambil halaman pertama (reset) atau halaman berikutnya sesuai kursor.
  Future<void> _muat({bool reset = true}) async {
    if (reset) {
      setState(() {
        _nextCursor = null;
        _error = null;
        _isLoading = _questions.isEmpty && _searchResults.isEmpty;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }
    final commodity = _commodityFilter == 'Semua'
        ? null
        : Commodity.fromApi(_commodityFilter);
    try {
      if (_searchActive) {
        final page = await _repo.searchQuestions(
          q: _searchController.text.trim(),
          commodity: commodity,
        );
        if (!mounted) return;
        setState(() {
          _searchResults = page.items;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        final page = await _repo.listQuestions(
          commodity: commodity,
          sort: _sort,
          cursor: reset ? null : _nextCursor,
        );
        if (!mounted) return;
        setState(() {
          _questions = reset ? page.items : [..._questions, ...page.items];
          _nextCursor = page.nextCursor;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = e.message;
      });
    }
  }

  Future<void> _vote(CommunityQuestion q, int value) async {
    try {
      final result = await _repo.voteQuestion(q.questionId, value);
      if (!mounted) return;
      setState(() {
        _questions = _questions
            .map(
              (x) => x.questionId == q.questionId
                  ? x.copyWith(score: result.score, myVote: result.myVote)
                  : x,
            )
            .toList();
      });
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _ubahPencarian() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _muat();
    });
    setState(() {});
  }

  void _tutupPencarian() {
    _searchDebounce?.cancel();
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    _muat();
  }

  @override
  Widget build(BuildContext context) {
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
                  hintStyle: AppTypography.isi.copyWith(
                    color: AppColors.tanahSamar,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (_) => _ubahPencarian(),
              )
            : Text(
                'Warung Tani',
                style: AppTypography.tampilanKecil.copyWith(
                  color: AppColors.tanah,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.tanah,
            ),
            onPressed: _isSearching
                ? _tutupPencarian
                : () => setState(() => _isSearching = true),
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
                      label: Text(
                        c == 'Semua'
                            ? 'Semua'
                            : c[0] + c.substring(1).toLowerCase(),
                      ),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _commodityFilter = c);
                        _muat();
                      },
                      backgroundColor: AppColors.kertas,
                      selectedColor: AppColors.daunSamar,
                      labelStyle: AppTypography.isiTebal.copyWith(
                        color: selected ? AppColors.daun : AppColors.tanahLemah,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.daun : AppColors.garis,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.penuh),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.s,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DropdownButton<QuestionSort>(
                  value: _sort,
                  underline: const SizedBox.shrink(),
                  style: AppTypography.isiTebal.copyWith(
                    color: AppColors.tanah,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: QuestionSort.newest,
                      child: Text('Terbaru'),
                    ),
                    DropdownMenuItem(
                      value: QuestionSort.top,
                      child: Text('Teratas'),
                    ),
                    DropdownMenuItem(
                      value: QuestionSort.active,
                      child: Text('Sedang ramai'),
                    ),
                    DropdownMenuItem(
                      value: QuestionSort.unanswered,
                      child: Text('Belum terjawab'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _sort = v);
                    _muat();
                  },
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.garis),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _muat(),
                color: AppColors.daun,
                child: _body(),
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
        label: Text(
          'Tanya',
          style: AppTypography.isiTebal.copyWith(color: AppColors.kertas),
        ),
      ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator(color: AppColors.daun)),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          KeadaanGalat(message: _error!, onRetry: () => _muat()),
        ],
      );
    }
    final hasil = _searchActive ? _searchResults : _questions;
    if (hasil.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          KeadaanKosong(
            icon: _searchActive ? Icons.search_off : Icons.forum_outlined,
            message: _searchActive
                ? 'Tidak ada hasil untuk pencarian ini'
                : 'Belum ada pertanyaan tentang ini',
            actionLabel: _searchActive
                ? 'Coba kata kunci lain'
                : 'Jadi yang pertama bertanya',
            onAction: _searchActive
                ? _tutupPencarian
                : () => context.push('/warung/tanya'),
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      itemCount: hasil.length + (!_searchActive && _isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: AppColors.garis),
      itemBuilder: (context, index) {
        if (index >= hasil.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.l),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.daun,
                ),
              ),
            ),
          );
        }
        if (_searchActive) {
          final r = hasil[index] as CommunitySearchResult;
          return _SearchResultTile(
            result: r,
            onTap: () => context.push('/warung/p/${r.questionId}'),
          );
        }
        final q = hasil[index] as CommunityQuestion;
        return QuestionListTile(
          question: q,
          onTap: () => context.push('/warung/p/${q.questionId}'),
          onVote: (v) => _vote(q, v),
        );
      },
    );
  }
}

/// Baris hasil pencarian — bentuknya ringkas dari server (API_DOCS §5.1),
/// tidak punya kendali suara (pencarian tidak mengembalikan `myVote`).
class _SearchResultTile extends StatelessWidget {
  final CommunitySearchResult result;
  final VoidCallback onTap;

  const _SearchResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.title,
              style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (result.snippet != null && result.snippet!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                result.snippet!,
                style: AppTypography.kecil.copyWith(
                  color: AppColors.tanahSamar,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${result.score} suara · ${result.replyCount} balasan · ${result.hasBestAnswer ? 'sudah terjawab' : 'belum terjawab'}',
              style: AppTypography.kecil.copyWith(
                color: result.hasBestAnswer ? AppColors.terong : AppColors.padi,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
