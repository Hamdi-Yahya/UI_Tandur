/// Model data F2 Periksa Tanaman. Nama field mengikuti camelCase di
/// SourceOfTruth/API_DOCS.md §4 apa adanya, supaya nanti tinggal diganti
/// sumbernya (mock -> repository Dio) tanpa reshape model.
///
/// API_DOCS.md v3.2 wajibkan:
///   - inputSize dibaca dari manifes (224 cabai/terong, 320 padi)
///   - healthyConfidenceThreshold dibaca dari manifes (0.85 cabai, 0.90 terong/padi)
///   - urutan labels adalah kontrak — jangan diurutkan ulang
///   - alternatif: tampilkan confidence > 0.10, maks 3
library;

enum PlantStatus { active, harvested, ended }

enum ScanStatus { processing, done, lowConfidence, rejected }

enum UnitType { polybag, meterPersegi, hektar }

String unitTypeLabel(UnitType t) {
  switch (t) {
    case UnitType.polybag:
      return 'polybag';
    case UnitType.meterPersegi:
      return 'm²';
    case UnitType.hektar:
      return 'ha';
  }
}

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
}

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
}

class LowConfidenceGuidance {
  final String title;
  final List<String> tips;

  const LowConfidenceGuidance({required this.title, required this.tips});
}

class ScanResult {
  final String scanId;
  final String plantId;
  final String plantNickname;
  final String commodity;
  final String imageUrl;
  final int daysAfterPlanting;
  final ScanStatus status;
  final ScanPrediction? primary;
  final List<ScanPrediction> alternatives;
  final bool canDiscuss;
  final List<String> suggestedPrompts;
  final String disclaimer;
  final LowConfidenceGuidance? guidance;

  const ScanResult({
    required this.scanId,
    required this.plantId,
    required this.plantNickname,
    required this.commodity,
    required this.imageUrl,
    required this.daysAfterPlanting,
    required this.status,
    this.primary,
    this.alternatives = const [],
    this.canDiscuss = true,
    this.suggestedPrompts = const [],
    this.disclaimer = 'Ini dugaan awal dari foto, bukan pemeriksaan langsung.',
    this.guidance,
  });
}

class ScanTimelineItem {
  final String scanId;
  final String imageUrl;
  final int daysAfterPlanting;
  final String label;
  final String displayName;
  final double confidence;
  final String? flag; // "REPEATED" atau null
  final DateTime createdAt;

  const ScanTimelineItem({
    required this.scanId,
    required this.imageUrl,
    required this.daysAfterPlanting,
    required this.label,
    required this.displayName,
    required this.confidence,
    this.flag,
    required this.createdAt,
  });
}

class Citation {
  final String title;
  final String publisher;
  final int year;
  final int? page;
  final String? url;

  const Citation({
    required this.title,
    required this.publisher,
    required this.year,
    this.page,
    this.url,
  });
}

enum MessageRole { user, assistant }

class DiscussionMessage {
  final String messageId;
  final MessageRole role;
  final String content;
  final List<Citation> citations;
  final bool? helpful;

  const DiscussionMessage({
    required this.messageId,
    required this.role,
    required this.content,
    this.citations = const [],
    this.helpful,
  });
}

class Discussion {
  final String discussionId;
  final String scanId;
  final String commodity;
  final int daysAfterPlanting;
  final String diagnosis;
  final double confidence;
  final List<DiscussionMessage> messages;
  final List<String> suggestedPrompts;

  const Discussion({
    required this.discussionId,
    required this.scanId,
    required this.commodity,
    required this.daysAfterPlanting,
    required this.diagnosis,
    required this.confidence,
    required this.messages,
    this.suggestedPrompts = const [],
  });
}

class PeriksaMockData {
  static final List<Plant> plants = [
    Plant(
      plantId: 'p1',
      nickname: 'Cabai Depan Rumah',
      commodity: 'CABAI',
      daysAfterPlanting: 42,
      phase: 'BERBUNGA',
      unitCount: 30,
      unitType: UnitType.polybag,
      lastScanAt: DateTime(2026, 8, 11, 6, 12),
      lastDiagnosis: 'VIRUS_KUNING_KERITING',
      scanCount: 4,
    ),
    Plant(
      plantId: 'p2',
      nickname: 'Terong Belakang',
      commodity: 'TERONG',
      daysAfterPlanting: 18,
      phase: 'VEGETATIF',
      unitCount: 20,
      unitType: UnitType.polybag,
      lastScanAt: DateTime(2026, 8, 5, 9, 0),
      lastDiagnosis: 'SEHAT',
      scanCount: 1,
    ),
    Plant(
      plantId: 'p3',
      nickname: 'Padi Sawah Belakang',
      commodity: 'PADI',
      daysAfterPlanting: 55,
      phase: 'ANAKAN',
      unitCount: 1000,
      unitType: UnitType.meterPersegi,
      lastScanAt: DateTime(2026, 8, 10, 7, 0),
      lastDiagnosis: 'BLAS_DAUN',
      scanCount: 2,
    ),
  ];

