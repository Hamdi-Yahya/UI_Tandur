
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Bricolage Grotesque
  static final TextStyle tampilanBesar = GoogleFonts.bricolageGrotesque(
    fontSize: 34, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.8,
  );
  static final TextStyle tampilanSedang = GoogleFonts.bricolageGrotesque(
    fontSize: 26, height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.5,
  );
  static final TextStyle tampilanKecil = GoogleFonts.bricolageGrotesque(
    fontSize: 20, height: 1.25, fontWeight: FontWeight.w600, letterSpacing: -0.3,
  );

  // Plus Jakarta Sans
  static final TextStyle judul = GoogleFonts.plusJakartaSans(
    fontSize: 18, height: 1.35, fontWeight: FontWeight.w700,
  );
  static final TextStyle isiBesar = GoogleFonts.plusJakartaSans(
    fontSize: 16, height: 1.55, fontWeight: FontWeight.w400,
  );
  static final TextStyle isi = GoogleFonts.plusJakartaSans(
    fontSize: 15, height: 1.55, fontWeight: FontWeight.w400,
  );
  static final TextStyle isiTebal = GoogleFonts.plusJakartaSans(
    fontSize: 15, height: 1.50, fontWeight: FontWeight.w600,
  );
  static final TextStyle kecil = GoogleFonts.plusJakartaSans(
    fontSize: 13, height: 1.45, fontWeight: FontWeight.w400,
  );
  static final TextStyle label = GoogleFonts.plusJakartaSans(
    fontSize: 11, height: 1.30, fontWeight: FontWeight.w700, letterSpacing: 0.6,
  );

  // JetBrains Mono
  static final TextStyle angkaBesar = GoogleFonts.jetBrainsMono(
    fontSize: 28, height: 1.10, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final TextStyle angka = GoogleFonts.jetBrainsMono(
    fontSize: 14, height: 1.30, fontWeight: FontWeight.w500, fontFeatures: const [FontFeature.tabularFigures()],
  );
}
