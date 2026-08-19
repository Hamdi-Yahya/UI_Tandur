import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_enums.dart';

// ============================== GAMIFIKASI ==============================

/// Statistik gamifikasi dari GET /gamification/stats (API_DOCS §3.4).
class GamificationStats {
  const GamificationStats({
    required this.totalXp,
    required this.level,
    required this.xpToNextLevel,
    required this.lives,
    required this.maxLives,
    this.nextLifeAt,
    required this.streakDays,
    required this.streakFreezeCount,
    this.lastActivityDate,
    required this.badgeCount,
    required this.completedLevels,
  });

  final int totalXp;
  final int level;
  final int xpToNextLevel;
  final int lives;
  final int maxLives;
  final DateTime? nextLifeAt;
  final int streakDays;
  final int streakFreezeCount;
  final DateTime? lastActivityDate;
  final int badgeCount;
  final int completedLevels;

  factory GamificationStats.fromJson(Map<String, dynamic> json) {
    return GamificationStats(
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 0,
      lives: json['lives'] as int? ?? 0,
      maxLives: json['maxLives'] as int? ?? 0,
      nextLifeAt: _parseDate(json['nextLifeAt']),
      streakDays: json['streakDays'] as int? ?? 0,
      streakFreezeCount: json['streakFreezeCount'] as int? ?? 0,
      lastActivityDate: _parseDate(json['lastActivityDate']),
      badgeCount: json['badgeCount'] as int? ?? 0,
      completedLevels: json['completedLevels'] as int? ?? 0,
    );
  }
}

/// Satu entri riwayat XP (API_DOCS §3.4 Get XP History).
class XpHistoryItem {
  const XpHistoryItem({
    required this.id,
    required this.amount,
    required this.reason,
    this.referenceType,
    this.referenceId,
    required this.createdAt,
  });

  final String id;
  final int amount;
  final XpReason reason;
  final String? referenceType;
  final String? referenceId;
  final DateTime createdAt;

