/// Model data F2 Periksa Tanaman. Nama field mengikuti camelCase di
/// SourceOfTruth/API_DOCS_NEW.md §4 apa adanya, supaya nanti tinggal diganti
/// sumbernya (mock -> repository Dio) tanpa reshape model.
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
  ];

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
    alternatives: [
      ScanPrediction(label: 'BERCAK_DAUN', displayName: 'Bercak Daun', confidence: 0.18),
      ScanPrediction(label: 'SEHAT', displayName: 'Sehat', confidence: 0.07),
    ],
    suggestedPrompts: ['Ini bahaya nggak?', 'Bisa menular ke tanaman lain?', 'Berapa lama sampai pulih?'],
  );

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
