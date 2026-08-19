import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/users_repository.dart';

/// Ubah Profil — rute `/saya/ubah`, API_DOCS bagian 2 Update Profile.
class UbahProfilScreen extends ConsumerStatefulWidget {
  const UbahProfilScreen({super.key});

  @override
  ConsumerState<UbahProfilScreen> createState() => _UbahProfilScreenState();
}

class _UbahProfilScreenState extends ConsumerState<UbahProfilScreen> {
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  List<Commodity> _commodities = const [];
  Map<String, String> _fieldErrors = const {};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _muatProfil() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ref.read(usersRepositoryProvider).getMe();
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.fullName;
        _districtController.text = profile.district ?? '';
        _commodities = List.of(profile.commodities);
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

  Future<void> _simpan() async {
    setState(() {
      _saving = true;
      _fieldErrors = const {};
    });
    try {
      await ref.read(usersRepositoryProvider).updateMe(
            fullName: _nameController.text.trim(),
            district: _districtController.text.trim(),
            commodities: _commodities,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (e.isValidation && e.fieldErrors != null) {
          _fieldErrors = e.fieldErrors!.map((k, v) => MapEntry(k, v.join('\n')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi galat. Coba lagi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Ubah Profil'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.daun))
            : _error != null
                ? KeadaanGalat(message: _error!, onRetry: _muatProfil)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama lengkap', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                        const SizedBox(height: AppSpacing.s),
                        TextField(
                          controller: _nameController,
                          style: AppTypography.isi.copyWith(color: AppColors.tanah),
                          decoration: _dec(errorText: _fieldErrors['fullName']),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text('Kabupaten', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                        const SizedBox(height: AppSpacing.s),
                        TextField(
                          controller: _districtController,
                          style: AppTypography.isi.copyWith(color: AppColors.tanah),
                          decoration: _dec(errorText: _fieldErrors['district']),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text('Komoditas diminati', style: AppTypography.isiTebal.copyWith(color: AppColors.tanah)),
                        const SizedBox(height: AppSpacing.s),
                        if (_fieldErrors['commodities'] != null) ...[
                          Text(
                            _fieldErrors['commodities']!,
                            style: AppTypography.kecil.copyWith(color: Theme.of(context).colorScheme.error),
                          ),
                          const SizedBox(height: AppSpacing.s),
                        ],
                        Wrap(
                          spacing: AppSpacing.s,
                          runSpacing: AppSpacing.s,
                          children: const [Commodity.cabai, Commodity.terong, Commodity.padi].map((c) {
                            final selected = _commodities.contains(c);
                            return PilihanKomoditasChip(
                              commodity: c.apiValue,
                              isSelected: selected,
                              onSelected: (v) {
                                setState(() {
                                  final list = List<Commodity>.from(_commodities);
                                  if (v) {
                                    if (!list.contains(c)) list.add(c);
                                  } else {
                                    list.remove(c);
                                  }
                                  _commodities = list;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _simpan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.daun,
                              foregroundColor: AppColors.kertas,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.penuh)),
                              textStyle: AppTypography.isiTebal,
                            ),
                            child: _saving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.kertas))
                                : const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  InputDecoration _dec({String? errorText}) {
    return InputDecoration(
      errorText: errorText,
      filled: true,
      fillColor: AppColors.kertas,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.garis)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.garis)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.daun, width: 2)),
    );
  }
}
