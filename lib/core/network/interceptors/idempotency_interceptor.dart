import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Memasang Idempotency-Key di setiap mutasi. Kunci boleh ditentukan pemanggil
/// lewat `Options(extra: {'idempotencyKey': key})` -- wajib untuk aksi yang
/// diantre luring, supaya retry memakai kunci yang sama persis
/// (lihat CATATAN_FE_FLUTTER.md 2.3 dan 3.2).
class IdempotencyInterceptor extends Interceptor {
  static const _mutating = {'POST', 'PATCH', 'PUT', 'DELETE'};
  static const _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_mutating.contains(options.method.toUpperCase())) {
      options.headers['Idempotency-Key'] =
          options.extra['idempotencyKey'] as String? ?? _uuid.v4();
    }
    handler.next(options);
  }
}