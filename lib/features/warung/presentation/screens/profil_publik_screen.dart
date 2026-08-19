import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/warung/data/warung_models.dart';
import 'package:tandur/features/warung/data/warung_repository.dart';
import 'package:tandur/features/warung/presentation/widgets/warung_widgets.dart';

/// Profil Publik Pengguna — DESAIN.md rute `/warung/pengguna/:id`,
/// API_DOCS.md §5.3 Get User Profile (GET /api/community/users/:id).
class ProfilPublikScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfilPublikScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfilPublikScreen> createState() => _ProfilPublikScreenState();
}

class _ProfilPublikScreenState extends ConsumerState<ProfilPublikScreen> {
  PublicProfile? _profile;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final p = await ref
          .read(warungRepositoryProvider)
          .getPublicProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Profil'),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.daun),
      );
    }
    final p = _profile;
    if (_error != null || p == null) {
      return KeadaanGalat(
        message: _error ?? 'Pengguna tidak ditemukan.',
        onRetry: _muat,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          InitialAvatar(name: p.fullName, radius: 40),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  p.fullName,
                  style: AppTypography.judul.copyWith(color: AppColors.tanah),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (p.isVerified) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.verified, size: 18, color: AppColors.terong),
              ],
            ],
          ),
          if (p.verifiedNote != null && p.verifiedNote!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              p.verifiedNote!,
              style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(label: 'Reputasi', value: '${p.reputation}'),
              _Stat(label: 'Jawaban terbaik', value: '${p.bestAnswerCount}'),
              _Stat(label: 'Balasan', value: '${p.replyCount}'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(color: AppColors.garis),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Komoditas dikuasai',
              style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          if (p.topCommodities.isEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Belum ada',
                style: AppTypography.kecil.copyWith(
                  color: AppColors.tanahSamar,
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSpacing.s,
                children: p.topCommodities
                    .where((c) => c != Commodity.unknown)
                    .map((c) => LabelKomoditas(commodity: apiKomoditas(c)))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.angkaBesar.copyWith(color: AppColors.tanah),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
        ),
      ],
    );
  }
}