  /// Scan CABAI — status DONE, virus kuning keriting
  static const ScanResult scanDone = ScanResult(
    scanId: 'scan1',
    plantId: 'p1',
    plantNickname: 'Cabai Depan Rumah',
    commodity: 'CABAI',
    imageUrl: 'placeholder',
    daysAfterPlanting: 42,
    status: ScanStatus.done,
    primary: ScanPrediction(
      label: 'VIRUS_KUNING_KERITING',
      displayName: 'Virus Kuning Keriting',
      alias: 'bule',
      confidence: 0.72,
      summary: 'Daun menguning belang mengikuti tulang daun dan menggulung ke atas.',
    ),
    // Sudah difilter: confidence > 0.10. SEHAT 0.07 → tidak masuk.
    alternatives: [
      ScanPrediction(label: 'BERCAK_DAUN', displayName: 'Bercak Daun', confidence: 0.18),
    ],
    suggestedPrompts: ['Ini bahaya nggak?', 'Bisa menular ke tanaman lain?', 'Berapa lama sampai pulih?'],
  );

  /// Scan CABAI — status LOW_CONFIDENCE, keyakinan di bawah ambang
  static const ScanResult scanLowConfidence = ScanResult(
    scanId: 'scan2',
    plantId: 'p1',
    plantNickname: 'Cabai Depan Rumah',
    commodity: 'CABAI',
    imageUrl: 'placeholder',
    daysAfterPlanting: 40,
    status: ScanStatus.lowConfidence,
    guidance: LowConfidenceGuidance(
      title: 'Fotonya belum cukup jelas',
      tips: ['Satu helai daun saja', 'Latar polos, misalnya kertas', 'Cahaya dari samping, jangan melawan matahari'],
    ),
  );

  /// Scan TERONG — status DONE, hama serangga.
  /// Label urutan kontrak: SEHAT, HAMA_SERANGGA, BERCAK_DAUN, VIRUS_MOSAIK,
  /// DAUN_KERDIL, EMBUN_TEPUNG_PUTIH, LAYU — jangan diurutkan ulang.
  static const ScanResult scanTerongDone = ScanResult(
    scanId: 'scan3',
    plantId: 'p2',
    plantNickname: 'Terong Belakang',
    commodity: 'TERONG',
    imageUrl: 'placeholder',
    daysAfterPlanting: 18,
    status: ScanStatus.done,
    primary: ScanPrediction(
      label: 'HAMA_SERANGGA',
      displayName: 'Hama Serangga',
      alias: null,
      confidence: 0.78,
      summary: 'Daun berlubang tidak beraturan, kadang terlihat bekas gigitan di tepi.',
    ),
    // confidence > 0.10: BERCAK_DAUN 0.15 lolos, VIRUS_MOSAIK 0.04 → tidak masuk
    alternatives: [
      ScanPrediction(label: 'BERCAK_DAUN', displayName: 'Bercak Daun', confidence: 0.15),
    ],
    suggestedPrompts: ['Serangannya parah nggak?', 'Pestisida apa yang cocok?', 'Bisa sembuh sendiri?'],
  );

  /// Scan PADI — status DONE, blas daun.
  /// inputSize 320 (bukan 224!) — dibaca dari manifest, bukan hardcode.
  /// Label urutan kontrak: BERCAK_COKELAT, BLAS_DAUN, SEHAT.
  static const ScanResult scanPadiDone = ScanResult(
    scanId: 'scan4',
    plantId: 'p3',
    plantNickname: 'Padi Sawah Belakang',
    commodity: 'PADI',
    imageUrl: 'placeholder',
    daysAfterPlanting: 55,
    status: ScanStatus.done,
    primary: ScanPrediction(
      label: 'BLAS_DAUN',
      displayName: 'Blas Daun',
      alias: 'blasting',
      confidence: 0.81,
      summary: 'Bercak berbentuk belah ketupat dengan tepi cokelat dan pusat abu-abu pada helai daun.',
    ),
    // confidence > 0.10: BERCAK_COKELAT 0.12 lolos, SEHAT 0.06 → tidak masuk
    alternatives: [
      ScanPrediction(label: 'BERCAK_COKELAT', displayName: 'Bercak Cokelat', confidence: 0.12),
    ],
    suggestedPrompts: ['Seberapa cepat menyebar?', 'Pengaruhnya ke hasil panen?', 'Fungisida yang disarankan?'],
  );

