import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_repository.dart';

/// Koleksi Lencana — rute `/saya/lencana`, API_DOCS §3.4 Get My Badges.
/// `earnedAt != null` berarti sudah didapat; sisanya lencana yang sedang
/// berjalan dengan progress/target.
class KoleksiLencanaScreen extends ConsumerStatefulWidget {
  const KoleksiLencanaScreen({super.key});

  @override
  ConsumerState<KoleksiLencanaScreen> createState() => _KoleksiLencanaScreenState();
}

class _KoleksiLencanaScreenState extends ConsumerState<KoleksiLencanaScreen> {
  List<Badge> _badges = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _loading = _badges.isEmpty;
      _error = null;
    });
    try {
      final badges = await ref.read(gamificationRepositoryProvider).getBadges();
      if (!mounted) return;
      setState(() {
        _badges = badges;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Koleksi Lencana'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.daun))
            : _error != null && _badges.isEmpty
                ? KeadaanGalat(message: _error!, onRetry: _muat)
                : _badges.isEmpty
                    ? KeadaanKosong(
                        icon: Icons.workspace_premium_outlined,
                        message: 'Belum ada lencana',
                        actionLabel: 'Kembali',
                        onAction: () => Navigator.of(context).maybePop(),
                      )
                    : RefreshIndicator(
                        onRefresh: _muat,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.l),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.m,
                            crossAxisSpacing: AppSpacing.m,
                            childAspectRatio: 0.76,
                          ),
                          itemCount: _badges.length,
                          itemBuilder: (context, index) {
                            final b = _badges[index];
                            final bool isEarned = b.isEarned;
                            final double progressVal = (b.progress != null && b.target != null && b.target! > 0)
                                ? (b.progress! / b.target!).clamp(0.0, 1.0)
                                : 0.0;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.m,
                                vertical: AppSpacing.m,
                              ),
                              decoration: BoxDecoration(
                                color: isEarned ? AppColors.kertas : AppColors.kertas.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(AppRadius.sedang),
                                border: Border.all(
                                  color: isEarned ? AppColors.padi.withValues(alpha: 0.45) : AppColors.garis,
                                  width: isEarned ? 1.5 : 1.0,
                                ),
                                boxShadow: isEarned
                                    ? [
                                        BoxShadow(
                                          color: AppColors.padi.withValues(alpha: 0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Badge Icon Circle
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: isEarned ? AppColors.padiSamar : AppColors.embun,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isEarned ? AppColors.padi.withValues(alpha: 0.4) : AppColors.garis,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: b.iconUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              b.iconUrl!,
                                              width: 52,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                isEarned ? Icons.workspace_premium : Icons.lock_outline_rounded,
                                                color: isEarned ? AppColors.padi : AppColors.tanahSamar,
                                                size: 26,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            isEarned ? Icons.workspace_premium : Icons.lock_outline_rounded,
                                            color: isEarned ? AppColors.padi : AppColors.tanahSamar,
                                            size: 26,
                                          ),
                                  ),
                                  const SizedBox(height: AppSpacing.s),

                                  // Badge Name
                                  Text(
                                    b.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.isiTebal.copyWith(
                                      color: isEarned ? AppColors.tanah : AppColors.tanahSamar,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Badge Description
                                  Text(
                                    b.description,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.kecil.copyWith(
                                      color: AppColors.tanahSamar,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s),

                                  // Status / Progress
                                  if (isEarned && b.earnedAt != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.daunSamar,
                                        borderRadius: BorderRadius.circular(AppRadius.penuh),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check_circle_rounded, size: 11, color: AppColors.daun),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Didapat ${b.earnedAt!.day}/${b.earnedAt!.month}',
                                            style: AppTypography.label.copyWith(
                                              color: AppColors.daun,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (b.progress != null && b.target != null && b.target! > 0)
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(AppRadius.penuh),
                                          child: SizedBox(
                                            width: 72,
                                            height: 4,
                                            child: LinearProgressIndicator(
                                              value: progressVal,
                                              backgroundColor: AppColors.garis,
                                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.padi),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${b.progress}/${b.target}',
                                          style: AppTypography.angka.copyWith(
                                            color: AppColors.tanahSamar,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      isEarned ? 'Tercapai' : 'Terkunci',
                                      style: AppTypography.label.copyWith(
                                        color: AppColors.tanahSamar,
                                        fontSize: 10,
                                      ),
                                    ),
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