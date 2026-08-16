import 'package:flutter/material.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_mock_data.dart';

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

/// Pusat Notifikasi — rute `/saya/notifikasi`, API_DOCS_NEW.md §6.
class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  List<NotificationItem> _items = List.of(SayaMockData.notifications);

  void _tandaiSemuaTerbaca() {
    setState(() {
      _items = _items.map((n) => n.readAt == null
          ? NotificationItem(notificationId: n.notificationId, type: n.type, title: n.title, body: n.body, readAt: DateTime.now(), createdAt: n.createdAt)
          : n).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: ScreenAppBar(
        title: 'Notifikasi',
        action: TextButton(
          onPressed: _tandaiSemuaTerbaca,
          child: Text('Tandai dibaca', style: AppTypography.kecil.copyWith(color: AppColors.daun, fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: _items.isEmpty
            ? KeadaanKosong(icon: Icons.notifications_none, message: 'Belum ada notifikasi', actionLabel: 'Kembali', onAction: () => Navigator.of(context).maybePop())
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.garis),
                itemBuilder: (context, index) {
                  final n = _items[index];
                  final isUnread = n.readAt == null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: isUnread ? AppColors.daunSamar : AppColors.garis, shape: BoxShape.circle),
                          child: Icon(_iconByType[n.type] ?? Icons.notifications, size: 18, color: isUnread ? AppColors.daun : AppColors.tanahSamar),
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
                  );
                },
              ),
      ),
    );
  }
}
