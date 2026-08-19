import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_models.dart';
import 'package:tandur/features/periksa/data/periksa_repository.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Daftar Tanaman Saya — PRD §5.2 US-06, rute `/periksa/tanaman`.
/// Memuat dari `GET /api/plants`; penambahan tanaman lewat `/periksa/tanaman/baru`
/// lalu daftar dimuat ulang supaya bentuk `PlantCreated` yang ringkas tidak
/// perlu dirangkai sendiri menjadi kartu kebohongan.
class DaftarTanamanScreen extends ConsumerStatefulWidget {
  const DaftarTanamanScreen({super.key});

  @override
  ConsumerState<DaftarTanamanScreen> createState() => _DaftarTanamanScreenState();
}

class _DaftarTanamanScreenState extends ConsumerState<DaftarTanamanScreen> {
  bool _loading = true;
  String? _error;
  List<Plant> _plants = const [];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plants = await ref.read(periksaRepositoryProvider).getPlants();
      if (!mounted) return;
      setState(() {
        _plants = plants;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _tambahTanaman() async {
    final baru = await context.push<PlantCreated>('/periksa/tanaman/baru');
    if (baru != null) _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Tanaman Saya'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? KeadaanGalat(message: _error!, onRetry: _muat)
                : _plants.isEmpty
                    ? KeadaanKosong(
                        icon: Icons.eco_outlined,
                        message: 'Belum ada tanaman yang dipantau',
                        actionLabel: 'Daftarkan tanaman',
                        onAction: _tambahTanaman,
                      )
                    : RefreshIndicator(
                        onRefresh: _muat,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppSpacing.l),
                          itemCount: _plants.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                          itemBuilder: (context, index) {
                            final p = _plants[index];
                            return PlantCard(plant: p, onTap: () => context.push('/periksa/tanaman/${p.plantId}'));
                          },
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahTanaman,
        backgroundColor: AppColors.daun,
        foregroundColor: AppColors.kertas,
        icon: const Icon(Icons.add),
        label: Text('Tanaman', style: AppTypography.isiTebal.copyWith(color: AppColors.kertas)),
      ),
    );
  }
}