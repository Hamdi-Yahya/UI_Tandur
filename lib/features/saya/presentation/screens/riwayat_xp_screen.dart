import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_repository.dart';

/// Riwayat XP — rute `/saya/xp`, API_DOCS §3.4 Get XP History. Paginasi
/// memakai cursor: `nextCursor: null` berarti halaman terakhir.
class RiwayatXpScreen extends ConsumerStatefulWidget {
  const RiwayatXpScreen({super.key});

  @override
  ConsumerState<RiwayatXpScreen> createState() => _RiwayatXpScreenState();
}

class _RiwayatXpScreenState extends ConsumerState<RiwayatXpScreen> {
  final _scrollController = ScrollController();
  List<XpHistoryItem> _items = const [];
  String? _nextCursor;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _muat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) {
      _muatLagi();
    }
  }

  Future<void> _muat() async {
    setState(() {
      _loading = _items.isEmpty;
      _error = null;
    });
    try {
      final page = await ref.read(gamificationRepositoryProvider).getXpHistory();
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _nextCursor = page.nextCursor;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi galat. Coba lagi.';
        _loading = false;
      });
    }
  }

  Future<void> _muatLagi() async {
    final cursor = _nextCursor;
    if (cursor == null || _loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final page = await ref.read(gamificationRepositoryProvider).getXpHistory(cursor: cursor);
      if (!mounted) return;
      setState(() {
        _items = List.of(_items)..addAll(page.items);
        _nextCursor = page.nextCursor;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Riwayat XP'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.daun))
            : _error != null && _items.isEmpty
                ? KeadaanGalat(message: _error!, onRetry: _muat)
                : _items.isEmpty
                    ? KeadaanKosong(icon: Icons.bolt_outlined, message: 'Belum ada riwayat XP', actionLabel: 'Mulai belajar', onAction: () {})
                    : RefreshIndicator(
                        onRefresh: _muat,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.l),
                          itemCount: _items.length + 1,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.garis),
                          itemBuilder: (context, index) {
                            if (index == _items.length) {
                              return _nextCursor == null
                                  ? const SizedBox(height: AppSpacing.l)
                                  : const Padding(
                                      padding: EdgeInsets.all(AppSpacing.l),
                                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.daun)),
                                    );
                            }
                            final x = _items[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(color: AppColors.padiSamar, shape: BoxShape.circle),
                                    child: const Icon(Icons.bolt, color: AppColors.padi, size: 20),
                                  ),
                                  const SizedBox(width: AppSpacing.m),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(x.reason.label, style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                                        Text(
                                          '${x.createdAt.day}/${x.createdAt.month} · ${x.createdAt.hour.toString().padLeft(2, '0')}:${x.createdAt.minute.toString().padLeft(2, '0')}',
                                          style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('+${x.amount}', style: AppTypography.angka.copyWith(color: AppColors.padi, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}