import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_enums.dart';
import 'warung_models.dart';

/// Repository F3 Warung Tani — seluruh endpoint API_DOCS.md §5.
///
/// Konvensi yang sudah ditangani lapisan jaringan (CATATAN_FE_FLUTTER.md 2-3):
/// - `EnvelopeInterceptor` mengupas `{msg, data}` — `res.data` di sini selalu
///   payload murni.
/// - `Idempotency-Key` otomatis dipasang pada POST/PATCH/PUT/DELETE. Untuk
///   POST yang sifatnya membaca ([findSimilar]) kunci baru setiap panggilan
///   memang yang benar.
/// - Galat dilempar sebagai [ApiException] lewat [guardApi].
class WarungRepository {
  WarungRepository(this._dio);

  final Dio _dio;

  Map<String, dynamic> _params({
    Commodity? commodity,
    QuestionSort? sort,
    String? district,
    String? tag,
    int? limit,
    String? cursor,
  }) {
    return {
      if (commodity != null && commodity != Commodity.unknown)
        'commodity': commodity.apiValue,
      if (sort != null && sort != QuestionSort.unknown) 'sort': sort.apiValue,
      if (district != null && district.isNotEmpty) 'district': district,
      if (tag != null && tag.isNotEmpty) 'tag': tag,
      'limit': ?limit,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };
  }

  /// Daftar pertanyaan dengan paginasi kursor (API_DOCS §5.1 List Questions).
  /// `nextCursor: null` pada hasil berarti halaman terakhir.
  Future<CursorPage<CommunityQuestion>> listQuestions({
    Commodity? commodity,
    QuestionSort? sort,
    String? district,
    String? tag,
    int? limit,
    String? cursor,
  }) async {
    final res = await guardApi(
      () => _dio.get(
        '/community/questions',
        queryParameters: _params(
          commodity: commodity,
          sort: sort,
          district: district,
          tag: tag,
          limit: limit,
          cursor: cursor,
        ),
      ),
    );
    return CursorPage.fromJson(
      (res.data as Map).cast<String, dynamic>(),
      CommunityQuestion.fromJson,
    );
  }

  /// Pencarian pertanyaan (API_DOCS §5.1 Search Questions).
  Future<CursorPage<CommunitySearchResult>> searchQuestions({
    required String q,
    Commodity? commodity,
    int? limit,
  }) async {
    final res = await guardApi(
      () => _dio.get(
        '/community/search',
        queryParameters: {
          'q': q,
          if (commodity != null && commodity != Commodity.unknown)
            'commodity': commodity.apiValue,
          'limit': ?limit,
        },
      ),
    );
    return CursorPage.fromJson(
      (res.data as Map).cast<String, dynamic>(),
      CommunitySearchResult.fromJson,
    );
  }

