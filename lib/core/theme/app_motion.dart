import 'package:flutter/animation.dart';

class AppMotion {
  static const Duration umpanBalik = Duration(milliseconds: 120);
  static const Duration perpindahanLayar = Duration(milliseconds: 240);
  static const Duration lembarBawah = Duration(milliseconds: 280);
  static const Duration progresBertambah = Duration(milliseconds: 400);
  static const Duration pengairanPetak = Duration(milliseconds: 1400);
  static const Duration lesapCepat = Duration(milliseconds: 100);

  static const Curve kurvaUmpanBalik = Curves.easeOut;
  static const Curve kurvaPerpindahan = Curves.easeInOutCubic;
  static const Curve kurvaLembar = Curves.easeOutCubic;
  static const Curve kurvaProgres = Curves.easeOutQuart;
}
