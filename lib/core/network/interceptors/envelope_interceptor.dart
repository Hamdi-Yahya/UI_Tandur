import 'package:dio/dio.dart';

import '../api_exception.dart';

/// Memisahkan amplop `{ msg, data }` dari backend. Repository menerima
/// payload murni lewat `res.data`, dan galat dinormalkan jadi `ApiException`
/// (lihat CATATAN_FE_FLUTTER.md 2.1, 2.2, 3.4).
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // SSE dan unduhan biner tidak berbentuk amplop.
    if (response.data is Map && (response.data as Map).containsKey('msg')) {
      response.extra['msg'] = response.data['msg']; // simpan untuk snackbar sukses
      response.data = (response.data as Map)['data']; // repository terima payload murni
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    if (res != null) {
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: res,
        type: err.type,
        error: ApiException.fromBody(res.statusCode ?? 0, res.data),
      ));
      return;
    }
    // Tidak ada response: timeout, DNS, sinyal putus.
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      type: err.type,
      error: ApiException(
        statusCode: 0,
        message: 'Tidak ada koneksi. Perubahanmu akan dikirim saat online.',
      ),
    ));
  }
}