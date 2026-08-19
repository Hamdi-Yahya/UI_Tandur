import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';

/// Satu baris menu di layar Profil Saya / Pengaturan — ikon, label, dan
/// opsional nilai di kanan sebelum panah.
class MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final Color iconColor;

  const MenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.iconColor = AppColors.tanahLemah,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacing.m),
            Expanded(child: Text(label, style: AppTypography.isi.copyWith(color: AppColors.tanah))),
            if (value != null) ...[
              Text(value!, style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar)),
              const SizedBox(width: AppSpacing.s),
            ],
            const Icon(Icons.chevron_right, size: 20, color: AppColors.tanahSamar),
          ],
        ),
      ),
    );
  }
}

/// Sakelar preferensi — label + Switch, target sentuh cukup lebar.
/// `onChanged` bernilai null saat sedang menyimpan ke server (Switch mati).
class PreferenceSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const PreferenceSwitchRow({super.key, required this.label, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.isi.copyWith(color: AppColors.tanah))),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.daun),
        ],
      ),
    );
  }
}
