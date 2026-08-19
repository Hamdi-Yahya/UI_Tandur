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

/// Form Daftarkan Tanaman — PRD §5.2 US-06 / API_DOCS_NEW.md §4.1 Create Plant.
/// Field: komoditas, nama panggilan, jumlah polybag/luas, tanggal tanam
/// (boleh perkiraan). Menyimpan lewat `POST /api/plants` dan mengembalikan
/// [PlantCreated] ke layar daftar.
class FormTanamanScreen extends ConsumerStatefulWidget {
  const FormTanamanScreen({super.key});

  @override
  ConsumerState<FormTanamanScreen> createState() => _FormTanamanScreenState();
}

class _FormTanamanScreenState extends ConsumerState<FormTanamanScreen> {
  final _nicknameController = TextEditingController();
  final _unitCountController = TextEditingController(text: '30');
  String _commodity = 'CABAI';
  UnitType _unitType = UnitType.polybag;
  DateTime _plantedAt = DateTime.now();
  bool _isEstimated = false;
  bool _menyimpan = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _unitCountController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_menyimpan) return;
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama panggilan wajib diisi.')));
      return;
    }
    final unitCount = int.tryParse(_unitCountController.text);
    if (unitCount == null || unitCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah minimal 1.')));
      return;
    }

    setState(() => _menyimpan = true);
    try {
      final created = await ref.read(periksaRepositoryProvider).createPlant(
            commodity: Commodity.fromApi(_commodity),
            nickname: _nicknameController.text.trim(),
            unitCount: unitCount,
            unitType: _unitType,
            plantedAt: _plantedAt,
          );
      if (!mounted) return;
      context.pop(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.fieldErrors?['nickname']?.first ?? e.message)));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Daftarkan Tanaman'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Komoditas', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: const ['CABAI', 'TERONG', 'PADI'].map((c) {
                  final selected = c == _commodity;
                  return PilihanKomoditasChip(
                    commodity: c,
                    isSelected: selected,
                    onTap: () => setState(() => _commodity = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Nama panggilan', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _nicknameController,
                style: AppTypography.isi.copyWith(color: AppColors.tanah),
                decoration: _dec('Misalnya: Cabai Depan Rumah'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jumlah', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                        const SizedBox(height: AppSpacing.s),
                        TextField(
                          controller: _unitCountController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.isi.copyWith(color: AppColors.tanah),
                          decoration: _dec('30'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Satuan', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                        const SizedBox(height: AppSpacing.s),
                        DropdownButtonFormField<UnitType>(
                          initialValue: _unitType,
                          decoration: _dec(null),
                          items: UnitType.values
                              .where((u) => u != UnitType.unknown)
                              .map((u) => DropdownMenuItem(value: u, child: Text(u.label, style: AppTypography.isi)))
                              .toList(),
                          onChanged: (u) => setState(() => _unitType = u ?? _unitType),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Tanggal tanam', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
              const SizedBox(height: AppSpacing.s),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _plantedAt,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _plantedAt = picked);
                },
                borderRadius: BorderRadius.circular(AppRadius.sedang),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.garis),
                    borderRadius: BorderRadius.circular(AppRadius.sedang),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.tanahSamar),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        '${_plantedAt.day}/${_plantedAt.month}/${_plantedAt.year}',
                        style: AppTypography.isi.copyWith(color: AppColors.tanah),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              TextButton(
                onPressed: () => setState(() {
                  _isEstimated = true;
                  _plantedAt = DateTime.now().subtract(const Duration(days: 30));
                }),
                child: Text(
                  _isEstimated ? '✓ Kira-kira sebulan lalu' : 'Kira-kira sebulan lalu',
                  style: AppTypography.kecil.copyWith(color: AppColors.daun, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _menyimpan ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.daun,
                    foregroundColor: AppColors.kertas,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                    textStyle: AppTypography.isiTebal,
                  ),
                  child: Text(_menyimpan ? 'Menyimpan...' : 'Daftarkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
      filled: true,
      fillColor: AppColors.kertas,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.garis)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.garis)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.daun, width: 2)),
    );
  }
}