  static List<ScanTimelineItem> timelineFor(String plantId) => [
        ScanTimelineItem(
          scanId: 'scan1',
          imageUrl: 'placeholder',
          daysAfterPlanting: 42,
          label: 'VIRUS_KUNING_KERITING',
          displayName: 'Virus Kuning Keriting',
          confidence: 0.72,
          flag: 'REPEATED',
          createdAt: DateTime(2026, 8, 11),
        ),
        ScanTimelineItem(
          scanId: 'scan0',
          imageUrl: 'placeholder',
          daysAfterPlanting: 35,
          label: 'SEHAT',
          displayName: 'Sehat',
          confidence: 0.88,
          createdAt: DateTime(2026, 8, 4),
        ),
        ScanTimelineItem(
          scanId: 'scan-1',
          imageUrl: 'placeholder',
          daysAfterPlanting: 28,
          label: 'VIRUS_KUNING_KERITING',
          displayName: 'Virus Kuning Keriting',
          confidence: 0.65,
          createdAt: DateTime(2026, 7, 28),
        ),
        ScanTimelineItem(
          scanId: 'scan-2',
          imageUrl: 'placeholder',
          daysAfterPlanting: 14,
          label: 'SEHAT',
          displayName: 'Sehat',
          confidence: 0.91,
          createdAt: DateTime(2026, 7, 14),
        ),
      ];

