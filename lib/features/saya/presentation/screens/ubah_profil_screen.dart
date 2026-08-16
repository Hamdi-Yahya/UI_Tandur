import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_mock_data.dart';

/// Ubah Profil — rute `/saya/ubah`, API_DOCS_NEW.md §2 Update Profile.
class UbahProfilScreen extends StatefulWidget {
  const UbahProfilScreen({super.key});

  @override
  State<UbahProfilScreen> createState() => _UbahProfilScreenState();
}

class _UbahProfilScreenState extends State<UbahProfilScreen> {
  final _nameController = TextEditingController(text: SayaMockData.profile.fullName);
  final _districtController = TextEditingController(text: SayaMockData.profile.district ?? '');
  final List<String> _commodities = List.of(SayaMockData.profile.commodities);

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _simpan() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Ubah Profil'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama lengkap', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
              const SizedBox(height: AppSpacing.s),
              TextField(controller: _nameController, style: AppTypography.isi.copyWith(color: AppColors.tanah), decoration: _dec()),
              const SizedBox(height: AppSpacing.xl),
              Text('Kabupaten', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
              const SizedBox(height: AppSpacing.s),
              TextField(controller: _districtController, style: AppTypography.isi.copyWith(color: AppColors.tanah), decoration: _dec()),
              const SizedBox(height: AppSpacing.xl),
              Text('Komoditas diminati', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                children: const ['CABAI', 'TERONG', 'PADI'].map((c) {
                  final selected = _commodities.contains(c);
                  return FilterChip(
                    label: LabelKomoditas(commodity: c),
                    selected: selected,
                    onSelected: (v) => setState(() => v ? _commodities.add(c) : _commodities.remove(c)),
                    backgroundColor: AppColors.kertas,
                    selectedColor: AppColors.daunSamar,
                    side: BorderSide(color: selected ? AppColors.daun : AppColors.garis, width: selected ? 2 : 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),
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
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.kertas,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.garis)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.garis)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.daun, width: 2)),
    );
  }
}
