// Enum backend yang diterima/dikirim sebagai string HURUF_BESAR_GARIS_BAWAH
// (CATATAN_FE_FLUTTER.md bagian 8). Selalu sediakan `unknown` sebagai
// fallback -- backend bisa menambah anggota enum sebelum aplikasi diperbarui.

/// Ubah nama anggota enum Dart (camelCase) menjadi nilai enum backend
/// (SCREAMING_SNAKE_CASE).
///
/// Tanpa ini `exerciseMcq` menghasilkan `EXERCISEMCQ` dan tidak pernah cocok
/// dengan `EXERCISE_MCQ` dari backend, sehingga setiap anggota enum yang
/// namanya lebih dari satu kata diam-diam jatuh ke `unknown`.
String enumApiValue(String memberName) {
  final buffer = StringBuffer();
  for (final rune in memberName.runes) {
    final char = String.fromCharCode(rune);
    final upper = char.toUpperCase();
    if (char != upper && buffer.isEmpty) {
      buffer.write(upper);
      continue;
    }
    if (char == upper && char.toLowerCase() != char) {
      buffer.write('_');
    }
    buffer.write(upper);
  }
  return buffer.toString();
}

/// Cari anggota enum yang nilai API-nya sama dengan [value].
T enumFromApi<T extends Enum>(List<T> values, String? value, T fallback) {
  if (value == null) return fallback;
  for (final member in values) {
    if (enumApiValue(member.name) == value) return member;
  }
  return fallback;
}

enum Commodity {
  cabai,
  terong,
  padi,
  unknown;

  static Commodity fromApi(String? value) {
    return enumFromApi(Commodity.values, value, Commodity.unknown);
  }

  String get apiValue => enumApiValue(name);

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
    return enumFromApi(PlantStatus.values, value, PlantStatus.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum ScanStatus { processing, done, lowConfidence, rejected, unknown }

extension ScanStatusX on ScanStatus {
  static ScanStatus fromApi(String? value) {
    return enumFromApi(ScanStatus.values, value, ScanStatus.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum UnitType { polybag, meterPersegi, hektar, unknown }

extension UnitTypeX on UnitType {
  static UnitType fromApi(String? value) {
    return enumFromApi(UnitType.values, value, UnitType.unknown);
  }

  String get apiValue => enumApiValue(name);

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
    return enumFromApi(LessonType.values, value, LessonType.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum VideoKind { selfHosted, embed, unknown }

extension VideoKindX on VideoKind {
  static VideoKind fromApi(String? value) {
    return enumFromApi(VideoKind.values, value, VideoKind.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum NodeStatus { locked, available, inProgress, completed, perfect, unknown }

extension NodeStatusX on NodeStatus {
  static NodeStatus fromApi(String? value) {
    return enumFromApi(NodeStatus.values, value, NodeStatus.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum QuestionSort { newest, top, active, unanswered, unknown }

extension QuestionSortX on QuestionSort {
  static QuestionSort fromApi(String? value) {
    return enumFromApi(QuestionSort.values, value, QuestionSort.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum ReportReason { spam, harassment, misinformation, offTopic, other, unknown }

extension ReportReasonX on ReportReason {
  static ReportReason fromApi(String? value) {
    return enumFromApi(ReportReason.values, value, ReportReason.unknown);
  }

  String get apiValue => enumApiValue(name);
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
    return enumFromApi(NotificationType.values, value, NotificationType.unknown);
  }

  String get apiValue => enumApiValue(name);
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
    return enumFromApi(XpReason.values, value, XpReason.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum Role { user, moderator, admin, unknown }

extension RoleX on Role {
  static Role fromApi(String? value) {
    return enumFromApi(Role.values, value, Role.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum ScanFlagReason { wrongLabel, notALeaf, other, unknown }

extension ScanFlagReasonX on ScanFlagReason {
  static ScanFlagReason fromApi(String? value) {
    return enumFromApi(ScanFlagReason.values, value, ScanFlagReason.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum ReportTargetType { question, reply, unknown }

extension ReportTargetTypeX on ReportTargetType {
  static ReportTargetType fromApi(String? value) {
    return enumFromApi(ReportTargetType.values, value, ReportTargetType.unknown);
  }

  String get apiValue => enumApiValue(name);
}

enum UploadPurpose { scan, avatar, community }

extension UploadPurposeX on UploadPurpose {
  String get apiValue => enumApiValue(name);
}