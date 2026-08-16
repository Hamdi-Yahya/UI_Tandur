import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_mock_data.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Daftar Tanaman Saya — PRD §5.2 US-06, rute `/periksa/tanaman`.
class DaftarTanamanScreen extends StatefulWidget {
  const DaftarTanamanScreen({super.key});

  @override
  State<DaftarTanamanScreen> createState() => _DaftarTanamanScreenState();
}

class _DaftarTanamanScreenState extends State<DaftarTanamanScreen> {
  List<Plant> _plants = List.of(PeriksaMockData.plants);

  Future<void> _tambahTanaman() async {
    final baru = await context.push<Plant>('/periksa/tanaman/baru');
    if (baru != null) {
      setState(() => _plants = [baru, ..._plants]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Tanaman Saya'),
      body: SafeArea(
        child: _plants.isEmpty
            ? KeadaanKosong(
                icon: Icons.eco_outlined,
                message: 'Belum ada tanaman yang dipantau',
                actionLabel: 'Daftarkan tanaman',
                onAction: _tambahTanaman,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: _plants.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                itemBuilder: (context, index) {
                  final p = _plants[index];
                  return PlantCard(plant: p, onTap: () => context.push('/periksa/tanaman/${p.plantId}'));
                },
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
