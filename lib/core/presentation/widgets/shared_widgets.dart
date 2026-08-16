import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_motion.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';

/// Komponen yang dipakai lintas-fitur (DESAIN.md §5), dibangun sekali supaya
/// F2 Periksa Tanaman dan F3 Warung Tani tidak membuat versi berbeda-beda.

/// Header layar standar: tombol kembali + judul, opsional aksi di kanan.
/// Dipakai menggantikan AppBar bawaan supaya warna & tipografi konsisten.
class ScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? action;
  final VoidCallback? onBack;

  const ScreenAppBar({super.key, required this.title, this.action, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.embun,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.tanah),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        tooltip: 'Kembali',
      ),
      title: Text(title, style: AppTypography.judul.copyWith(color: AppColors.tanah)),
      actions: action == null ? null : [action!, const SizedBox(width: AppSpacing.s)],
    );
  }
}

/// Pil label komoditas dengan ikon dan warna aksen komoditas.
/// Dipakai di kartu tanaman (Periksa) dan kartu pertanyaan (Warung).
class LabelKomoditas extends StatelessWidget {
  final String commodity; // CABAI, TERONG, PADI, atau nilai lain untuk "Umum"

  const LabelKomoditas({super.key, required this.commodity});

  // Ikon disamakan dengan _KomoditasItem.ikonTemp di komoditas_screen.dart
  // (gaya garis/outlined, konsisten dengan bahasa Lucide di DESAIN.md §7.1 A5)
  // supaya komoditas terlihat sama di seluruh aplikasi, bukan cuma di
  // onboarding.
  static ({Color warna, Color latar, IconData ikon, String nama}) _rupa(String c) {
    switch (c) {
      case 'CABAI':
        return (warna: AppColors.cabai, latar: AppColors.cabaiSamar, ikon: Icons.local_fire_department_outlined, nama: 'Cabai');
      case 'TERONG':
        return (warna: AppColors.terong, latar: AppColors.terongSamar, ikon: Icons.spa_outlined, nama: 'Terong');
      case 'PADI':
        return (warna: AppColors.padi, latar: AppColors.padiSamar, ikon: Icons.grass_outlined, nama: 'Padi');
      default:
        return (warna: AppColors.tanahLemah, latar: AppColors.garis, ikon: Icons.forum_outlined, nama: 'Umum');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rupa = _rupa(commodity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 4),
      decoration: BoxDecoration(
        color: rupa.latar,
        borderRadius: BorderRadius.circular(AppRadius.penuh),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(rupa.ikon, size: 13, color: rupa.warna),
          const SizedBox(width: 4),
          Text(rupa.nama, style: AppTypography.label.copyWith(color: rupa.warna, letterSpacing: 0)),
        ],
      ),
    );
  }
}

/// Bilah keyakinan + persentase, huruf mono lebar sama.
class LencanaKeyakinan extends StatelessWidget {
  final double confidence; // 0.0 - 1.0
  final Color color;

  const LencanaKeyakinan({super.key, required this.confidence, this.color = AppColors.cabai});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.penuh),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: AppColors.garis,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          '${(confidence * 100).toStringAsFixed(0)}%',
          style: AppTypography.angka.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Kartu rujukan sumber — dapat diketuk, membuka lembar berisi kutipan lengkap.
class KartuRujukan extends StatelessWidget {
  final String title;
  final String publisher;
  final int year;
  final int? page;
  final String? url;

  const KartuRujukan({
    super.key,
    required this.title,
    required this.publisher,
    required this.year,
    this.page,
    this.url,
  });

  void _bukaLembar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kertas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.besar)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.judul.copyWith(color: AppColors.tanah)),
            const SizedBox(height: AppSpacing.s),
            Text(
              '$publisher, $year${page != null ? ', hlm. $page' : ''}',
              style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
            ),
            if (url != null) ...[
              const SizedBox(height: AppSpacing.l),
              Text(url!, style: AppTypography.kecil.copyWith(color: AppColors.daun)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _bukaLembar(context),
      borderRadius: BorderRadius.circular(AppRadius.kecil),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.embun,
          borderRadius: BorderRadius.circular(AppRadius.kecil),
          border: Border.all(color: AppColors.garis),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 18, color: AppColors.tanahLemah),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                '$publisher · $title${page != null ? ', hlm. $page' : ''}',
                style: AppTypography.kecil.copyWith(color: AppColors.tanah),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.tanahSamar),
          ],
        ),
      ),
    );
  }
}

