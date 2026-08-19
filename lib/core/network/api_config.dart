import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Konfigurasi akses ke backend TANDUR.
///
/// Base URL dapat di-override saat build:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
///
/// Default mengikuti panduan CATATAN_FE_FLUTTER.md bagian 1:
///   - Android emulator : http://10.0.2.2:3000/api
///   - iOS / web        : http://localhost:3000/api
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }
}