  static final Discussion discussion = Discussion(
    discussionId: 'disc1',
    scanId: 'scan1',
    commodity: 'CABAI',
    daysAfterPlanting: 42,
    diagnosis: 'VIRUS_KUNING_KERITING',
    confidence: 0.72,
    suggestedPrompts: const ['Bisa menular ke tanaman lain?', 'Berapa lama sampai pulih?'],
    messages: [
      const DiscussionMessage(
        messageId: 'm1',
        role: MessageRole.user,
        content: 'Ini bahaya nggak?',
      ),
      const DiscussionMessage(
        messageId: 'm2',
        role: MessageRole.assistant,
        content:
            'Virus kuning keriting memang merugikan kalau dibiarkan, tapi di HST 42 kamu masih punya waktu.\n\n'
            'Yang paling menentukan sekarang dua hal: buang bagian yang sudah terinfeksi supaya kutu kebul '
            'tidak berpindah, dan kurangi kelembapan di sekitar tanaman.',
        citations: [
          Citation(title: 'Petunjuk Teknis Budidaya Cabai', publisher: 'Balitsa', year: 2023, page: 34),
        ],
        helpful: null,
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ModelManifest — API_DOCS.md v3.2 §4.2
//
// PENTING: inputSize dan healthyConfidenceThreshold WAJIB dibaca dari manifes,
// bukan ditulis langsung ke kode. Padi pakai 320, cabai dan terong pakai 224.
// Urutan labels adalah kontrak TFLite — jangan diurutkan ulang di klien.
// ─────────────────────────────────────────────────────────────────────────────

/// Manifes model TFLite per komoditas. Dibaca dari `GET /api/vision/model?commodity=X`.
/// Di tahap ini menggunakan data mock yang identik dengan tabel API_DOCS v3.2.
class ModelManifest {
  /// Kode komoditas: CABAI, TERONG, atau PADI.
  final String commodity;

  /// Versi model, misalnya "1.0.0".
  final String version;

  /// URL unduh file .tflite dari Supabase Storage.
  final String fileUrl;

  /// SHA-256 hex untuk verifikasi integritas setelah unduh.
  final String sha256;

  /// Ukuran file dalam byte — dipakai untuk progres unduh.
  final int bytes;

  /// Ukuran masukan model dalam piksel. Cabai & Terong: 224, Padi: 320.
  /// WAJIB dibaca dari manifes — jangan hardcode.
  final int inputSize;

  /// Tipe data piksel yang dikirim ke model. Selalu "float32"; 0–255 mentah,
  /// normalisasi ada di dalam model sehingga klien tidak perlu melakukannya.
  final String inputDtype;

  /// Skema kuantisasi. Selalu "FLOAT16" sejak v1.0.0.
  final String quantization;

  /// Urutan label output model. URUTAN INI ADALAH KONTRAK — TFLite mengembalikan
  /// indeks, bukan nama. Memakai urutan berbeda membuat label tertukar diam-diam.
  final List<String> labels;

  /// Ambang keyakinan umum. Sama untuk semua komoditas: 0.70.
  final double confidenceThreshold;

  /// Ambang khusus vonis SEHAT. Dibaca dari manifes karena berbeda per komoditas:
  /// cabai 0.85, terong 0.90, padi 0.90. Lebih ketat dengan sengaja — salah
  /// menyatakan sehat padahal sakit membuat petani kehilangan satu musim.
  final double healthyConfidenceThreshold;

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
  });

  /// Menerapkan aturan filter alternatif API_DOCS v3.2:
  /// Tampilkan setiap dugaan dengan confidence > 0.10, maks 3,
  /// kecuali label yang sudah menjadi dugaan utama.
  ///
  /// [allPredictions] adalah seluruh output model sebelum dipisah primary/alt.
  /// [primaryLabel] adalah label dengan confidence tertinggi.
  List<ScanPrediction> filterAlternatives(
    List<ScanPrediction> allPredictions,
    String primaryLabel,
  ) {
    return allPredictions
        .where((p) => p.label != primaryLabel && p.confidence > 0.10)
        .take(2) // maks 3 total termasuk primary, jadi alternatif maks 2
        .toList();
  }
}

/// Mock manifes resmi berdasarkan tabel Ringkasan Perubahan 3.2 API_DOCS.md.
/// Alamat file dan SHA-256 sudah final dan diverifikasi pada 18 Agustus 2026.
class MockManifests {
  static const String _supabaseBase =
      'https://znsifcxggkbvpbcstawe.supabase.co/storage/v1/object/public/';

  /// Manifes model Cabai v1.0.0 — Float16, inputSize 224.
  /// healthyConfidenceThreshold 0.85 (lebih longgar dari terong/padi karena
  /// dataset uji hanya 61 foto, semua berlatar polos — belum foto lapangan).
  static const ModelManifest cabai = ModelManifest(
    commodity: 'CABAI',
    version: '1.0.0',
    fileUrl: '${_supabaseBase}models/cabai/cabai_v100_fp16.tflite',
    sha256: '0c8b84f896736fb0b63645ef60585f1b528e46137d524919802620e5a74facc5',
    bytes: 5996812,
    inputSize: 224,
    inputDtype: 'float32',
    quantization: 'FLOAT16',
    // Urutan abjad Indonesia — ini adalah kontrak, jangan diubah.
    labels: ['BERCAK_DAUN', 'SEHAT', 'VIRUS_KUNING_KERITING'],
    confidenceThreshold: 0.70,
    healthyConfidenceThreshold: 0.85,
  );

  /// Manifes model Terong v1.0.0 — Float16, inputSize 224.
  /// healthyConfidenceThreshold 0.90.
  /// Urutan label mengikuti nama folder saat pelatihan (abjad Inggris lalu
  /// diterjemahkan): Healthy → SEHAT, Insect Pest → HAMA_SERANGGA, dst.
  static const ModelManifest terong = ModelManifest(
    commodity: 'TERONG',
    version: '1.0.0',
    fileUrl: '${_supabaseBase}models/terong/terong_v100_fp16.tflite',
    sha256: '3c301079ce022e89d46a467fdeb4a059b480200507699ea0b1aa5e009d54f748',
    bytes: 5995556,
    inputSize: 224,
    inputDtype: 'float32',
    quantization: 'FLOAT16',
    // PERHATIAN: urutan ini mengikuti abjad Inggris nama folder dataset,
    // BUKAN abjad Indonesia. Jangan diurutkan ulang.
    labels: [
      'SEHAT',
      'HAMA_SERANGGA',
      'BERCAK_DAUN',
      'VIRUS_MOSAIK',
      'DAUN_KERDIL',
      'EMBUN_TEPUNG_PUTIH',
      'LAYU',
    ],
    confidenceThreshold: 0.70,
    healthyConfidenceThreshold: 0.90,
  );

  /// Manifes model Padi v1.0.0 — Float16, inputSize 320 (berbeda dari lainnya!).
  /// healthyConfidenceThreshold 0.90.
  /// Hanya tiga label — Tungro, hispa, hawar tidak ada dalam model dan tidak
  /// boleh dipetakan ke label terdekat.
  static const ModelManifest padi = ModelManifest(
    commodity: 'PADI',
    version: '1.0.0',
    fileUrl: '${_supabaseBase}models/padi/padi_v100_fp16.tflite',
    sha256: 'c8ab7da9e5d4387c6b1befc737252f3d470e834e370916a16df4bf379aa8c5ab',
    bytes: 5987608,
    inputSize: 320, // BERBEDA dari cabai/terong — wajib dibaca dari manifes
    inputDtype: 'float32',
    quantization: 'FLOAT16',
    // Urutan abjad Indonesia.
    labels: ['BERCAK_COKELAT', 'BLAS_DAUN', 'SEHAT'],
    confidenceThreshold: 0.70,
    healthyConfidenceThreshold: 0.90,
  );

  /// Kembalikan manifes yang sesuai berdasarkan kode komoditas.
  static ModelManifest forCommodity(String commodity) {
    switch (commodity.toUpperCase()) {
      case 'TERONG':
        return terong;
      case 'PADI':
        return padi;
      default:
        return cabai;
    }
  }
}

