import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_mock_data.dart';
import 'package:tandur/features/saya/presentation/widgets/saya_widgets.dart';

/// Pengaturan — rute `/saya/pengaturan`. Preferensi notifikasi
/// (API_DOCS_NEW.md §6 Update Preferences), keluar, dan hapus akun (§2
/// Delete Account) — konfirmasi hapus akun ditampilkan sebagai dialog di
/// layar ini, bukan rute terpisah.
class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final _prefs = SayaMockData.preferences;

  void _keluar() {
    context.go('/masuk');
  }

  Future<void> _konfirmasiHapusAkun() async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.kertas,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sedang)),
        title: Text('Hapus akun?', style: AppTypography.judul.copyWith(color: AppColors.tanah)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun dijadwalkan dihapus dalam 30 hari beserta seluruh datanya. Masukkan kata sandi untuk melanjutkan.',
              style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
            ),
            const SizedBox(height: AppSpacing.l),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: AppTypography.isi.copyWith(color: AppColors.tanah),
              decoration: InputDecoration(
                hintText: 'Kata sandi',
                hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
                filled: true,
                fillColor: AppColors.embun,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sedang), borderSide: const BorderSide(color: AppColors.garis)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Batal', style: AppTypography.isiTebal.copyWith(color: AppColors.tanahLemah)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Hapus', style: AppTypography.isiTebal.copyWith(color: AppColors.cabai)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun dijadwalkan dihapus dalam 30 hari.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      appBar: const ScreenAppBar(title: 'Pengaturan'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Text('Notifikasi', style: AppTypography.label.copyWith(color: AppColors.tanahSamar)),
            const SizedBox(height: AppSpacing.s),
            PreferenceSwitchRow(
              label: 'Pengingat periksa tanaman',
              value: _prefs.scanReminder,
              onChanged: (v) => setState(() => _prefs.scanReminder = v),
            ),
            PreferenceSwitchRow(
              label: 'Balasan Warung Tani',
              value: _prefs.replyReceived,
              onChanged: (v) => setState(() => _prefs.replyReceived = v),
            ),
            PreferenceSwitchRow(
              label: 'Jawaban ditandai terbaik',
              value: _prefs.bestAnswerMarked,
              onChanged: (v) => setState(() => _prefs.bestAnswerMarked = v),
            ),
            PreferenceSwitchRow(
              label: 'Peringatan runtutan putus',
              value: _prefs.streakWarning,
              onChanged: (v) => setState(() => _prefs.streakWarning = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: AppColors.garis),
            const SizedBox(height: AppSpacing.l),
            Text('Akun', style: AppTypography.label.copyWith(color: AppColors.tanahSamar)),
            MenuRow(icon: Icons.logout, label: 'Keluar', onTap: _keluar),
            MenuRow(
              icon: Icons.delete_outline,
              label: 'Hapus Akun',
              iconColor: AppColors.cabai,
              onTap: _konfirmasiHapusAkun,
            ),
          ],
        ),
      ),
    );
  }
}
