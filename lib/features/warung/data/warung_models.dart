/// Model data F3 Warung Tani dari backend (SourceOfTruth/API_DOCS.md §5).
/// Semua waktu dari API berupa UTC ISO 8601 — ubah dengan [DateTime.parse]
/// lalu `.toLocal()` untuk menampilkan (CATATAN_FE_FLUTTER.md 2.7).
library;

import 'package:tandur/core/network/app_enums.dart';

DateTime _parseDate(dynamic v) =>
    v is String ? DateTime.parse(v).toLocal() : DateTime.now();

int _asInt(dynamic v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

bool _asBool(dynamic v, [bool fallback = false]) => v is bool ? v : fallback;

String _asString(dynamic v, [String fallback = '']) =>
    v is String ? v : fallback;

List<String> _asStringList(dynamic v) =>
    (v as List<dynamic>?)?.whereType<String>().toList() ?? const [];

/// Penulis pertanyaan/balasan (API_DOCS §5).
class CommunityAuthor {
  const CommunityAuthor({
    required this.userId,
    required this.fullName,
    this.reputation = 0,
    this.isVerified = false,
  });

  final String userId;
  final String fullName;
  final int reputation;
  final bool isVerified;

  factory CommunityAuthor.fromJson(Map<String, dynamic> json) {
    return CommunityAuthor(
      userId: _asString(json['userId']),
      fullName: _asString(json['fullName']),
      reputation: _asInt(json['reputation']),
      isVerified: _asBool(json['isVerified']),
    );
  }
}

/// Pindai yang menempel pada pertanyaan (API_DOCS §5.1 Get Question).
class CommunityAttachedScan {
  const CommunityAttachedScan({
    required this.scanId,
    this.imageUrl,
    this.label,
    this.status = ScanStatus.unknown,
    this.daysAfterPlanting = 0,
  });

  final String scanId;
  final String? imageUrl;
  final String? label;
  final ScanStatus status;
  final int daysAfterPlanting;

  factory CommunityAttachedScan.fromJson(Map<String, dynamic> json) {
    return CommunityAttachedScan(
      scanId: _asString(json['scanId']),
      imageUrl: json['imageUrl'] as String?,
      label: json['label'] as String?,
      status: ScanStatusX.fromApi(json['status'] as String?),
      daysAfterPlanting: _asInt(json['daysAfterPlanting']),
    );
  }
}

/// Pertanyaan Warung Tani — dipakai untuk baris daftar maupun detail.
/// Medan tertentu hanya hadir di salah satu bentuk (mis. `body` di detail,
/// `hasBestAnswer` di daftar), sisanya diisi nilai bawaan.
class CommunityQuestion {
  const CommunityQuestion({
    required this.questionId,
    required this.title,
    this.body = '',
    this.commodity = Commodity.unknown,
    this.tags = const [],
    this.district,
    required this.author,
    this.score = 0,
    this.myVote = 0,
    this.replyCount = 0,
    this.hasBestAnswer = false,
    this.isAnswered = false,
    required this.createdAt,
    this.canEdit = false,
    this.editedAt,
    this.photos = const [],
    this.attachedScan,
  });

  final String questionId;
  final String title;
  final String body;
  final Commodity commodity;
  final List<String> tags;
  final String? district;
  final CommunityAuthor author;
  final int score;
  final int myVote;
  final int replyCount;
  final bool hasBestAnswer;
  final bool isAnswered;
  final DateTime createdAt;
  final bool canEdit;
  final DateTime? editedAt;
  final List<String> photos;
  final CommunityAttachedScan? attachedScan;

  factory CommunityQuestion.fromJson(Map<String, dynamic> json) {
    final rawAuthor = (json['author'] as Map?)?.cast<String, dynamic>();
    return CommunityQuestion(
      questionId: _asString(json['questionId']),
      title: _asString(json['title']),
      body: _asString(json['body']),
      commodity: Commodity.fromApi(json['commodity'] as String?),
      tags: _asStringList(json['tags']),
      district: json['district'] as String?,
      author: rawAuthor == null
          ? const CommunityAuthor(userId: '', fullName: '')
          : CommunityAuthor.fromJson(rawAuthor),
      score: _asInt(json['score']),
      myVote: _asInt(json['myVote']),
      replyCount: _asInt(json['replyCount']),
      hasBestAnswer: _asBool(json['hasBestAnswer']),
      isAnswered: _asBool(json['isAnswered']),
      createdAt: _parseDate(json['createdAt']),
      canEdit: _asBool(json['canEdit']),
      editedAt: json['editedAt'] is String
          ? DateTime.parse(json['editedAt'] as String).toLocal()
          : null,
      photos: _asStringList(json['photos']),
      attachedScan: json['attachedScan'] is Map
          ? CommunityAttachedScan.fromJson(
              (json['attachedScan'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }

  CommunityQuestion copyWith({int? score, int? myVote, int? replyCount}) {
    return CommunityQuestion(
      questionId: questionId,
      title: title,
      body: body,
      commodity: commodity,
      tags: tags,
      district: district,
      author: author,
      score: score ?? this.score,
      myVote: myVote ?? this.myVote,
      replyCount: replyCount ?? this.replyCount,
      hasBestAnswer: hasBestAnswer,
      isAnswered: isAnswered,
      createdAt: createdAt,
      canEdit: canEdit,
      editedAt: editedAt,
      photos: photos,
      attachedScan: attachedScan,
    );
  }
}

/// Satu balasan dalam pohon berjenjang. `children` berisi balasan yang sudah
/// dimuat; `hasMoreChildren` menandakan masih ada yang belum dimuat
/// (API_DOCS §5.2 List Replies / Load More Children).
class CommunityReply {
  const CommunityReply({
    required this.replyId,
    this.parentId,
    required this.body,
    required this.author,
    this.score = 0,
    this.myVote = 0,
    this.depth = 0,
    this.childCount = 0,
    this.hasMoreChildren = false,
    this.isBestAnswer = false,
    this.children = const [],
    required this.createdAt,
  });

  final String replyId;
  final String? parentId;
  final String body;
  final CommunityAuthor author;
  final int score;
  final int myVote;
  final int depth;
  final int childCount;
  final bool hasMoreChildren;
  final bool isBestAnswer;
  final List<CommunityReply> children;
  final DateTime createdAt;

  /// [isBestAnswer] diisi `true` khusus objek `bestAnswer` dari List Replies —
  /// balasan di `items` tidak membawa bendera ini.
  factory CommunityReply.fromJson(
    Map<String, dynamic> json, {
    bool isBestAnswer = false,
  }) {
    final rawAuthor = (json['author'] as Map?)?.cast<String, dynamic>();
    return CommunityReply(
      replyId: _asString(json['replyId']),
      parentId: json['parentId'] as String?,
      body: _asString(json['body']),
      author: rawAuthor == null
          ? const CommunityAuthor(userId: '', fullName: '')
          : CommunityAuthor.fromJson(rawAuthor),
      score: _asInt(json['score']),
      myVote: _asInt(json['myVote']),
      depth: _asInt(json['depth']),
      childCount: _asInt(json['childCount']),
      hasMoreChildren: _asBool(json['hasMoreChildren']),
      isBestAnswer: isBestAnswer,
      children:
          (json['children'] as List?)
              ?.map(
                (e) =>
                    CommunityReply.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
      createdAt: _parseDate(json['createdAt']),
    );
  }

  CommunityReply copyWith({
    int? score,
    int? myVote,
    int? childCount,
    bool? hasMoreChildren,
    List<CommunityReply>? children,
  }) {
    return CommunityReply(
      replyId: replyId,
      parentId: parentId,
      body: body,
      author: author,
      score: score ?? this.score,
      myVote: myVote ?? this.myVote,
      depth: depth,
      childCount: childCount ?? this.childCount,
      hasMoreChildren: hasMoreChildren ?? this.hasMoreChildren,
      isBestAnswer: isBestAnswer,
      children: children ?? this.children,
      createdAt: createdAt,
    );
  }
}

/// Hasil pencarian pertanyaan (API_DOCS §5.1 Search Questions) — bentuknya
/// lebih ringkas daripada [CommunityQuestion].
class CommunitySearchResult {
  const CommunitySearchResult({
    required this.questionId,
    required this.title,
    this.snippet,
    this.score = 0,
    this.replyCount = 0,
    this.hasBestAnswer = false,
  });

  final String questionId;
  final String title;
  final String? snippet;
  final int score;
  final int replyCount;
  final bool hasBestAnswer;

  factory CommunitySearchResult.fromJson(Map<String, dynamic> json) {
    return CommunitySearchResult(
      questionId: _asString(json['questionId']),
      title: _asString(json['title']),
      snippet: json['snippet'] as String?,
      score: _asInt(json['score']),
      replyCount: _asInt(json['replyCount']),
      hasBestAnswer: _asBool(json['hasBestAnswer']),
    );
  }
}

/// Hasil Find Similar (API_DOCS §5.1) — dugaan pertanyaan duplikat.
class SimilarQuestion {
  const SimilarQuestion({
    required this.questionId,
    required this.title,
    this.replyCount = 0,
    this.hasBestAnswer = false,
    this.similarity = 0,
  });

  final String questionId;
  final String title;
  final int replyCount;
  final bool hasBestAnswer;
  final double similarity;

  factory SimilarQuestion.fromJson(Map<String, dynamic> json) {
    return SimilarQuestion(
      questionId: _asString(json['questionId']),
      title: _asString(json['title']),
      replyCount: _asInt(json['replyCount']),
      hasBestAnswer: _asBool(json['hasBestAnswer']),
      similarity: json['similarity'] is num
          ? (json['similarity'] as num).toDouble()
          : 0,
    );
  }
}

/// Profil publik pengguna (API_DOCS §5.3 Get User Profile).
class PublicProfile {
  const PublicProfile({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.reputation = 0,
    this.isVerified = false,
    this.verifiedNote,
    this.bestAnswerCount = 0,
    this.questionCount = 0,
    this.replyCount = 0,
    this.topCommodities = const [],
    required this.joinedAt,
  });

  final String userId;
  final String fullName;
  final String? avatarUrl;
  final int reputation;
  final bool isVerified;
  final String? verifiedNote;
  final int bestAnswerCount;
  final int questionCount;
  final int replyCount;
  final List<Commodity> topCommodities;
  final DateTime joinedAt;

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      userId: _asString(json['userId']),
      fullName: _asString(json['fullName']),
      avatarUrl: json['avatarUrl'] as String?,
      reputation: _asInt(json['reputation']),
      isVerified: _asBool(json['isVerified']),
      verifiedNote: json['verifiedNote'] as String?,
      bestAnswerCount: _asInt(json['bestAnswerCount']),
      questionCount: _asInt(json['questionCount']),
      replyCount: _asInt(json['replyCount']),
      topCommodities: _asStringList(json['topCommodities'])
          .map(Commodity.fromApi)
          .toList(),
      joinedAt: _parseDate(json['joinedAt']),
    );
  }
}

/// Label pertanyaan berikut jumlah pemakaiannya (API_DOCS §5.3 Get Tags).
class CommunityTag {
  const CommunityTag({required this.tag, this.count = 0});

  final String tag;
  final int count;

  factory CommunityTag.fromJson(Map<String, dynamic> json) {
    return CommunityTag(
      tag: _asString(json['tag']),
      count: _asInt(json['count']),
    );
  }
}

/// Halaman paginasi kursor (CATATAN_FE_FLUTTER.md 2.6).
/// `nextCursor == null` berarti halaman terakhir.
class CursorPage<T> {
  const CursorPage({required this.items, this.nextCursor});

  final List<T> items;
  final String? nextCursor;

  factory CursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemBuilder,
  ) {
    return CursorPage(
      items:
          (json['items'] as List?)
              ?.map((e) => itemBuilder((e as Map).cast<String, dynamic>()))
              .toList() ??
          const [],
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Balasan satu pertanyaan: jawaban terbaik opsional + pohon balasan
/// (API_DOCS §5.2 List Replies).
class ReplyPage {
  const ReplyPage({this.bestAnswer, this.items = const []});

  final CommunityReply? bestAnswer;
  final List<CommunityReply> items;

  factory ReplyPage.fromJson(Map<String, dynamic> json) {
    final rawBest = json['bestAnswer'] as Map?;
    return ReplyPage(
      bestAnswer: rawBest == null
          ? null
          : CommunityReply.fromJson(
              rawBest.cast<String, dynamic>(),
              isBestAnswer: true,
            ),
      items:
          (json['items'] as List?)
              ?.map(
                (e) =>
                    CommunityReply.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
    );
  }
}

/// Hasil Create Question (API_DOCS §5.1).
class QuestionCreateResult {
  const QuestionCreateResult({required this.questionId, this.xpEarned = 0});

  final String questionId;
  final int xpEarned;

  factory QuestionCreateResult.fromJson(Map<String, dynamic> json) {
    return QuestionCreateResult(
      questionId: _asString(json['questionId']),
      xpEarned: _asInt(json['xpEarned']),
    );
  }
}

/// Hasil Update Question (API_DOCS §5.1).
class QuestionUpdateResult {
  const QuestionUpdateResult({
    required this.questionId,
    required this.editedAt,
  });

  final String questionId;
  final DateTime editedAt;

  factory QuestionUpdateResult.fromJson(Map<String, dynamic> json) {
    return QuestionUpdateResult(
      questionId: _asString(json['questionId']),
      editedAt: _parseDate(json['editedAt']),
    );
  }
}

/// Hasil Create Reply (API_DOCS §5.2).
class ReplyCreateResult {
  const ReplyCreateResult({
    required this.replyId,
    this.depth = 0,
    this.xpEarned = 0,
  });

  final String replyId;
  final int depth;
  final int xpEarned;

  factory ReplyCreateResult.fromJson(Map<String, dynamic> json) {
    return ReplyCreateResult(
      replyId: _asString(json['replyId']),
      depth: _asInt(json['depth']),
      xpEarned: _asInt(json['xpEarned']),
    );
  }
}

/// Hasil suara pertanyaan/balasan (API_DOCS §5.3).
class VoteResult {
  const VoteResult({this.score = 0, this.myVote = 0});

  final int score;
  final int myVote;

  factory VoteResult.fromJson(Map<String, dynamic> json) {
    return VoteResult(
      score: _asInt(json['score']),
      myVote: _asInt(json['myVote']),
    );
  }
}

/// Hasil tandai jawaban terbaik (API_DOCS §5.2 Mark Best Answer).
class BestAnswerResult {
  const BestAnswerResult({
    required this.replyId,
    this.questionResolved = false,
    this.authorXpEarned = 0,
    this.authorReputationEarned = 0,
  });

  final String replyId;
  final bool questionResolved;
  final int authorXpEarned;
  final int authorReputationEarned;

  factory BestAnswerResult.fromJson(Map<String, dynamic> json) {
    return BestAnswerResult(
      replyId: _asString(json['replyId']),
      questionResolved: _asBool(json['questionResolved']),
      authorXpEarned: _asInt(json['authorXpEarned']),
      authorReputationEarned: _asInt(json['authorReputationEarned']),
    );
  }
}

/// Hasil lapor konten (API_DOCS §5.3 Report Content).
class ReportResult {
  const ReportResult({required this.reportId});

  final String reportId;

  factory ReportResult.fromJson(Map<String, dynamic> json) {
    return ReportResult(reportId: _asString(json['reportId']));
  }
}
