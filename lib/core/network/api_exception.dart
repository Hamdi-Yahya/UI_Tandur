/// Galat API yang sudah dinormalkan. `fieldErrors` hanya terisi pada 400
/// validasi (lihat CATATAN_FE_FLUTTER.md 2.2 dan 3.1).
class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.fieldErrors,
  });

  final int statusCode;

  /// Selalu bisa ditampilkan ke pengguna. Untuk 400 validasi, ini gabungan pesan.
  final String message;

  /// Nilai dari enum ErrorCode backend. Cabangkan logika di sini, bukan di `message`.
  final String? code;

  /// field -> daftar pesan, untuk ditempel di bawah TextFormField.
  final Map<String, List<String>>? fieldErrors;

  bool get isValidation => fieldErrors != null;
  bool get isAccessTokenExpired => code == 'AUTH_TOKEN_EXPIRED';
  bool get isQuotaExceeded => code == 'QUOTA_EXCEEDED';
  bool get isModelNotAvailable => code == 'MODEL_NOT_AVAILABLE';
  bool get isIdempotencyInProgress => code == 'IDEMPOTENCY_IN_PROGRESS';

  /// Membangun dari body backend, menangani `msg` yang bisa String atau Map.
  factory ApiException.fromBody(int status, dynamic body) {
    if (body is! Map) {
      return ApiException(statusCode: status, message: 'Terjadi galat. Coba lagi.');
    }
    final msg = body['msg'];
    final code = body['code'] as String?;

    if (msg is Map) {
      final fields = msg.map<String, List<String>>(
        (k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()),
      );
      return ApiException(
        statusCode: status,
        message: fields.values.expand((e) => e).join('\n'),
        code: code,
        fieldErrors: fields,
      );
    }
    return ApiException(
      statusCode: status,
      message: msg?.toString() ?? 'Terjadi galat. Coba lagi.',
      code: code,
    );
  }

  /// Kode error stabil dari backend dibandingkan lewat getter di atas
  /// (mis. `isAccessTokenExpired`, `isQuotaExceeded`).

  @override
  String toString() => 'ApiException($statusCode${code == null ? '' : ', $code'}): $message';
}