  factory XpHistoryItem.fromJson(Map<String, dynamic> json) {
    return XpHistoryItem(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      reason: XpReasonX.fromApi(json['reason']?.toString()),
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Halaman riwayat XP — paginasi cursor, `nextCursor: null` = halaman terakhir.
class XpHistoryPage {
  const XpHistoryPage({required this.items, this.nextCursor});

  final List<XpHistoryItem> items;
  final String? nextCursor;

  factory XpHistoryPage.fromJson(Map<String, dynamic> json) {
    return XpHistoryPage(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => XpHistoryItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Label bahasa Indonesia untuk [XpReason], menggantikan `xpReasonLabel`
/// pada data mock.
extension XpReasonLabelX on XpReason {
  String get label {
    switch (this) {
      case XpReason.lessonCompleted:
        return 'Lesson selesai';
      case XpReason.exerciseCompleted:
        return 'Latihan selesai';
      case XpReason.quizPassed:
        return 'Ujian Unit lulus';
      case XpReason.finalTestPassed:
        return 'Ujian Petak lulus';
      case XpReason.firstDailyScan:
        return 'Pindai pertama hari ini';
      case XpReason.bestAnswerReceived:
        return 'Jawaban ditandai terbaik';
      case XpReason.replyPosted:
        return 'Membalas pertanyaan';
      case XpReason.plantHarvested:
        return 'Tanaman dipanen';
      case XpReason.unknown:
        return 'Aktivitas';
    }
  }
}

/// Lencana pengguna (API_DOCS §3.4 Get My Badges). `earnedAt != null` berarti
/// sudah didapat; sebaliknya sedang berjalan dengan progress/target.
class Badge {
  const Badge({
    required this.badgeId,
    required this.code,
    required this.name,
    this.description = '',
    this.iconUrl,
    this.earnedAt,
    this.progress,
    this.target,
  });

  final String badgeId;
  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final DateTime? earnedAt;
  final int? progress;
  final int? target;

  bool get isEarned => earnedAt != null;

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      badgeId: json['badgeId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      earnedAt: _parseDate(json['earnedAt']),
      progress: json['progress'] as int?,
      target: json['target'] as int?,
    );
  }
}

/// Hasil pembelian Pelindung Runtutan (API_DOCS §3.4 Buy Streak Freeze).
class StreakFreezeResult {
  const StreakFreezeResult({
    required this.streakFreezeCount,
    required this.xpSpent,
    required this.totalXp,
  });

  final int streakFreezeCount;
  final int xpSpent;
  final int totalXp;

  factory StreakFreezeResult.fromJson(Map<String, dynamic> json) {
    return StreakFreezeResult(
      streakFreezeCount: json['streakFreezeCount'] as int? ?? 0,
      xpSpent: json['xpSpent'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
    );
  }
}

/// Repository gamifikasi (API_DOCS §3.4). Melempar [ApiException] yang sudah
/// ternormalisasi.
class GamificationRepository {
  GamificationRepository(this._dio);

  final Dio _dio;

  /// Statistik XP, level, nyawa, runtutan, dan lencana.
  Future<GamificationStats> getStats() async {
    final res = await guardApi(() => _dio.get('/gamification/stats'));
    return GamificationStats.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Riwayat XP dengan paginasi cursor. `cursor` diisi `nextCursor` dari
  /// halaman sebelumnya; `null` berarti mulai dari awal (pull-to-refresh).
  Future<XpHistoryPage> getXpHistory({int? limit, String? cursor}) async {
    final res = await guardApi(() => _dio.get(
          '/gamification/xp-history',
          queryParameters: <String, dynamic>{
            'limit': ?limit,
            'cursor': ?cursor,
          },
        ));
    return XpHistoryPage.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Semua lencana: yang sudah didapat dan yang sedang berjalan.
  Future<List<Badge>> getBadges() async {
    final res = await guardApi(() => _dio.get('/gamification/badges'));
    return (res.data as List<dynamic>? ?? const [])
        .map((e) => Badge.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Beli Pelindung Runtutan dengan XP.
  Future<StreakFreezeResult> buyStreakFreeze() async {
    final res = await guardApi(() => _dio.post('/gamification/streak-freeze'));
    return StreakFreezeResult.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

// ============================== NOTIFIKASI ==============================

/// Satu notifikasi (API_DOCS bagian 6). `readAt == null` berarti belum dibaca.
class AppNotification {
  const AppNotification({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    this.readAt,
    required this.createdAt,
  });

  final String notificationId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId'] as String? ?? '',
      type: NotificationTypeX.fromApi(json['type']?.toString()),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      payload: json['payload'] as Map<String, dynamic>?,
      readAt: _parseDate(json['readAt']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Halaman notifikasi: daftar + jumlah belum dibaca + kursor halaman berikutnya.
class NotificationPage {
  const NotificationPage({
    required this.unreadCount,
    required this.items,
    this.nextCursor,
  });

  final int unreadCount;
  final List<AppNotification> items;
  final String? nextCursor;

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    return NotificationPage(
      unreadCount: json['unreadCount'] as int? ?? 0,
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => AppNotification.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Preferensi notifikasi (API_DOCS bagian 6 Update Preferences). Tidak ada
/// endpoint GET, jadi layar memegang nilai terakhir yang berhasil disimpan.
class NotificationPreferences {
  const NotificationPreferences({
    this.scanReminder = true,
    this.scanReminderDays = 7,
    this.replyReceived = true,
    this.bestAnswerMarked = true,
    this.streakWarning = true,
    this.streakWarningHour = 19,
  });

  final bool scanReminder;
  final int scanReminderDays;
  final bool replyReceived;
  final bool bestAnswerMarked;
  final bool streakWarning;
  final int streakWarningHour;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      scanReminder: json['scanReminder'] as bool? ?? true,
      scanReminderDays: json['scanReminderDays'] as int? ?? 7,
      replyReceived: json['replyReceived'] as bool? ?? true,
      bestAnswerMarked: json['bestAnswerMarked'] as bool? ?? true,
      streakWarning: json['streakWarning'] as bool? ?? true,
      streakWarningHour: json['streakWarningHour'] as int? ?? 19,
    );
  }

  NotificationPreferences copyWith({
    bool? scanReminder,
    int? scanReminderDays,
    bool? replyReceived,
    bool? bestAnswerMarked,
    bool? streakWarning,
    int? streakWarningHour,
  }) {
    return NotificationPreferences(
      scanReminder: scanReminder ?? this.scanReminder,
      scanReminderDays: scanReminderDays ?? this.scanReminderDays,
      replyReceived: replyReceived ?? this.replyReceived,
      bestAnswerMarked: bestAnswerMarked ?? this.bestAnswerMarked,
      streakWarning: streakWarning ?? this.streakWarning,
      streakWarningHour: streakWarningHour ?? this.streakWarningHour,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scanReminder': scanReminder,
      'scanReminderDays': scanReminderDays,
      'replyReceived': replyReceived,
      'bestAnswerMarked': bestAnswerMarked,
      'streakWarning': streakWarning,
      'streakWarningHour': streakWarningHour,
    };
  }
}

/// Repository notifikasi (API_DOCS bagian 6). Melempar [ApiException] yang
/// sudah ternormalisasi.
class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  /// Daftar notifikasi + jumlah belum dibaca, dengan paginasi cursor.
  Future<NotificationPage> getNotifications({
    bool? unreadOnly,
    int? limit,
    String? cursor,
  }) async {
    final res = await guardApi(() => _dio.get(
          '/notifications',
          queryParameters: <String, dynamic>{
            'unreadOnly': ?unreadOnly,
            'limit': ?limit,
            'cursor': ?cursor,
          },
        ));
    return NotificationPage.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Tandai satu notifikasi dibaca. Mengembalikan jumlah belum dibaca terbaru.
  Future<int> markRead(String id) async {
    final res = await guardApi(() => _dio.post('/notifications/$id/read'));
    final data = (res.data as Map).cast<String, dynamic>();
    return data['unreadCount'] as int? ?? 0;
  }

  /// Tandai semua notifikasi dibaca. Mengembalikan jumlah belum dibaca (0).
  Future<int> markAllRead() async {
    final res = await guardApi(() => _dio.post('/notifications/read-all'));
    final data = (res.data as Map).cast<String, dynamic>();
    return data['unreadCount'] as int? ?? 0;
  }

  /// Simpan preferensi notifikasi (seluruh field dikirim penuh).
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    await guardApi(() => _dio.put('/notifications/preferences', data: preferences.toJson()));
  }
}

// ============================== PROVIDER ==============================

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(dioProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});

/// Waktu backend selalu UTC ISO 8601; tampilkan dalam zona lokal.
DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}
