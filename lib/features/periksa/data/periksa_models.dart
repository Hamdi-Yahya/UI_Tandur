/// Model data F2 Periksa Tanaman. Nama field mengikuti camelCase di
/// SourceOfTruth/API_DOCS.md §4 apa adanya, dipetakan dari payload murni yang
/// sudah dikupas amplopnya oleh EnvelopeInterceptor (CATATAN_FE_FLUTTER.md 2.1).
///
/// API_DOCS.md v3.2 wajibkan:
///   - inputSize dibaca dari manifes (224 cabai/terong, 320 padi)
///   - healthyConfidenceThreshold dibaca dari manifes (0.85 cabai, 0.90 terong/padi)
///   - urutan labels adalah kontrak — jangan diurutkan ulang
///   - alternatif: tampilkan confidence > 0.10, maks 3
library;

import '../../../core/network/app_enums.dart';

/// Peran pengirim pesan diskusi (API_DOCS.md §4.3).
enum MessageRole { user, assistant, unknown }

extension MessageRoleX on MessageRole {
  static MessageRole fromApi(String? value) {
    switch (value) {
      case 'USER':
        return MessageRole.user;
      case 'ASSISTANT':
        return MessageRole.assistant;
      default:
        return MessageRole.unknown;
    }
  }

  String get apiValue => enumApiValue(name);
}

ScanStatus _scanStatusFromApi(String? value) {
  switch (value) {
    case 'PROCESSING':
      return ScanStatus.processing;
    case 'DONE':
      return ScanStatus.done;
    case 'LOW_CONFIDENCE':
      return ScanStatus.lowConfidence;
    case 'REJECTED':
      return ScanStatus.rejected;
    default:
      return ScanStatus.unknown;
  }
}

UnitType _unitTypeFromApi(String? value) {
  switch (value) {
    case 'POLYBAG':
      return UnitType.polybag;
    case 'METER_PERSEGI':
      return UnitType.meterPersegi;
    case 'HEKTAR':
      return UnitType.hektar;
    default:
      return UnitType.unknown;
  }
}

String _judul(String? raw) {
  if (raw == null) return '-';
  return raw
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}')
      .join(' ');
}

/// Ringkasan satu tanaman — bentuk item `GET /api/plants` (API_DOCS.md §4.1).
class Plant {
  final String plantId;
  final String nickname;
  final String commodity; // CABAI, TERONG, PADI
  final int daysAfterPlanting;
  final String phase;
  final int unitCount;
  final UnitType unitType;
  final DateTime? lastScanAt;
  final String? lastDiagnosis;
  final int scanCount;
  final PlantStatus status;

  const Plant({
    required this.plantId,
    required this.nickname,
    required this.commodity,
    required this.daysAfterPlanting,
    required this.phase,
    required this.unitCount,
    required this.unitType,
    this.lastScanAt,
    this.lastDiagnosis,
    this.scanCount = 0,
    this.status = PlantStatus.active,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plantId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      commodity: json['commodity'] as String? ?? '',
      daysAfterPlanting: json['daysAfterPlanting'] as int? ?? 0,
      phase: json['phase'] as String? ?? '-',
      unitCount: json['unitCount'] as int? ?? 0,
      unitType: _unitTypeFromApi(json['unitType'] as String?),
      lastScanAt: DateTime.tryParse(json['lastScanAt'] as String? ?? ''),
      lastDiagnosis: json['lastDiagnosis'] as String?,
      scanCount: json['scanCount'] as int? ?? 0,
      status: PlantStatusX.fromApi(json['status'] as String?),
    );
  }
}

/// Hasil `POST /api/plants` — bentuk singkat tanpa unitCount/unitType.
class PlantCreated {
  final String plantId;
  final String nickname;
  final String commodity;
  final int daysAfterPlanting;
  final String phase;
  final PlantStatus status;

  const PlantCreated({
    required this.plantId,
    required this.nickname,
    required this.commodity,
    required this.daysAfterPlanting,
    required this.phase,
    required this.status,
  });

