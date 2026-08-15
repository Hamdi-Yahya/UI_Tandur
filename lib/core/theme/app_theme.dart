import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.daun,
        onPrimary: AppColors.kertas,
        primaryContainer: AppColors.daunSamar,
        onPrimaryContainer: AppColors.tanah,
        
        secondary: AppColors.air,
        onSecondary: AppColors.kertas,
        secondaryContainer: AppColors.airDalam,
        onSecondaryContainer: AppColors.kertas,
        
        error: AppColors.cabai,
        onError: AppColors.kertas,
        errorContainer: AppColors.cabaiSamar,
        onErrorContainer: AppColors.cabai,

        surface: AppColors.embun,
        onSurface: AppColors.tanah,
        
        outline: AppColors.garis,
        outlineVariant: AppColors.tanahSamar,
      ),
      scaffoldBackgroundColor: AppColors.embun,
      textTheme: TextTheme(
        displayLarge: AppTypography.tampilanBesar,
        displayMedium: AppTypography.tampilanSedang,
        displaySmall: AppTypography.tampilanKecil,
        titleLarge: AppTypography.judul,
        bodyLarge: AppTypography.isiBesar,
        bodyMedium: AppTypography.isi,
        bodySmall: AppTypography.kecil,
        labelSmall: AppTypography.label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.daun,
          foregroundColor: AppColors.kertas,
          minimumSize: const Size(64, 48), // minimum touch target 48 dp
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.penuh),
          ),
          elevation: 0, // Minim shadow dari desain
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.kertas,
        elevation: 0, // Jangan menambahkan shadow pada semua card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sedang),
          side: const BorderSide(color: AppColors.garis),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.embun,
        foregroundColor: AppColors.tanah,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.judul.copyWith(color: AppColors.tanah),
      ),
    );
  }
}
