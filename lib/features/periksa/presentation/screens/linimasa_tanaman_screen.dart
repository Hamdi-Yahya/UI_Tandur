import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_models.dart';
import 'package:tandur/features/periksa/data/periksa_repository.dart';
import 'package:tandur/features/periksa/presentation/widgets/periksa_widgets.dart';

/// Linimasa Tanaman — DESAIN.md §4.8, rute `/periksa/tanaman/:id`.
/// Memuat `GET /api/plants/:id` (kepala) dan `GET /api/plants/:id/scans`
/// (linimasa cursor) sekaligus.
class LinimasaTanamanScreen extends ConsumerStatefulWidget {
  final String plantId;

  const LinimasaTanamanScreen({super.key, required this.plantId});

  @override
  ConsumerState<LinimasaTanamanScreen> createState() => _LinimasaTanamanScreenState();
}

class _LinimasaTanamanScreenState extends ConsumerState<LinimasaTanamanScreen> {
  bool _loading = true;
  String? _error;
  PlantDetail? _plant;
  List<ScanTimelineItem> _timeline = const [];
  ScanTimelinePage? _page;

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
      final repo = ref.read(periksaRepositoryProvider);
      final plant = await repo.getPlantDetail(widget.plantId);
      final page = await repo.getPlantScans(widget.plantId);
      if (!mounted) return;
      setState(() {
        _plant = plant;
        _timeline = page.items;
        _page = page;
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

  Future<void> _muatLagi() async {
    final repo = ref.read(periksaRepositoryProvider);
    final page = await repo.getPlantScans(widget.plantId, cursor: _page?.nextCursor);
    if (!mounted) return;
    setState(() {
      _timeline = [..._timeline, ...page.items];
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plant = _plant;
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: ScreenAppBar(title: plant?.nickname ?? 'Tanaman'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? KeadaanGalat(message: _error!, onRetry: _muat)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${formatHst(plant!.daysAfterPlanting)} · ${plant.unitCount} ${plant.unitType.label}',
                              style: AppTypography.angka.copyWith(color: AppColors.tanahLemah),
                            ),
                            if (plant.patterns.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.s),
                                child: Text(
                                  '${plant.patterns.map((p) => '${diagnosisLabel(p.label)} ${p.occurrences}x').join(' · ')} dalam ${plant.patterns.first.withinDays} hari terakhir',
                                  style: AppTypography.kecil.copyWith(color: AppColors.padi, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.garis),
                      Expanded(
                        child: _timeline.isEmpty
                            ? KeadaanKosong(
                                icon: Icons.timeline,
                                message: 'Belum ada pemeriksaan untuk tanaman ini',
                                actionLabel: 'Periksa sekarang',
                                onAction: () => context.push('/periksa'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(AppSpacing.l),
                                itemCount: _timeline.length + (_page?.nextCursor != null ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _timeline.length) {
                                    _muatLagi();
                                    return const Padding(
                                      padding: EdgeInsets.all(AppSpacing.l),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  return ScanTimelineTile(
                                    item: _timeline[index],
                                    isLast: index == _timeline.length - 1,
                                    onTap: () => context.push('/periksa/hasil/${_timeline[index].scanId}'),
                                  );
                                },
                              ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.l),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/periksa'),
                              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                              label: const Text('Periksa lagi'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.daun,
                                side: const BorderSide(color: AppColors.daun, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                                textStyle: AppTypography.isiTebal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}