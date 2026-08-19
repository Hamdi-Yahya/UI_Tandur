import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../secure_token_store.dart';

/// Memasang Authorization Bearer dan menangani refresh saat 401.
/// Refresh dibagi satu `Future` supaya request paralel tidak saling menimpa
/// (lihat CATATAN_FE_FLUTTER.md 3.3).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);

  final SecureTokenStore _storage;
  final Dio _dio;
  Future<String>? _refreshing; // dibagi oleh semua request yang menunggu

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['public'] != true) {
      final token = await _storage.accessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final code = (data is Map) ? data['code'] as String? : null;

    // Hanya token akses kedaluwarsa yang layak diulang. AUTH_REFRESH_INVALID
    // berarti sesi benar-benar habis, dan mengulang endpoint refresh akan
    // jadi loop tak berujung.
    final retryable = status == 401 &&
        code != _ErrorCode.authRefreshInvalid &&
        err.requestOptions.extra['retried'] != true &&
        !err.requestOptions.path.contains('/auth/refresh');

    if (!retryable) return handler.next(err);

    try {
      final fresh = await (_refreshing ??= _refreshAccessToken());
      final opts = err.requestOptions..extra['retried'] = true;
      opts.headers['Authorization'] = 'Bearer $fresh';
      handler.resolve(await _dio.fetch(opts));
    } catch (_) {
      await _storage.clear(); // paksa ke layar login lewat listener Riverpod
      handler.next(err);
    } finally {
      _refreshing = null;
    }
  }

  Future<String> _refreshAccessToken() async {
    final refresh = await _storage.refreshToken();
    if (refresh == null) throw StateError('tidak ada refresh token');

    // Dio terpisah: tanpa interceptor ini, supaya tidak rekursif.
    final res = await Dio(_dio.options).post(
      '/auth/refresh',
      data: {'refreshToken': refresh},
      options: Options(headers: {'Idempotency-Key': const Uuid().v4()}),
    );

    // Response refresh HANYA berisi accessToken -- lihat CATATAN 2.4.
    // Jangan sentuh refreshToken.
    final body = res.data is Map ? res.data as Map : const {};
    final data = body['data'] is Map ? body['data'] as Map : const {};
    final access = data['accessToken'] as String;
    await _storage.saveAccessToken(access);
    return access;
  }
}

class _ErrorCode {
  static const authRefreshInvalid = 'AUTH_REFRESH_INVALID';
}