  /// Cari pertanyaan serupa sebelum membuat yang baru (API_DOCS §5.1 Find
  /// Similar). POST yang sifatnya membaca — kunci idempotensi baru otomatis
  /// setiap panggilan supaya hasilnya tidak basi 24 jam.
  Future<List<SimilarQuestion>> findSimilar({
    required String title,
    Commodity? commodity,
  }) async {
    final res = await guardApi(
      () => _dio.post(
        '/community/questions/similar',
        data: {
          'title': title,
          if (commodity != null && commodity != Commodity.unknown)
            'commodity': commodity.apiValue,
        },
      ),
    );
    return (res.data as List?)
            ?.map(
              (e) =>
                  SimilarQuestion.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList() ??
        const [];
  }

  /// Buat pertanyaan baru (API_DOCS §5.1 Create Question).
  Future<QuestionCreateResult> createQuestion({
    required String title,
    required String body,
    required String commodity,
    List<String>? tags,
    List<String>? photos,
    String? fromScanId,
  }) async {
    final res = await guardApi(
      () => _dio.post(
        '/community/questions',
        data: {
          'title': title,
          'body': body,
          'commodity': commodity,
          if (tags != null && tags.isNotEmpty) 'tags': tags,
          if (photos != null && photos.isNotEmpty) 'photos': photos,
          if (fromScanId != null && fromScanId.isNotEmpty)
            'fromScanId': fromScanId,
        },
      ),
    );
    return QuestionCreateResult.fromJson(
      (res.data as Map).cast<String, dynamic>(),
    );
  }

  /// Detail pertanyaan (API_DOCS §5.1 Get Question).
  Future<CommunityQuestion> getQuestion(String id) async {
    final res = await guardApi(() => _dio.get('/community/questions/$id'));
    return CommunityQuestion.fromJson(
      (res.data as Map).cast<String, dynamic>(),
    );
  }

  /// Ubah pertanyaan milik sendiri (API_DOCS §5.1 Update Question).
  Future<QuestionUpdateResult> updateQuestion(
    String id, {
    String? title,
    String? body,
    List<String>? tags,
  }) async {
    final res = await guardApi(
      () => _dio.patch(
        '/community/questions/$id',
        data: {'title': ?title, 'body': ?body, 'tags': ?tags},
      ),
    );
    return QuestionUpdateResult.fromJson(
      (res.data as Map).cast<String, dynamic>(),
    );
  }

  /// Hapus pertanyaan (API_DOCS §5.1 Delete Question).
  Future<void> deleteQuestion(String id) async {
    await guardApi(() => _dio.delete('/community/questions/$id'));
  }

  /// Suara pertanyaan — nilai 1, -1, atau 0 (batal) (API_DOCS §5.3).
  Future<VoteResult> voteQuestion(String id, int value) async {
    final res = await guardApi(
      () => _dio.post('/community/questions/$id/vote', data: {'value': value}),
    );
    return VoteResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Balasan satu pertanyaan dengan urutan `TOP`/`NEWEST` (API_DOCS §5.2).
  /// `bestAnswer` bisa null; `items` sudah berisi pohon `children` bersarang.
  Future<ReplyPage> listReplies(String questionId, {QuestionSort? sort}) async {
    final res = await guardApi(
      () => _dio.get(
        '/community/questions/$questionId/replies',
        queryParameters: {
          if (sort != null && sort != QuestionSort.unknown)
            'sort': sort.apiValue,
        },
      ),
    );
    return ReplyPage.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Balasan lanjutan dari satu balasan (API_DOCS §5.2 Load More Children).
  Future<CursorPage<CommunityReply>> loadMoreChildren(
    String replyId, {
    int? limit,
    String? cursor,
  }) async {
    final res = await guardApi(
      () => _dio.get(
        '/community/replies/$replyId/children',
        queryParameters: {
          'limit': ?limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      ),
    );
    return CursorPage.fromJson(
      (res.data as Map).cast<String, dynamic>(),
      CommunityReply.fromJson,
    );
  }

  /// Kirim balasan — `parentId` diisi untuk membalas balasan (API_DOCS §5.2).
  Future<ReplyCreateResult> createReply(
    String questionId, {
    required String body,
    String? parentId,
  }) async {
    final res = await guardApi(
      () => _dio.post(
        '/community/questions/$questionId/replies',
        data: {
          'body': body,
          if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
        },
      ),
    );
    return ReplyCreateResult.fromJson(
      (res.data as Map).cast<String, dynamic>(),
    );
  }

  /// Suara balasan — nilai 1, -1, atau 0 (batal) (API_DOCS §5.3).
  Future<VoteResult> voteReply(String replyId, int value) async {
    final res = await guardApi(
      () =>
          _dio.post('/community/replies/$replyId/vote', data: {'value': value}),
    );
    return VoteResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Tandai jawaban terbaik (API_DOCS §5.2). Hanya penanya yang berhak.
  Future<BestAnswerResult> markBest(String replyId) async {
    final res = await guardApi(
      () => _dio.post('/community/replies/$replyId/best'),
    );
    return BestAnswerResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Lepas tanda jawaban terbaik (API_DOCS §5.2) — pasangan
  /// POST/DELETE pada path yang sama, jangan tertukar.
  Future<void> unmarkBest(String replyId) async {
    await guardApi(() => _dio.delete('/community/replies/$replyId/best'));
  }

  /// Hapus balasan (API_DOCS §5.2 Delete Reply).
  Future<void> deleteReply(String replyId) async {
    await guardApi(() => _dio.delete('/community/replies/$replyId'));
  }

  /// Lapor konten (API_DOCS §5.3 Report Content).
  Future<ReportResult> report({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReason reason,
    String? note,
  }) async {
    final res = await guardApi(
      () => _dio.post(
        '/community/reports',
        data: {
          'targetType': targetType.apiValue,
          'targetId': targetId,
          'reason': reason.apiValue,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      ),
    );
    return ReportResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Profil publik pengguna (API_DOCS §5.3 Get User Profile).
  Future<PublicProfile> getPublicProfile(String userId) async {
    final res = await guardApi(() => _dio.get('/community/users/$userId'));
    return PublicProfile.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Label beserta jumlah pemakaiannya (API_DOCS §5.3 Get Tags).
  Future<List<CommunityTag>> getTags({Commodity? commodity}) async {
    final res = await guardApi(
      () => _dio.get(
        '/community/tags',
        queryParameters: {
          if (commodity != null && commodity != Commodity.unknown)
            'commodity': commodity.apiValue,
        },
      ),
    );
    return (res.data as List?)
            ?.map(
              (e) => CommunityTag.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList() ??
        const [];
  }
}

final warungRepositoryProvider = Provider<WarungRepository>((ref) {
  return WarungRepository(ref.watch(dioProvider));
});