  factory PlantCreated.fromJson(Map<String, dynamic> json) {
    return PlantCreated(
      plantId: json['plantId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      commodity: json['commodity'] as String? ?? '',
      daysAfterPlanting: json['daysAfterPlanting'] as int? ?? 0,
      phase: json['phase'] as String? ?? '-',
      status: PlantStatusX.fromApi(json['status'] as String?),
    );
  }
}

/// Pola berulang pada detail tanaman (missal diagnosis sama dua kali
/// dalam 14 hari) — `GET /api/plants/:id`.
class PlantPattern {
  final String type;
  final String label;
  final int occurrences;
  final int withinDays;
  final String? note;

  const PlantPattern({
    required this.type,
    required this.label,
    required this.occurrences,
    required this.withinDays,
    this.note,
  });

  factory PlantPattern.fromJson(Map<String, dynamic> json) {
    return PlantPattern(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      occurrences: json['occurrences'] as int? ?? 0,
      withinDays: json['withinDays'] as int? ?? 0,
      note: json['note'] as String?,
    );
  }
}

/// Detail lengkap tanaman — `GET /api/plants/:id`.
class PlantDetail {
  final String plantId;
  final String nickname;
  final String commodity;
  final String? variety;
  final DateTime plantedAt;
  final int daysAfterPlanting;
  final String phase;
  final int unitCount;
  final UnitType unitType;
  final PlantStatus status;
  final List<PlantPattern> patterns;

  const PlantDetail({
    required this.plantId,
    required this.nickname,
    required this.commodity,
    required this.plantedAt,
    required this.daysAfterPlanting,
    required this.phase,
    required this.unitCount,
    required this.unitType,
    required this.status,
    this.variety,
    this.patterns = const [],
  });

