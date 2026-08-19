import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/warung/data/warung_repository.dart';

/// Buat Pertanyaan — DESAIN.md rute `/warung/tanya`, PRD §5.3 US-11.
/// Butuh judul, isi, komoditas, maksimal 3 label, foto opsional maksimal 4.
/// Bisa dibuat langsung dari hasil pindai lewat `fromScanId` (state.extra).
/// Mengirim POST /api/community/questions; galat validasi dari server
/// ditempel ke kolom terkait (`e.fieldErrors`).
class BuatPertanyaanScreen extends ConsumerStatefulWidget {
  final String? fromScanId;
  final String? initialCommodity;

  const BuatPertanyaanScreen({
    super.key,
    this.fromScanId,
    this.initialCommodity,
  });

  @override
  ConsumerState<BuatPertanyaanScreen> createState() =>
      _BuatPertanyaanScreenState();
}

class _BuatPertanyaanScreenState extends ConsumerState<BuatPertanyaanScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagController = TextEditingController();
  String _commodity = 'CABAI';
  final List<String> _tags = [];

  bool _isLoading = false;
  String? _titleError;
  String? _bodyError;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _commodity = widget.initialCommodity ?? 'CABAI';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _tambahTag(String value) {
    final t = value.trim();
    if (t.isEmpty || _tags.length >= 3 || _tags.contains(t)) return;
    setState(() {
      _tags.add(t);
      _tagController.clear();
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _kirim() async {
    if (_titleController.text.trim().length < 10) {
      _snack('Judul minimal 10 karakter.');
      return;
    }
    // Backend hanya mengenal CABAI/TERONG/PADI (API_DOCS konvensi enum).
    if (_commodity == 'UMUM') {
      _snack('Pilih komoditas: Cabai, Terong, atau Padi.');
      return;
    }
    setState(() {
      _isLoading = true;
      _titleError = null;
      _bodyError = null;
      _serverError = null;
    });

    try {
      final result = await ref
          .read(warungRepositoryProvider)
          .createQuestion(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            commodity: _commodity,
            tags: _tags.isEmpty ? null : _tags,
            fromScanId: widget.fromScanId,
          );
      if (!mounted) return;
      _snack(
        result.xpEarned > 0
            ? 'Pertanyaan terkirim · +${result.xpEarned} XP'
            : 'Pertanyaan terkirim',
      );
      context.pushReplacement('/warung/p/${result.questionId}');
    } on ApiException catch (e) {
      if (!mounted) return;
      final title = e.fieldErrors?['title']?.join('\n');
      final body = e.fieldErrors?['body']?.join('\n');
      final tags = e.fieldErrors?['tags']?.join('\n');
      final photos = e.fieldErrors?['photos']?.join('\n');
      final commodity = e.fieldErrors?['commodity']?.join('\n');
      setState(() {
        _isLoading = false;
        _titleError = title;
        _bodyError = body;
        _serverError = (title == null && body == null) ? e.message : null;
      });
      final sisa = [tags, photos, commodity].whereType<String>().join('\n');
      if (sisa.isNotEmpty) _snack(sisa);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Buat Pertanyaan'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.fromScanId != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.daunSamar,
                    borderRadius: BorderRadius.circular(AppRadius.kecil),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: AppColors.daun,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          'Foto dan konteks dari hasil pindai ikut terbawa',
                          style: AppTypography.kecil.copyWith(
                            color: AppColors.daun,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
              Text(
                'Komoditas',
                style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                children: const ['CABAI', 'TERONG', 'PADI', 'UMUM'].map((c) {
                  final selected = c == _commodity;
                  return ChoiceChip(
                    label: LabelKomoditas(commodity: c),
                    selected: selected,
                    onSelected: (_) => setState(() => _commodity = c),
                    backgroundColor: AppColors.kertas,
                    selectedColor: AppColors.daunSamar,
                    side: BorderSide(
                      color: selected ? AppColors.daun : AppColors.garis,
                      width: selected ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.penuh),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Judul',
                style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
              ),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _titleController,
                style: AppTypography.isi.copyWith(color: AppColors.tanah),
                decoration: _dec(
                  'Misalnya: Daun cabai keriting tapi tidak ada kutunya',
                  errorText: _titleError,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Ceritakan lebih lengkap',
                style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
              ),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _bodyController,
                maxLines: 5,
                style: AppTypography.isi.copyWith(color: AppColors.tanah),
                decoration: _dec(
                  'Ceritakan gejalanya, sudah berapa lama, dan apa yang sudah dicoba',
                  errorText: _bodyError,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Label (maks. 3)',
                style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  ..._tags.map(
                    (t) => Chip(
                      label: Text(
                        t,
                        style: AppTypography.kecil.copyWith(
                          color: AppColors.daun,
                        ),
                      ),
                      backgroundColor: AppColors.daunSamar,
                      onDeleted: () => setState(() => _tags.remove(t)),
                    ),
                  ),
                  if (_tags.length < 3)
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _tagController,
                        style: AppTypography.kecil.copyWith(
                          color: AppColors.tanah,
                        ),
                        decoration: _dec('tambah label')
                            .copyWith(isDense: true),
                        onSubmitted: _tambahTag,
                      ),
                    ),
                ],
              ),
              if (_serverError != null) ...[
                const SizedBox(height: AppSpacing.l),
                Text(
                  _serverError!,
                  style: AppTypography.kecil.copyWith(color: AppColors.cabai),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terong,
                    foregroundColor: AppColors.kertas,
                    disabledBackgroundColor: AppColors.terongSamar,
                    disabledForegroundColor: AppColors.kertas,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.penuh),
                    ),
                    textStyle: AppTypography.isiTebal,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.kertas,
                          ),
                        )
                      : const Text('Tanya'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
      errorText: errorText,
      filled: true,
      fillColor: AppColors.kertas,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sedang),
        borderSide: const BorderSide(color: AppColors.garis),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sedang),
        borderSide: const BorderSide(color: AppColors.garis),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sedang),
        borderSide: const BorderSide(color: AppColors.daun, width: 2),
      ),
    );
  }
}
