import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_repository.dart';

const Map<String, IconData> _iconByType = {
  'REPLY_RECEIVED': Icons.reply,
  'BEST_ANSWER_MARKED': Icons.emoji_events,
  'MENTION': Icons.alternate_email,
  'SCAN_REMINDER': Icons.camera_alt_outlined,
  'STREAK_WARNING': Icons.local_fire_department,
  'LEVEL_UNLOCKED': Icons.lock_open,
  'BADGE_EARNED': Icons.workspace_premium,
  'MODEL_UPDATED': Icons.system_update,
};

/// Pusat Notifikasi — rute `/saya/notifikasi`, API_DOCS bagian 6.
/// Daftar dengan paginasi cursor; mengetuk notifikasi menandainya dibaca.
class NotifikasiScreen extends ConsumerStatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  ConsumerState<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends ConsumerState<NotifikasiScreen> {
  final _scrollController = ScrollController();
  List<AppNotification> _items = const [];
  int _unreadCount = 0;
  String? _nextCursor;
  bool _loading = true;
  bool _loadingMore = false;
  bool _markingRead = false;
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
      final page = await ref.read(notificationRepositoryProvider).getNotifications();
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _unreadCount = page.unreadCount;
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
      final page = await ref.read(notificationRepositoryProvider).getNotifications(cursor: cursor);
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

  Future<void> _tandaiDibaca(AppNotification n) async {
    if (_markingRead || !n.isUnread) return;
    setState(() => _markingRead = true);
    try {
      final unread = await ref.read(notificationRepositoryProvider).markRead(n.notificationId);
      if (!mounted) return;
      setState(() {
        _items = _items.map((item) => item.notificationId == n.notificationId
            ? AppNotification(
                notificationId: item.notificationId,
                type: item.type,
                title: item.title,
                body: item.body,
                payload: item.payload,
                readAt: DateTime.now(),
                createdAt: item.createdAt,
              )
            : item).toList();
        _unreadCount = unread;
        _markingRead = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _markingRead = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _markingRead = false);
    }
  }

  Future<void> _tandaiSemuaTerbaca() async {
    if (_markingRead) return;
    setState(() => _markingRead = true);
    try {
      final unread = await ref.read(notificationRepositoryProvider).markAllRead();
      if (!mounted) return;
      setState(() {
        _items = _items.map((item) => item.isUnread
            ? AppNotification(
                notificationId: item.notificationId,
                type: item.type,
                title: item.title,
                body: item.body,
                payload: item.payload,
                readAt: DateTime.now(),
                createdAt: item.createdAt,
              )
            : item).toList();
        _unreadCount = unread;
        _markingRead = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _markingRead = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _markingRead = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: ScreenAppBar(
        title: 'Notifikasi',
        action: TextButton(
          onPressed: _markingRead ? null : _tandaiSemuaTerbaca,
          child: Text('Tandai dibaca', style: AppTypography.kecil.copyWith(color: AppColors.daun, fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.daun))
            : _error != null && _items.isEmpty
                ? KeadaanGalat(message: _error!, onRetry: _muat)
                : _items.isEmpty
                    ? KeadaanKosong(icon: Icons.notifications_none, message: 'Belum ada notifikasi', actionLabel: 'Kembali', onAction: () => Navigator.of(context).maybePop())
                    : RefreshIndicator(
                        onRefresh: _muat,
                        child: Column(
                          children: [
                            if (_unreadCount > 0)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.daun,
                                        borderRadius: BorderRadius.circular(AppRadius.penuh),
                                      ),
                                      child: Text('$_unreadCount belum dibaca', style: AppTypography.kecil.copyWith(color: AppColors.kertas, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
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
                                  final n = _items[index];
                                  final isUnread = n.isUnread;
                                  return InkWell(
                                    onTap: isUnread ? () => _tandaiDibaca(n) : null,
                                    borderRadius: BorderRadius.circular(AppRadius.sedang),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(color: isUnread ? AppColors.daunSamar : AppColors.garis, shape: BoxShape.circle),
                                            child: Icon(_iconByType[n.type.apiValue] ?? Icons.notifications, size: 18, color: isUnread ? AppColors.daun : AppColors.tanahSamar),
                                          ),
                                          const SizedBox(width: AppSpacing.m),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(n.title, style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                                                const SizedBox(height: 2),
                                                Text(n.body, style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah), maxLines: 2, overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.daun, shape: BoxShape.circle)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}