/// Model data tab Saya. Nama field mengikuti camelCase di
/// SourceOfTruth/API_DOCS_NEW.md §2 (profil) dan §3.4 (gamifikasi).
library;

class UserProfile {
  final String userId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? province;
  final String? district;
  final List<String> commodities;
  final int reputation;
  final DateTime joinedAt;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.province,
    this.district,
    this.commodities = const [],
    this.reputation = 0,
    required this.joinedAt,
  });
}

class GamificationStats {
  final int totalXp;
  final int level;
  final int xpToNextLevel;
  final int lives;
  final int maxLives;
  final int streakDays;
  final int streakFreezeCount;
  final int badgeCount;
  final int completedLevels;

  const GamificationStats({
    required this.totalXp,
    required this.level,
    required this.xpToNextLevel,
    required this.lives,
    required this.maxLives,
    required this.streakDays,
    required this.streakFreezeCount,
    required this.badgeCount,
    required this.completedLevels,
  });
}

class Badge {
  final String badgeId;
  final String code;
  final String name;
  final String description;
  final DateTime? earnedAt;
  final int? progress;
  final int? target;

  const Badge({
    required this.badgeId,
    required this.code,
    required this.name,
    required this.description,
    this.earnedAt,
    this.progress,
    this.target,
  });

  bool get isEarned => earnedAt != null;
}

class XpHistoryItem {
  final String id;
  final int amount;
  final String reason;
  final DateTime createdAt;

  const XpHistoryItem({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });
}

String xpReasonLabel(String reason) {
  switch (reason) {
    case 'LESSON_COMPLETED':
      return 'Lesson selesai';
    case 'EXERCISE_COMPLETED':
      return 'Latihan selesai';
    case 'QUIZ_PASSED':
      return 'Ujian Unit lulus';
    case 'FINAL_TEST_PASSED':
      return 'Ujian Petak lulus';
    case 'FIRST_DAILY_SCAN':
      return 'Pindai pertama hari ini';
    case 'BEST_ANSWER_RECEIVED':
      return 'Jawaban ditandai terbaik';
    case 'REPLY_POSTED':
      return 'Membalas pertanyaan';
    case 'PLANT_HARVESTED':
      return 'Tanaman dipanen';
    default:
      return reason;
  }
}

class NotificationItem {
  final String notificationId;
  final String type;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationItem({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    this.readAt,
    required this.createdAt,
  });
}

class NotificationPreferences {
  bool scanReminder;
  bool replyReceived;
  bool bestAnswerMarked;
  bool streakWarning;

  NotificationPreferences({
    this.scanReminder = true,
    this.replyReceived = true,
    this.bestAnswerMarked = true,
    this.streakWarning = true,
  });
}

class SayaMockData {
  static final UserProfile profile = UserProfile(
    userId: 'u1',
    fullName: 'Reza Pratama',
    email: 'reza@mail.com',
    province: 'Jawa Tengah',
    district: 'Grobogan',
    commodities: const ['CABAI', 'TERONG'],
    reputation: 42,
    joinedAt: DateTime(2026, 8, 1),
  );

  static const GamificationStats stats = GamificationStats(
    totalXp: 1250,
    level: 4,
    xpToNextLevel: 250,
    lives: 3,
    maxLives: 5,
    streakDays: 13,
    streakFreezeCount: 1,
    badgeCount: 4,
    completedLevels: 2,
  );

  static final List<Badge> badges = [
    Badge(badgeId: 'b1', code: 'PANEN_PERTAMA', name: 'Panen Pertama', description: 'Catat panen pertamamu', earnedAt: DateTime(2026, 8, 2)),
    Badge(badgeId: 'b2', code: 'LEVEL_1', name: 'Petak Pertama', description: 'Selesaikan satu Petak penuh', earnedAt: DateTime(2026, 8, 5)),
    const Badge(badgeId: 'b3', code: 'STREAK_30', name: 'Rajin Sebulan', description: 'Runtutan 30 hari', progress: 13, target: 30),
    const Badge(badgeId: 'b4', code: 'JAWABAN_TERBAIK_10', name: 'Andalan Warung', description: '10 jawaban terbaik', progress: 4, target: 10),
  ];

  static final List<XpHistoryItem> xpHistory = [
    XpHistoryItem(id: 'x1', amount: 50, reason: 'QUIZ_PASSED', createdAt: DateTime(2026, 8, 11, 9, 15)),
    XpHistoryItem(id: 'x2', amount: 10, reason: 'LESSON_COMPLETED', createdAt: DateTime(2026, 8, 11, 8, 50)),
    XpHistoryItem(id: 'x3', amount: 5, reason: 'FIRST_DAILY_SCAN', createdAt: DateTime(2026, 8, 11, 6, 12)),
    XpHistoryItem(id: 'x4', amount: 25, reason: 'BEST_ANSWER_RECEIVED', createdAt: DateTime(2026, 8, 10, 14, 0)),
  ];

  static final List<NotificationItem> notifications = [
    NotificationItem(
      notificationId: 'n1',
      type: 'REPLY_RECEIVED',
      title: 'Dimas W menjawab pertanyaanmu',
      body: 'Kalau keritingnya ke atas dan daun mudanya yang kena...',
      createdAt: DateTime(2026, 8, 11, 1, 0),
    ),
    NotificationItem(
      notificationId: 'n2',
      type: 'BADGE_EARNED',
      title: 'Lencana baru: Petak Pertama',
      body: 'Kamu menyelesaikan satu Petak penuh.',
      readAt: DateTime(2026, 8, 5, 10, 0),
      createdAt: DateTime(2026, 8, 5, 9, 0),
    ),
    NotificationItem(
      notificationId: 'n3',
      type: 'STREAK_WARNING',
      title: 'Jangan putus runtutan hari ini',
      body: 'Selesaikan minimal satu aktivitas sebelum tengah malam.',
      readAt: DateTime(2026, 8, 4, 20, 0),
      createdAt: DateTime(2026, 8, 4, 19, 0),
    ),
  ];

  static final NotificationPreferences preferences = NotificationPreferences();
}
