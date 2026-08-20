import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan token aman memakai flutter_secure_storage
/// (lihat CATATAN_FE_FLUTTER.md 2.4).
class SecureTokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  // Penanda menetap bahwa pengguna pernah berhasil masuk atau mendaftar di perangkat ini.
  // Digunakan oleh AppRouter agar pengguna lama langsung diarahkan ke /masuk, bukan /onboarding.
  static const _hasAccountKey = 'has_account';

  Future<String?> accessToken() => _storage.read(key: _accessKey);
  Future<String?> refreshToken() => _storage.read(key: _refreshKey);

  /// Memeriksa apakah pengguna pernah memiliki akun sebelumnya di perangkat ini.
  Future<bool> hasAccount() async {
    final val = await _storage.read(key: _hasAccountKey);
    return val == 'true';
  }

  /// Menyimpan penanda bahwa pengguna pernah memiliki akun.
  Future<void> setHasAccount([bool value = true]) =>
      _storage.write(key: _hasAccountKey, value: value ? 'true' : 'false');

  Future<void> saveAccessToken(String token) => _storage.write(key: _accessKey, value: token);
  Future<void> saveRefreshToken(String token) => _storage.write(key: _refreshKey, value: token);

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    // Tandai secara menetap bahwa pengguna memiliki akun saat token berhasil disimpan
    await setHasAccount(true);
  }

  /// Menghapus token saat logout atau sesi mati.
  /// ALASAN: `_hasAccountKey` sengaja TIDAK dihapus di sini agar penanda "pernah punya akun"
  /// tetap bertahan melewati keluar akun, sehingga pengguna lama tidak dilempar kembali
  /// ke layar perkenalan (onboarding) saat membuka aplikasi lagi.
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}