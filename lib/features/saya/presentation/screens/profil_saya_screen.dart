import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/saya/data/saya_repository.dart';
import 'package:tandur/features/saya/data/users_repository.dart';
import 'package:tandur/features/saya/presentation/widgets/saya_widgets.dart';

/// Profil Saya (Utama) — rute `/saya`. Pintu masuk ke Ubah Profil, Riwayat XP,
/// Koleksi Lencana, Pusat Notifikasi, dan Pengaturan.
class ProfilSayaScreen extends ConsumerStatefulWidget {
  const ProfilSayaScreen({super.key});

  @override
  ConsumerState<ProfilSayaScreen> createState() => _ProfilSayaScreenState();
}

class _ProfilSayaScreenState extends ConsumerState<ProfilSayaScreen> {
  UserProfile? _profile;
  GamificationStats? _stats;
  String? _error;
  bool _loading = true;
  bool _membeli = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _loading = _profile == null;
      _error = null;
    });
    try {
      final profile = await ref.read(usersRepositoryProvider).getMe();
      final stats = await ref.read(gamificationRepositoryProvider).getStats();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _stats = stats;
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

  /// Membeli Pelindung Runtutan seharga 200 XP (API_DOCS 3.4).
  ///
  /// ALASAN kenapa tombol ini ada: sebelumnya XP hanya menumpuk tanpa satu pun
  /// cara membelanjakannya, sehingga gamifikasinya terasa tidak berujung.
  /// Endpoint dan metode repositorinya sudah lama ada, hanya tidak pernah
  /// dipanggil dari layar mana pun.
  ///
  /// Pesan galat dari backend ditampilkan apa adanya karena sudah berbahasa
  /// manusia dan menyebut angka yang tepat, misalnya berapa XP yang kurang.
  /// Menggantinya dengan pesan sendiri malah membuang keterangan itu.
  Future<void> _beliPelindung() async {
    if (_membeli) return;
    setState(() => _membeli = true);
    try {
      final hasil = await ref.read(gamificationRepositoryProvider).buyStreakFreeze();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pelindung Runtutan dibeli. Sisa XP kamu ${hasil.totalXp}.')),
      );
      await _muat();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membeli. Periksa koneksi internet.')),
      );
    } finally {
      if (mounted) setState(() => _membeli = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final stats = _stats;
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: _loading
            ? const _KerangkaProfil()
            : profile == null
                ? KeadaanGalat(message: _error ?? 'Terjadi galat. Coba lagi.', onRetry: _muat)
                : RefreshIndicator(
                    onRefresh: _muat,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InitialAvatar(name: profile.fullName, radius: 32),
                              const SizedBox(width: AppSpacing.l),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(profile.fullName, style: AppTypography.tampilanKecil.copyWith(color: AppColors.tanah)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${profile.district ?? '-'} · Reputasi ${profile.reputation}',
                                      style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.l),
                            decoration: BoxDecoration(
                              color: AppColors.kertas,
                              borderRadius: BorderRadius.circular(AppRadius.sedang),
                              border: Border.all(color: AppColors.garis),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _Stat(icon: Icons.bolt, color: AppColors.padi, value: '${stats?.totalXp ?? 0}', label: 'XP'),
                                _Stat(icon: Icons.local_fire_department, color: AppColors.cabai, value: '${stats?.streakDays ?? 0}', label: 'Runtutan'),
                                _Stat(icon: Icons.workspace_premium, color: AppColors.daun, value: '${stats?.badgeCount ?? 0}', label: 'Lencana'),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _KartuPelindungRuntutan(
                            jumlah: stats?.streakFreezeCount ?? 0,
                            totalXp: stats?.totalXp ?? 0,
                            sedangMembeli: _membeli,
                            onBeli: _beliPelindung,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                            decoration: BoxDecoration(
                              color: AppColors.kertas,
                              borderRadius: BorderRadius.circular(AppRadius.sedang),
                              border: Border.all(color: AppColors.garis),
                            ),
                            child: Column(
                              children: [
                                MenuRow(icon: Icons.edit_outlined, label: 'Ubah Profil', onTap: () => context.push('/saya/ubah')),
                                const Divider(height: 1, color: AppColors.garis),
                                MenuRow(icon: Icons.bar_chart, label: 'Riwayat XP', onTap: () => context.push('/saya/xp')),
                                const Divider(height: 1, color: AppColors.garis),
                                MenuRow(icon: Icons.workspace_premium_outlined, label: 'Koleksi Lencana', onTap: () => context.push('/saya/lencana')),
                                const Divider(height: 1, color: AppColors.garis),
                                MenuRow(icon: Icons.notifications_outlined, label: 'Pusat Notifikasi', onTap: () => context.push('/saya/notifikasi')),
                                const Divider(height: 1, color: AppColors.garis),
                                MenuRow(icon: Icons.settings_outlined, label: 'Pengaturan', onTap: () => context.push('/saya/pengaturan')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

/// Kerangka muat saat profil dan statistik baru diambil dari server.
class _KerangkaProfil extends StatelessWidget {
  const _KerangkaProfil();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              KerangkaMuat(height: 64, width: 64, radius: BorderRadius.all(Radius.circular(32))),
              SizedBox(width: AppSpacing.l),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                KerangkaMuat(height: 20, width: 160),
                SizedBox(height: AppSpacing.s),
                KerangkaMuat(height: 14, width: 120),
              ])),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const KerangkaMuat(height: 96),
          const SizedBox(height: AppSpacing.xl),
          const KerangkaMuat(height: 240),
        ],
      ),
    );
  }
}

/// Kartu beli Pelindung Runtutan.
///
/// Harga dan batas stok ditulis di sini hanya untuk MENAMPILKAN keterangan dan
/// menonaktifkan tombol lebih awal. Yang menentukan tetap backend: kalau angka
/// ini nanti berubah di sana, permintaannya ditolak dengan pesan yang benar dan
/// pengguna tetap melihat alasan yang tepat, bukan tombol yang berbohong.
class _KartuPelindungRuntutan extends StatelessWidget {
  static const _harga = 200;
  static const _maksStok = 2;

  final int jumlah;
  final int totalXp;
  final bool sedangMembeli;
  final Future<void> Function() onBeli;

  const _KartuPelindungRuntutan({
    required this.jumlah,
    required this.totalXp,
    required this.sedangMembeli,
    required this.onBeli,
  });

  @override
  Widget build(BuildContext context) {
    final penuh = jumlah >= _maksStok;
    final xpKurang = totalXp < _harga;
    final bisaBeli = !penuh && !xpKurang && !sedangMembeli;

    final String keterangan;
    if (penuh) {
      keterangan = 'Stok sudah penuh.';
    } else if (xpKurang) {
      keterangan = 'Kurang ${_harga - totalXp} XP lagi.';
    } else {
      keterangan = 'Menjaga runtutanmu kalau kamu melewatkan satu hari.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.kertas,
        borderRadius: BorderRadius.circular(AppRadius.sedang),
        border: Border.all(color: AppColors.garis),
      ),
      child: Row(
        children: [
          Icon(Icons.ac_unit, color: AppColors.daun, size: 26),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pelindung Runtutan  $jumlah/$_maksStok',
                  style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
                ),
                const SizedBox(height: 2),
                Text(
                  keterangan,
                  style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          sedangMembeli
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: bisaBeli ? () => onBeli() : null,
                  child: Text('$_harga XP'),
                ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.angkaBesar.copyWith(color: AppColors.tanah, fontSize: 20)),
        Text(label, style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah)),
      ],
    );
  }
}
