/// Enum backend yang diterima/dikirim sebagai string HURUF_BESAR_GARIS_BAWAH
/// (CATATAN_FE_FLUTTER.md bagian 8). Selalu sediakan `unknown` sebagai
/// fallback -- backend bisa menambah anggota enum sebelum aplikasi diperbarui.
enum Commodity {
  cabai,
  terong,
  padi,
  unknown;

  static Commodity fromApi(String? value) {
    return Commodity.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => Commodity.unknown,
    );
  }

  String get apiValue => name.toUpperCase();

  String get label {
    switch (this) {
      case Commodity.cabai:
        return 'Cabai';
      case Commodity.terong:
        return 'Terong';
      case Commodity.padi:
        return 'Padi';
      case Commodity.unknown:
        return 'Unknown';
    }
  }

  /// Upper-first label untuk kode peta (C/T/P).
  String get mapCode {
    switch (this) {
      case Commodity.cabai:
        return 'C';
      case Commodity.terong:
        return 'T';
      case Commodity.padi:
        return 'P';
      case Commodity.unknown:
        return '';
    }
  }
}

enum PlantStatus { active, harvested, ended, unknown }

extension PlantStatusX on PlantStatus {
  static PlantStatus fromApi(String? value) {
    return PlantStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => PlantStatus.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum ScanStatus { processing, done, lowConfidence, rejected, unknown }

extension ScanStatusX on ScanStatus {
  static ScanStatus fromApi(String? value) {
    return ScanStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => ScanStatus.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum UnitType { polybag, meterPersegi, hektar, unknown }

extension UnitTypeX on UnitType {
  static UnitType fromApi(String? value) {
    return UnitType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => UnitType.unknown,
    );
  }

  String get apiValue => name.toUpperCase();

  String get label {
    switch (this) {
      case UnitType.polybag:
        return 'polybag';
      case UnitType.meterPersegi:
        return 'm²';
      case UnitType.hektar:
        return 'ha';
      case UnitType.unknown:
        return '';
    }
  }
}

enum LessonType { card, video, exerciseMcq, exerciseMatch, exerciseOrder, exerciseImage, unknown }

extension LessonTypeX on LessonType {
  static LessonType fromApi(String? value) {
    return LessonType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => LessonType.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum VideoKind { selfHosted, embed, unknown }

extension VideoKindX on VideoKind {
  static VideoKind fromApi(String? value) {
    return VideoKind.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => VideoKind.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum NodeStatus { locked, available, inProgress, completed, perfect, unknown }

extension NodeStatusX on NodeStatus {
  static NodeStatus fromApi(String? value) {
    return NodeStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => NodeStatus.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum QuestionSort { newest, top, active, unanswered, unknown }

extension QuestionSortX on QuestionSort {
  static QuestionSort fromApi(String? value) {
    return QuestionSort.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => QuestionSort.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum ReportReason { spam, harassment, misinformation, offTopic, other, unknown }

extension ReportReasonX on ReportReason {
  static ReportReason fromApi(String? value) {
    return ReportReason.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => ReportReason.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum NotificationType {
  replyReceived,
  bestAnswerMarked,
  mention,
  scanReminder,
  streakWarning,
  levelUnlocked,
  badgeEarned,
  modelUpdated,
  unknown,
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromApi(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => NotificationType.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum XpReason {
  lessonCompleted,
  exerciseCompleted,
  quizPassed,
  finalTestPassed,
  firstDailyScan,
  bestAnswerReceived,
  replyPosted,
  plantHarvested,
  unknown,
}

extension XpReasonX on XpReason {
  static XpReason fromApi(String? value) {
    return XpReason.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => XpReason.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum Role { user, moderator, admin, unknown }

extension RoleX on Role {
  static Role fromApi(String? value) {
    return Role.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => Role.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum ScanFlagReason { wrongLabel, notALeaf, other, unknown }

extension ScanFlagReasonX on ScanFlagReason {
  static ScanFlagReason fromApi(String? value) {
    return ScanFlagReason.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => ScanFlagReason.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum ReportTargetType { question, reply, unknown }

extension ReportTargetTypeX on ReportTargetType {
  static ReportTargetType fromApi(String? value) {
    return ReportTargetType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => ReportTargetType.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

enum UploadPurpose { scan, avatar, community }

extension UploadPurposeX on UploadPurpose {
  String get apiValue => name.toUpperCase();
}