import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/app_enums.dart';
import 'periksa_models.dart';

/// Repository F2 Periksa Tanaman. Semua method melempar [ApiException] yang
/// sudah ternormalisasi (CATATAN_FE_FLUTTER.md 2.1-2.6). Payload sudah dikupas
/// amplopnya oleh interceptor, jadi `res.data` adalah isi `data` mentah.
class PeriksaRepository {
  PeriksaRepository(this._dio);

  final Dio _dio;

  // ───────────────────────────── Tanaman ─────────────────────────────

  /// POST /api/plants — respons hanya membawa bentuk singkat (tanpa
  /// unitCount/unitType), jadi lanjutkan dengan `getPlants` bila perlu.
  Future<PlantCreated> createPlant({
    required Commodity commodity,
    required String nickname,
    required int unitCount,
    required UnitType unitType,
    required DateTime plantedAt,
    String? variety,
  }) async {
    final res = await guardApi(() => _dio.post(
          '/plants',
          data: {
            'commodity': commodity.apiValue,
            'nickname': nickname,
            'unitCount': unitCount,
            'unitType': unitType.apiValue,
            'plantedAt': _formatDate(plantedAt),
            if (variety != null && variety.isNotEmpty) 'variety': variety,
          },
        ));
    return PlantCreated.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// GET /api/plants — satu-satunya endpoint yang mengembalikan daftar
  /// telanjang di dalam data (bukan { items, nextCursor }).
  Future<List<Plant>> getPlants({PlantStatus? status}) async {
    final res = await guardApi(() => _dio.get(
          '/plants',
          queryParameters: status == null ? null : {'status': status.apiValue},
        ));
    return (res.data as List)
        .map((e) => Plant.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// GET /api/plants/:id
  Future<PlantDetail> getPlantDetail(String plantId) async {
    final res = await guardApi(() => _dio.get('/plants/$plantId'));
    return PlantDetail.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// PATCH /api/plants/:id — hanya nickname dan unitCount yang bisa diubah.
  Future<({String plantId, String nickname})> updatePlant(
    String plantId, {
    String? nickname,
    int? unitCount,
  }) async {
    final res = await guardApi(() => _dio.patch(
          '/plants/$plantId',
          data: {
            if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
            'unitCount': ?unitCount,
          },
        ));
    final json = (res.data as Map).cast<String, dynamic>();
    return (
      plantId: json['plantId'] as String? ?? plantId,
      nickname: json['nickname'] as String? ?? '',
    );
  }

  /// POST /api/plants/:id/end
  Future<PlantEndResult> endPlant(
    String plantId, {
    required PlantStatus status,
    required DateTime endedAt,
    String? note,
  }) async {
    final res = await guardApi(() => _dio.post(
          '/plants/$plantId/end',
          data: {
            'status': status.apiValue,
            'endedAt': _formatDate(endedAt),
            if (note != null && note.isNotEmpty) 'note': note,
          },
        ));
    return PlantEndResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// DELETE /api/plants/:id
  Future<void> deletePlant(String plantId) async {
    await guardApi(() => _dio.delete('/plants/$plantId'));
  }

  // ───────────────────────────── Pindai ─────────────────────────────

  /// GET /api/vision/model?commodity=X. Komoditas yang belum punya model
  /// membalas 404 dengan `code: MODEL_NOT_AVAILABLE` — keadaan normal,
  /// cek lewat [ApiException.isModelNotAvailable].
  Future<ModelManifest> getModelManifest(Commodity commodity) async {
    final res = await guardApi(() => _dio.get(
          '/vision/model',
          queryParameters: {'commodity': commodity.apiValue},
        ));
    return ModelManifest.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// POST /api/uploads/signed-url — kunci idempotensi baru tiap panggilan
  /// otomatis dibuat interceptor (POST yang sifatnya "membaca").
  Future<SignedUploadUrl> getSignedUploadUrl({
    UploadPurpose purpose = UploadPurpose.scan,
    required String contentType,
    required int sizeBytes,
  }) async {
    final res = await guardApi(() => _dio.post(
          '/uploads/signed-url',
          data: {
            'purpose': purpose.apiValue,
            'contentType': contentType,
            'sizeBytes': sizeBytes,
          },
        ));
    return SignedUploadUrl.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// POST /api/scans. [imageUrl] wajib ada di body; isi dengan '' sampai
  /// langkah unggah foto tersambung (Camera + kompresi gambar).
  /// Backend yang mengurutkan, menyaring, dan memutuskan DONE/LOW_CONFIDENCE.
  Future<ScanResult> saveScan({
    required String plantId,
    String imageUrl = '',
    String? modelVersion,
    int? inferenceMs,
    required List<ScanPrediction> predictions,
    required DateTime capturedAt,
  }) async {
    final res = await guardApi(() => _dio.post(
          '/scans',
          data: {
            'plantId': plantId,
            'imageUrl': imageUrl,
            'modelVersion': ?modelVersion,
            'inferenceMs': ?inferenceMs,
            'predictions': predictions
                .map((p) => {'label': p.label, 'confidence': p.confidence})
                .toList(),
            'capturedAt': capturedAt.toUtc().toIso8601String(),
          },
        ));
    return ScanResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// GET /api/scans/:id
  Future<ScanResult> getScan(String scanId) async {
    final res = await guardApi(() => _dio.get('/scans/$scanId'));
    return ScanResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// GET /api/plants/:id/scans — cursor paginasi; `nextCursor: null` pada
  /// hasil berarti halaman terakhir.
  Future<ScanTimelinePage> getPlantScans(
    String plantId, {
    int? limit,
    String? cursor,
  }) async {
    final res = await guardApi(() => _dio.get(
          '/plants/$plantId/scans',
          queryParameters: {
            'limit': ?limit,
            'cursor': ?cursor,
          },
        ));
    return ScanTimelinePage.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// POST /api/scans/:id/flag — lapor label yang keliru.
  Future<String> flagScan(
    String scanId, {
    required ScanFlagReason reason,
    String? userGuess,
    String? note,
  }) async {
    final res = await guardApi(() => _dio.post(
          '/scans/$scanId/flag',
          data: {
            'reason': reason.apiValue,
            if (userGuess != null && userGuess.isNotEmpty) 'userGuess': userGuess,
            if (note != null && note.isNotEmpty) 'note': note,
          },
        ));
    final json = (res.data as Map).cast<String, dynamic>();
    return json['flagId'] as String? ?? '';
  }

  /// DELETE /api/scans/:id
  Future<void> deleteScan(String scanId) async {
    await guardApi(() => _dio.delete('/scans/$scanId'));
  }

  // ───────────────────────────── Diskusi ─────────────────────────────

  /// POST /api/discussions. Scan yang sudah punya diskusi membalas 409
  /// ("Pindai ini sudah punya diskusi") — baca `discussionId` dari
  /// `GET /api/scans/:id` lalu muat percakapan yang sudah ada.
  Future<DiscussionStarted> createDiscussion(String scanId) async {
    final res = await guardApi(() => _dio.post('/discussions', data: {'scanId': scanId}));
    return DiscussionStarted.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// GET /api/discussions/:id
  Future<DiscussionDetail> getDiscussion(String discussionId) async {
    final res = await guardApi(() => _dio.get('/discussions/$discussionId'));
    return DiscussionDetail.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// GET /api/discussions/quota — cek sebelum pengguna mengetik panjang,
  /// dan tangani 403 QUOTA_EXCEEDED saat mengirim.
  Future<DiscussionQuota> getDiscussionQuota() async {
    final res = await guardApi(() => _dio.get('/discussions/quota'));
    return DiscussionQuota.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// POST /api/discussions/:id/messages — satu-satunya endpoint tanpa amplop
  /// (CATATAN_FE_FLUTTER.md 2.1 & 6). Membaca aliran `text/event-stream`
  /// dan mengubahnya menjadi peristiwa bertipe. `ResponseType.stream` wajib,
  /// kalau tidak Dio menunggu sampai selesai.
  Stream<DiscussionSseEvent> sendMessage(String discussionId, String content) async* {
    final res = await guardApi(() => _dio.post<ResponseBody>(
          '/discussions/$discussionId/messages',
          data: {'content': content},
          options: Options(responseType: ResponseType.stream),
        ));
    final body = res.data;
    if (body == null) return;

    var buffer = '';
    await for (final chunk in body.stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      var idx = buffer.indexOf('\n\n');
      while (idx != -1) {
        final event = _parseSseBlock(buffer.substring(0, idx));
        buffer = buffer.substring(idx + 2);
        if (event != null) yield event;
        idx = buffer.indexOf('\n\n');
      }
    }
  }

  /// POST /api/discussions/messages/:id/rate
  Future<void> rateMessage(String messageId, {required bool helpful}) async {
    await guardApi(() => _dio.post(
          '/discussions/messages/$messageId/rate',
          data: {'helpful': helpful},
        ));
  }

  // ───────────────────────────── Bantuan ─────────────────────────────

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Satu blok SSE (`event:`/`data:` dipisah baris kosong ganda). Blok yang
  /// tidak dikenal atau JSON rusak dilewati diam-diam.
  DiscussionSseEvent? _parseSseBlock(String block) {
    String? event;
    String? data;
    for (final line in block.split('\n')) {
      if (line.startsWith('event: ')) {
        event = line.substring(7);
      } else if (line.startsWith('data: ')) {
        data = line.substring(6);
      }
    }
    if (event == null || data == null) return null;

    final Map<String, dynamic>? payload;
    try {
      payload = (jsonDecode(data) as Map).cast<String, dynamic>();
    } on FormatException {
      return null;
    }

    switch (event) {
      case 'start':
        return SseStartEvent(
          messageId: payload['messageId'] as String? ?? '',
          model: payload['model'] as String?,
        );
      case 'chunk':
        return SseChunkEvent(text: payload['text'] as String? ?? '');
      case 'citations':
        return SseCitationsEvent(
          citations: ((payload['citations'] as List<dynamic>?) ?? const [])
              .map((e) => Citation.fromJson((e as Map).cast<String, dynamic>()))
              .toList(),
        );
      case 'suggestions':
        return SseSuggestionsEvent(
          prompts: ((payload['prompts'] as List<dynamic>?) ?? const []).cast<String>(),
        );
      case 'done':
        return SseDoneEvent(
          messageId: payload['messageId'] as String? ?? '',
          grounded: payload['grounded'] as bool?,
          totalTokens: (payload['totalTokens'] as num?)?.toInt(),
          latencyMs: (payload['latencyMs'] as num?)?.toInt(),
        );
      case 'error':
        return SseErrorEvent(
          code: payload['code'] as String?,
          msg: payload['msg'] as String? ?? 'Asisten sedang tidak bisa dihubungi.',
        );
      default:
        return null;
    }
  }
}

final periksaRepositoryProvider = Provider<PeriksaRepository>((ref) {
  return PeriksaRepository(ref.watch(dioProvider));
});