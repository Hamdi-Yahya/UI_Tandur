import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/envelope_interceptor.dart';
import 'interceptors/idempotency_interceptor.dart';
import 'secure_token_store.dart';

/// Penyimpanan token aman (flutter_secure_storage).
final secureTokenStoreProvider = Provider<SecureTokenStore>((ref) {
  return SecureTokenStore();
});

/// Klien HTTP tunggal untuk seluruh aplikasi. Urutan interceptor penting:
/// Dio menjalankan onRequest sesuai urutan daftar, tapi onResponse/onError
/// terbalik (lihat CATATAN_FE_FLUTTER.md bagian 3).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  final storage = ref.watch(secureTokenStoreProvider);
  dio.interceptors.addAll([
    AuthInterceptor(storage, dio),
    IdempotencyInterceptor(),
    EnvelopeInterceptor(),
    if (kDebugMode)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
  ]);

  return dio;
});

/// Pembungkus kecil agar repository tidak perlu menulis blok try/catch yang
/// sama berulang kali. Melempar [ApiException] yang sudah ternormalisasi.
Future<T> guardApi<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on ApiException {
    rethrow;
  } on DioException catch (e) {
    final inner = e.error;
    if (inner is ApiException) throw inner;
    throw ApiException.fromBody(e.response?.statusCode ?? 0, e.response?.data);
  } catch (_) {
    throw ApiException(statusCode: 0, message: 'Terjadi galat. Coba lagi.');
  }
}