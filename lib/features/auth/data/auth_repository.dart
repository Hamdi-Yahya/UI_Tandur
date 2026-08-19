import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/secure_token_store.dart';

/// Hasil signin/signup/google dari backend (API_DOCS bagian 1).
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.fullName,
    this.roles = const [],
    this.isNewUser = false,
  });

  final String userId;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String? fullName;
  final List<String> roles;
  final bool isNewUser;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['userId'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 3600,
      fullName: json['fullName'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? const [],
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }
}

/// Repository autentikasi. Semua method melempar [ApiException] yang sudah
/// ternormalisasi (lihat CATATAN_FE_FLUTTER.md 2.1-2.4).
class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final SecureTokenStore _storage;

  Future<AuthSession> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await guardApi(() => _dio.post(
          '/auth/signup',
          data: {'fullName': fullName, 'email': email, 'password': password},
        ));
    return AuthSession.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<AuthSession> signin({required String email, required String password}) async {
    final res = await guardApi(() => _dio.post(
          '/auth/signin',
          data: {'email': email, 'password': password},
        ));
    return AuthSession.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    final res = await guardApi(() => _dio.post(
          '/auth/google',
          data: {'idToken': idToken},
        ));
    return AuthSession.fromJson((res.data as Map).cast<String, dynamic>());
  }

  Future<void> session({required AuthSession session}) async {
    await _storage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  /// Logout: hapus refresh token di server (best-effort), lalu bersihkan lokal.
  Future<void> logout() async {
    final refresh = await _storage.refreshToken();
    try {
      if (refresh != null) {
        await guardApi(() => _dio.post('/auth/logout', data: {'refreshToken': refresh}));
      }
    } finally {
      await _storage.clear();
    }
  }

  /// Selalu membalas 200 dengan pesan generik, terdaftar atau tidak.
  Future<void> forgotPassword({required String email}) async {
    await guardApi(() => _dio.post(
          '/auth/forgot-password',
          data: {'email': email},
        ));
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await guardApi(() => _dio.post(
          '/auth/reset-password',
          data: {
            'token': token,
            'newPassword': newPassword,
            'confirmPassword': confirmPassword,
          },
        ));
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(secureTokenStoreProvider));
});