/// Gelembung pesan diskusi — dua varian pengguna/asisten, dukungan kursor
/// berkedip sederhana saat sedang "mengalir" (streaming kosmetik dari mock).
class GelembungPesan extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isStreaming;

  const GelembungPesan({
    super.key,
    required this.content,
    required this.isUser,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
          decoration: BoxDecoration(
            color: isUser ? AppColors.daun : AppColors.kertas,
            borderRadius: BorderRadius.circular(AppRadius.sedang),
            border: isUser ? null : Border.all(color: AppColors.garis),
          ),
          child: RichText(
            text: TextSpan(
              style: AppTypography.isi.copyWith(color: isUser ? AppColors.kertas : AppColors.tanah),
              children: [
                TextSpan(text: content),
                if (isStreaming) const TextSpan(text: ' ▍'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kendali suara tegak — panah naik/turun dengan angka lebar sama di antaranya.
/// Target sentuh 48 dp walau ikonnya tampak kecil.
class KendaliSuara extends StatelessWidget {
  final int score;
  final int myVote; // 1, -1, atau 0
  final ValueChanged<int> onVote;

  const KendaliSuara({
    super.key,
    required this.score,
    required this.myVote,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            iconSize: 20,
            icon: Icon(Icons.keyboard_arrow_up, color: myVote == 1 ? AppColors.daun : AppColors.tanahSamar),
            onPressed: () => onVote(myVote == 1 ? 0 : 1),
            tooltip: 'Suara naik',
          ),
        ),
        Text(
          '$score',
          style: AppTypography.angka.copyWith(color: AppColors.tanah, fontWeight: FontWeight.w700),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            iconSize: 20,
            icon: Icon(Icons.keyboard_arrow_down, color: myVote == -1 ? AppColors.cabai : AppColors.tanahSamar),
            onPressed: () => onVote(myVote == -1 ? 0 : -1),
            tooltip: 'Suara turun',
          ),
        ),
      ],
    );
  }
}

/// Keadaan kosong — ilustrasi (ikon besar), satu kalimat, satu tindakan.
class KeadaanKosong extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const KeadaanKosong({
    super.key,
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.daunSamar, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: AppColors.daun),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
            ),
            const SizedBox(height: AppSpacing.l),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel, style: AppTypography.isiTebal.copyWith(color: AppColors.daun)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keadaan galat — menjelaskan apa yang terjadi dan langkah berikutnya.
class KeadaanGalat extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const KeadaanGalat({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 32, color: AppColors.cabai),
            const SizedBox(height: AppSpacing.l),
            Text(message, textAlign: TextAlign.center, style: AppTypography.isi.copyWith(color: AppColors.tanahLemah)),
            const SizedBox(height: AppSpacing.l),
            TextButton(
              onPressed: onRetry,
              child: Text('Coba lagi', style: AppTypography.isiTebal.copyWith(color: AppColors.daun)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kerangka muat — berkedip lembut, bukan indikator berputar.
class KerangkaMuat extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? radius;

  const KerangkaMuat({super.key, this.height = 16, this.width, this.radius});

  @override
  State<KerangkaMuat> createState() => _KerangkaMuatState();
}

class _KerangkaMuatState extends State<KerangkaMuat> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.5 + (_controller.value * 0.3);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.garis.withValues(alpha: opacity),
            borderRadius: widget.radius ?? BorderRadius.circular(AppRadius.kecil),
          ),
        );
      },
    );
  }
}

/// Chip saran/tindakan kecil yang bisa diketuk — dipakai untuk "Tanya lanjut"
/// dan label pertanyaan.
class ChipSaran extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ChipSaran({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sedang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.daunSamar,
          borderRadius: BorderRadius.circular(AppRadius.sedang),
        ),
        child: Text(label, style: AppTypography.kecil.copyWith(color: AppColors.daun, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Lingkaran avatar berisi huruf awal nama, warna latar konsisten dari
/// nama itu sendiri. Dipakai di Profil Saya dan Profil Publik supaya kedua
/// layar tidak membangun versi berbeda dari hal yang sama.
class InitialAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialAvatar({super.key, required this.name, this.radius = 32});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.daunSamar,
      child: Text(
        initial,
        style: AppTypography.tampilanSedang.copyWith(color: AppColors.daun, fontSize: radius * 0.7),
      ),
    );
  }
}

/// Kotak foto placeholder — dipakai di mana pun belum ada foto sungguhan
/// (hasil pindai, lampiran pertanyaan). Satu gaya visual untuk semua,
/// bukan `Container` abu-abu yang beda-beda tiap layar.
class PhotoPlaceholder extends StatelessWidget {
  final IconData icon;
  final BorderRadius? radius;

  const PhotoPlaceholder({super.key, this.icon = Icons.image_outlined, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.embun,
        borderRadius: radius ?? BorderRadius.circular(AppRadius.sedang),
        border: Border.all(color: AppColors.garis),
      ),
      child: Center(child: Icon(icon, size: 32, color: AppColors.tanahSamar)),
    );
  }
}

/// Transisi ringan bawaan, dipakai berulang untuk AnimatedSwitcher kecil.
const Duration kTransisiRingan = AppMotion.umpanBalik;
