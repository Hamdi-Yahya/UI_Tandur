import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/auth_controller.dart';
import 'package:tandur/features/saya/data/saya_repository.dart';
import 'package:tandur/features/saya/data/users_repository.dart';
import 'package:tandur/features/saya/presentation/widgets/saya_widgets.dart';

/// Pengaturan — rute `/saya/pengaturan`. Preferensi notifikasi
/// (API_DOCS bagian 6 Update Preferences), keluar, dan hapus akun (§2
/// Delete Account) — konfirmasi hapus akun ditampilkan sebagai dialog di
/// layar ini, bukan rute terpisah.
class PengaturanScreen extends ConsumerStatefulWidget {
  const PengaturanScreen({super.key});

  @override
  ConsumerState<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends ConsumerState<PengaturanScreen> {
  NotificationPreferences _prefs = const NotificationPreferences();
  bool _savingPrefs = false;

  Future<void> _keluar() async {
    await ref.read(authControllerProvider.notifier).signout();
    if (!mounted) return;
    context.go('/masuk');
  }

  Future<void> _konfirmasiHapusAkun() async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Batal', style: AppTypography.isiTebal.copyWith(color: AppColors.tanahLemah)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(passwordController.text),
            child: Text('Hapus', style: AppTypography.isiTebal.copyWith(color: AppColors.cabai)),
          ),
        ],
      ),
    );
    if (password == null || password.isEmpty || !mounted) return;
    await _hapusAkun(password: password);
  }

  Future<void> _hapusAkun({required String password}) async {
    try {
      await ref.read(usersRepositoryProvider).deleteAccount(password: password);
      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).signout();
      if (!mounted) return;
      context.go('/masuk');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi galat. Coba lagi.')));
    }
  }

  Future<void> _ubahPrefs(NotificationPreferences next) async {
    final sebelum = _prefs;
    setState(() {
      _prefs = next;
      _savingPrefs = true;
    });
    try {
      await ref.read(notificationRepositoryProvider).updatePreferences(next);
      if (!mounted) return;
      setState(() => _savingPrefs = false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _prefs = sebelum;
        _savingPrefs = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _prefs = sebelum;
        _savingPrefs = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi galat. Coba lagi.')));
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
              onChanged: _savingPrefs ? null : (v) => _ubahPrefs(_prefs.copyWith(scanReminder: v)),
            ),
            PreferenceSwitchRow(
              label: 'Balasan Warung Tani',
              value: _prefs.replyReceived,
              onChanged: _savingPrefs ? null : (v) => _ubahPrefs(_prefs.copyWith(replyReceived: v)),
            ),
            PreferenceSwitchRow(
              label: 'Jawaban ditandai terbaik',
              value: _prefs.bestAnswerMarked,
              onChanged: _savingPrefs ? null : (v) => _ubahPrefs(_prefs.copyWith(bestAnswerMarked: v)),
            ),
            PreferenceSwitchRow(
              label: 'Peringatan runtutan putus',
              value: _prefs.streakWarning,
              onChanged: _savingPrefs ? null : (v) => _ubahPrefs(_prefs.copyWith(streakWarning: v)),
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