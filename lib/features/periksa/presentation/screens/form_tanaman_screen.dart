import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/periksa/data/periksa_mock_data.dart';

/// Form Daftarkan Tanaman — PRD §5.2 US-06 / API_DOCS_NEW.md §4.1 Create Plant.
/// Field: komoditas, nama panggilan, jumlah polybag/luas, tanggal tanam
/// (boleh perkiraan).
class FormTanamanScreen extends StatefulWidget {
  const FormTanamanScreen({super.key});

  @override
  State<FormTanamanScreen> createState() => _FormTanamanScreenState();
}

class _FormTanamanScreenState extends State<FormTanamanScreen> {
  final _nicknameController = TextEditingController();
  final _unitCountController = TextEditingController(text: '30');
  String _commodity = 'CABAI';
  UnitType _unitType = UnitType.polybag;
  DateTime _plantedAt = DateTime.now();
  bool _isEstimated = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _unitCountController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama panggilan wajib diisi.')));
      return;
    }
    final baru = Plant(
      plantId: 'p${DateTime.now().millisecondsSinceEpoch}',
      nickname: _nicknameController.text.trim(),
      commodity: _commodity,
      daysAfterPlanting: DateTime.now().difference(_plantedAt).inDays,
      phase: 'SEMAI',
      unitCount: int.tryParse(_unitCountController.text) ?? 1,
      unitType: _unitType,
    );
    context.pop(baru);
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
                children: const ['CABAI', 'TERONG', 'PADI'].map((c) {
                  final selected = c == _commodity;
                  return ChoiceChip(
                    label: LabelKomoditas(commodity: c),
                    selected: selected,
                    onSelected: (_) => setState(() => _commodity = c),
                    backgroundColor: AppColors.kertas,
                    selectedColor: AppColors.daunSamar,
                    side: BorderSide(color: selected ? AppColors.daun : AppColors.garis, width: selected ? 2 : 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
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
                              .map((u) => DropdownMenuItem(value: u, child: Text(unitTypeLabel(u), style: AppTypography.isi)))
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
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.daun,
                    foregroundColor: AppColors.kertas,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                    textStyle: AppTypography.isiTebal,
                  ),
                  child: const Text('Daftarkan'),
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