  factory PlantDetail.fromJson(Map<String, dynamic> json) {
    return PlantDetail(
      plantId: json['plantId'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      commodity: json['commodity'] as String? ?? '',
      variety: json['variety'] as String?,
      plantedAt: DateTime.tryParse(json['plantedAt'] as String? ?? '') ?? DateTime.now(),
      daysAfterPlanting: json['daysAfterPlanting'] as int? ?? 0,
      phase: json['phase'] as String? ?? '-',
      unitCount: json['unitCount'] as int? ?? 0,
      unitType: _unitTypeFromApi(json['unitType'] as String?),
      status: PlantStatusX.fromApi(json['status'] as String?),
      patterns: ((json['patterns'] as List<dynamic>?) ?? const [])
          .map((e) => PlantPattern.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

/// Satu dugaan model. Pada `POST /api/scans` berisi displayName/alias/summary;
/// pada `GET /api/scans/:id` hanya label + confidence, jadi displayName
/// diturunkan dari label kalau tidak dikirim.
class ScanPrediction {
  final String label;
  final String displayName;
  final String? alias;
  final double confidence;
  final String? summary;

  const ScanPrediction({
    required this.label,
    required this.displayName,
    this.alias,
    required this.confidence,
    this.summary,
  });

  factory ScanPrediction.fromJson(Map<String, dynamic> json) {
    final label = json['label'] as String? ?? '';
    return ScanPrediction(
      label: label,
      displayName: json['displayName'] as String? ?? _judul(label),
      alias: json['alias'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      summary: json['summary'] as String?,
    );
  }
}

/// Saran memotret ulang saat hasil berstatus LOW_CONFIDENCE.
class LowConfidenceGuidance {
  final String title;
  final List<String> tips;

  const LowConfidenceGuidance({required this.title, required this.tips});

  factory LowConfidenceGuidance.fromJson(Map<String, dynamic> json) {
    return LowConfidenceGuidance(
      title: json['title'] as String? ?? 'Fotonya belum cukup jelas',
      tips: ((json['tips'] as List<dynamic>?) ?? const []).cast<String>(),
    );
  }
}

/// Hasil pindai — menangani dua bentuk respons `POST /api/scans` (DONE dan
/// LOW_CONFIDENCE) maupun `GET /api/scans/:id` sekaligus.
class ScanResult {
  final String scanId;
  final String? plantId;
  final String? plantNickname;
  final String? imageUrl;
  final int? daysAfterPlanting;
  final ScanStatus status;
  final ScanPrediction? primary;
  final List<ScanPrediction> alternatives;
  final bool canDiscuss;
  final List<String> suggestedPrompts;
  final String disclaimer;
  final LowConfidenceGuidance? guidance;
  final bool hasDiscussion;
  final String? discussionId;
  final DateTime? createdAt;

  const ScanResult({
    required this.scanId,
    required this.status,
    this.plantId,
    this.plantNickname,
    this.imageUrl,
    this.daysAfterPlanting,
    this.primary,
    this.alternatives = const [],
    this.canDiscuss = true,
    this.suggestedPrompts = const [],
    this.disclaimer = 'Ini dugaan awal dari foto, bukan pemeriksaan langsung.',
    this.guidance,
    this.hasDiscussion = false,
    this.discussionId,
    this.createdAt,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      scanId: json['scanId'] as String? ?? '',
      plantId: json['plantId'] as String?,
      plantNickname: json['plantNickname'] as String?,
      imageUrl: json['imageUrl'] as String?,
      daysAfterPlanting: json['daysAfterPlanting'] as int?,
      status: _scanStatusFromApi(json['status'] as String?),
      primary: json['primary'] == null
          ? null
          : ScanPrediction.fromJson((json['primary'] as Map).cast<String, dynamic>()),
      alternatives: ((json['alternatives'] as List<dynamic>?) ?? const [])
          .map((e) => ScanPrediction.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      canDiscuss: json['canDiscuss'] as bool? ?? true,
      suggestedPrompts: ((json['suggestedPrompts'] as List<dynamic>?) ?? const []).cast<String>(),
      disclaimer: json['disclaimer'] as String? ?? 'Ini dugaan awal dari foto, bukan pemeriksaan langsung.',
      guidance: json['guidance'] == null
          ? null
          : LowConfidenceGuidance.fromJson((json['guidance'] as Map).cast<String, dynamic>()),
      hasDiscussion: json['hasDiscussion'] as bool? ?? false,
      discussionId: json['discussionId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

/// Satu butir linimasa pindai — `GET /api/plants/:id/scans`.
class ScanTimelineItem {
  final String scanId;
  final String? imageUrl;
  final int daysAfterPlanting;
  final String? label;
  final String? displayName;
  final double confidence;
  final String? flag; // "REPEATED" atau null
  final DateTime createdAt;

  const ScanTimelineItem({
    required this.scanId,
    required this.daysAfterPlanting,
    required this.confidence,
    required this.createdAt,
    this.imageUrl,
    this.label,
    this.displayName,
    this.flag,
  });

  factory ScanTimelineItem.fromJson(Map<String, dynamic> json) {
    final label = json['label'] as String?;
    return ScanTimelineItem(
      scanId: json['scanId'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      daysAfterPlanting: json['daysAfterPlanting'] as int? ?? 0,
      label: label,
      displayName: json['displayName'] as String? ?? _judul(label),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      flag: json['flag'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Satu halaman linimasa. `nextCursor: null` berarti halaman terakhir
/// (CATATAN_FE_FLUTTER.md 2.6) — bukan `items.length < limit`.
class ScanTimelinePage {
  final String plantId;
  final List<ScanTimelineItem> items;
  final String? nextCursor;

  const ScanTimelinePage({required this.plantId, required this.items, this.nextCursor});

  factory ScanTimelinePage.fromJson(Map<String, dynamic> json) {
    return ScanTimelinePage(
      plantId: json['plantId'] as String? ?? '',
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((e) => ScanTimelineItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Sitasi sumber jawaban asisten (API_DOCS.md §4.3). `grounded: false`
/// berdampingan dengan citations kosong berarti "tidak tahu" yang jujur,
/// bukan galat.
class Citation {
  final String title;
  final String publisher;
  final int year;
  final int? page;
  final String? url;

  const Citation({required this.title, required this.publisher, required this.year, this.page, this.url});

  factory Citation.fromJson(Map<String, dynamic> json) {
    return Citation(
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt(),
      url: json['url'] as String?,
    );
  }
}

/// Satu pesan diskusi — `GET /api/discussions/:id`.
class DiscussionMessage {
  final String messageId;
  final MessageRole role;
  final String content;
  final List<Citation> citations;
  final bool? grounded;
  final bool? helpful;

  const DiscussionMessage({
    required this.messageId,
    required this.role,
    required this.content,
    this.citations = const [],
    this.grounded,
    this.helpful,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      messageId: json['messageId'] as String? ?? '',
      role: MessageRoleX.fromApi(json['role'] as String?),
      content: json['content'] as String? ?? '',
      citations: ((json['citations'] as List<dynamic>?) ?? const [])
          .map((e) => Citation.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      grounded: json['grounded'] as bool?,
      helpful: json['helpful'] as bool?,
    );
  }
}

/// Konteks pindai yang menemani diskusi — respons `POST /api/discussions`.
class DiscussionContext {
  final String commodity;
  final int? daysAfterPlanting;
  final String? diagnosis;
  final double? confidence;

  const DiscussionContext({
    required this.commodity,
    this.daysAfterPlanting,
    this.diagnosis,
    this.confidence,
  });

  factory DiscussionContext.fromJson(Map<String, dynamic> json) {
    return DiscussionContext(
      commodity: json['commodity'] as String? ?? '',
      daysAfterPlanting: json['daysAfterPlanting'] as int?,
      diagnosis: json['diagnosis'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}

/// Diskusi baru — `POST /api/discussions`.
class DiscussionStarted {
  final String discussionId;
  final String scanId;
  final DiscussionContext context;
  final List<String> suggestedPrompts;

  const DiscussionStarted({
    required this.discussionId,
    required this.scanId,
    required this.context,
    required this.suggestedPrompts,
  });

  factory DiscussionStarted.fromJson(Map<String, dynamic> json) {
    return DiscussionStarted(
      discussionId: json['discussionId'] as String? ?? '',
      scanId: json['scanId'] as String? ?? '',
      context: json['context'] == null
          ? const DiscussionContext(commodity: '')
          : DiscussionContext.fromJson((json['context'] as Map).cast<String, dynamic>()),
      suggestedPrompts: ((json['suggestedPrompts'] as List<dynamic>?) ?? const []).cast<String>(),
    );
  }
}

/// Isi percakapan — `GET /api/discussions/:id`.
class DiscussionDetail {
  final String discussionId;
  final String scanId;
  final List<DiscussionMessage> messages;

  const DiscussionDetail({required this.discussionId, required this.scanId, required this.messages});

  factory DiscussionDetail.fromJson(Map<String, dynamic> json) {
    return DiscussionDetail(
      discussionId: json['discussionId'] as String? ?? '',
      scanId: json['scanId'] as String? ?? '',
      messages: ((json['messages'] as List<dynamic>?) ?? const [])
          .map((e) => DiscussionMessage.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

/// Sisa kuota diskusi harian — `GET /api/discussions/quota`.
class DiscussionQuota {
  final int dailyLimit;
  final int usedToday;
  final int remaining;
  final DateTime resetAt;

  const DiscussionQuota({
    required this.dailyLimit,
    required this.usedToday,
    required this.remaining,
    required this.resetAt,
  });

  factory DiscussionQuota.fromJson(Map<String, dynamic> json) {
    return DiscussionQuota(
      dailyLimit: json['dailyLimit'] as int? ?? 0,
      usedToday: json['usedToday'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 0,
      resetAt: DateTime.tryParse(json['resetAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Manifes model TFLite per komoditas — `GET /api/vision/model?commodity=X`.
/// `inputSize` dan `healthyConfidenceThreshold` WAJIB dibaca dari sini, bukan
/// ditanam di kode (API_DOCS.md v3.2 bagian B). Urutan `labels` adalah kontrak.
class ModelManifest {
  final Commodity commodity;
  final String version;
  final String fileUrl;
  final String sha256;
  final int bytes;
  final int inputSize;
  final String inputDtype;
  final String quantization;
  final List<String> labels;
  final double confidenceThreshold;
  final double healthyConfidenceThreshold;
  final DateTime releasedAt;

  const ModelManifest({
    required this.commodity,
    required this.version,
    required this.fileUrl,
    required this.sha256,
    required this.bytes,
    required this.inputSize,
    required this.inputDtype,
    required this.quantization,
    required this.labels,
    required this.confidenceThreshold,
    required this.healthyConfidenceThreshold,
    required this.releasedAt,
  });

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    return ModelManifest(
      commodity: Commodity.fromApi(json['commodity'] as String?),
      version: json['version'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      sha256: json['sha256'] as String? ?? '',
      bytes: json['bytes'] as int? ?? 0,
      inputSize: json['inputSize'] as int? ?? 224,
      inputDtype: json['inputDtype'] as String? ?? 'float32',
      quantization: json['quantization'] as String? ?? '',
      labels: ((json['labels'] as List<dynamic>?) ?? const []).cast<String>(),
      confidenceThreshold: (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.7,
      healthyConfidenceThreshold: (json['healthyConfidenceThreshold'] as num?)?.toDouble() ?? 0.85,
      releasedAt: DateTime.tryParse(json['releasedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// URL unggah bertanda tangan Supabase Storage — `POST /api/uploads/signed-url`.
class SignedUploadUrl {
  final String uploadUrl;
  final String fileUrl;
  final int expiresIn;

  const SignedUploadUrl({required this.uploadUrl, required this.fileUrl, required this.expiresIn});

  factory SignedUploadUrl.fromJson(Map<String, dynamic> json) {
    return SignedUploadUrl(
      uploadUrl: json['uploadUrl'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 3600,
    );
  }
}

/// Hasil `POST /api/plants/:id/end`.
class PlantEndResult {
  final String plantId;
  final PlantStatus status;
  final int totalDays;
  final int scanCount;
  final int xpEarned;

  const PlantEndResult({
    required this.plantId,
    required this.status,
    required this.totalDays,
    required this.scanCount,
    required this.xpEarned,
  });

  factory PlantEndResult.fromJson(Map<String, dynamic> json) {
    return PlantEndResult(
      plantId: json['plantId'] as String? ?? '',
      status: PlantStatusX.fromApi(json['status'] as String?),
      totalDays: json['totalDays'] as int? ?? 0,
      scanCount: json['scanCount'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }
}

/// Satu peristiwa SSE dari `POST /api/discussions/:id/messages`
/// (CATATAN_FE_FLUTTER.md bagian 6). `error` datang dengan HTTP 200 —
/// jangan andalkan status kode, periksa jenis peristiwanya.
sealed class DiscussionSseEvent {
  const DiscussionSseEvent();
}

class SseStartEvent extends DiscussionSseEvent {
  final String messageId;
  final String? model;

  const SseStartEvent({required this.messageId, this.model});
}

class SseChunkEvent extends DiscussionSseEvent {
  final String text;

  const SseChunkEvent({required this.text});
}

class SseCitationsEvent extends DiscussionSseEvent {
  final List<Citation> citations;

  const SseCitationsEvent({required this.citations});
}

class SseSuggestionsEvent extends DiscussionSseEvent {
  final List<String> prompts;

  const SseSuggestionsEvent({required this.prompts});
}

class SseDoneEvent extends DiscussionSseEvent {
  final String messageId;
  final bool? grounded;
  final int? totalTokens;
  final int? latencyMs;

  const SseDoneEvent({required this.messageId, this.grounded, this.totalTokens, this.latencyMs});
}

class SseErrorEvent extends DiscussionSseEvent {
  final String? code;
  final String msg;

  const SseErrorEvent({this.code, required this.msg});
}