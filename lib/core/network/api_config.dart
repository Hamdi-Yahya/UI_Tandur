/// Konfigurasi akses ke backend TANDUR.
///
/// Base URL dapat di-override saat build:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
///
/// Default: backend produksi di Railway (deploy Mikail, 19 Agu 2026).
/// Untuk dev lokal lawan backend lokal, selalu beri --dart-define di atas
/// (CATATAN_FE_FLUTTER.md bagian 1).
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');
  static const String _production = 'https://api-production-65ed.up.railway.app/api';

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return _production;
  }
}