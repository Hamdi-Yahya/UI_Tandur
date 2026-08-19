import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_enums.dart';

/// Model + repository untuk F1 Kelas Tandur (API_DOCS bagian 3).
///
/// EnvelopeInterceptor sudah mengupas `{ msg, data }`, jadi repository cukup
/// memanggil `Model.fromJson(response.data)` (CATATAN_FE_FLUTTER.md 2.1 dan 3.4).

/// Node pada peta pembelajaran per komoditas.
class LearningMapNode {
  const LearningMapNode({
    required this.levelId,
    required this.code,
    required this.title,
    required this.status,
    required this.progressPercent,
    required this.stars,
    required this.shapeVariant,
    required this.mapX,
    required this.mapY,
    this.lockReason,
  });

  final String levelId;
  final String code;
  final String title;
  final NodeStatus status;
  final int progressPercent;
  final int stars;
  final int shapeVariant;
  final double mapX;
  final double mapY;
  final String? lockReason;

  factory LearningMapNode.fromJson(Map<String, dynamic> json) {
    return LearningMapNode(
      levelId: json['levelId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: NodeStatusX.fromApi(json['status'] as String?),
      progressPercent: json['progressPercent'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      shapeVariant: json['shapeVariant'] as int? ?? 0,
      mapX: (json['mapX'] as num?)?.toDouble() ?? 0,
      mapY: (json['mapY'] as num?)?.toDouble() ?? 0,
      lockReason: json['lockReason'] as String?,
    );
  }
}

/// Isi peta pembelajaran sekaligus stats gamifikasi utama.
class LearningMap {
  const LearningMap({
    required this.commodity,
    required this.totalXp,
    required this.streakDays,
    required this.lives,
    required this.nodes,
    this.nextLifeAt,
  });

  final Commodity commodity;
  final int totalXp;
  final int streakDays;
  final int lives;
  final DateTime? nextLifeAt;
  final List<LearningMapNode> nodes;

  factory LearningMap.fromJson(Map<String, dynamic> json) {
    return LearningMap(
      commodity: Commodity.fromApi(json['commodity'] as String?),
      totalXp: json['totalXp'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lives: json['lives'] as int? ?? 0,
      nextLifeAt: DateTime.tryParse(json['nextLifeAt'] as String? ?? ''),
      nodes:
          (json['nodes'] as List<dynamic>?)
              ?.map(
                (e) => LearningMapNode.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

/// Ringkasan satu unit di dalam petak.
class LevelUnitSummary {
  const LevelUnitSummary({
    required this.unitId,
    required this.title,
    required this.lessonCount,
    required this.completedCount,
    required this.status,
  });

  final String unitId;
  final String title;
  final int lessonCount;
  final int completedCount;
  final NodeStatus status;

  /// Progres unit 0.0-1.0, dihitung dari lesson selesai.
  double get progress => lessonCount == 0 ? 0.0 : completedCount / lessonCount;

  factory LevelUnitSummary.fromJson(Map<String, dynamic> json) {
    return LevelUnitSummary(
      unitId: json['unitId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      lessonCount: json['lessonCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
      status: NodeStatusX.fromApi(json['status'] as String?),
    );
  }
}

/// Kartu ujian akhir petak.
class LevelFinalTest {
  const LevelFinalTest({
    required this.testId,
    required this.questionCount,
    required this.passThreshold,
    required this.status,
    this.lockReason,
  });

  final String testId;
  final int questionCount;
  final int passThreshold;
  final NodeStatus status;
  final String? lockReason;

  factory LevelFinalTest.fromJson(Map<String, dynamic> json) {
    return LevelFinalTest(
      testId: json['testId'] as String? ?? '',
      questionCount: json['questionCount'] as int? ?? 0,
      passThreshold: json['passThreshold'] as int? ?? 0,
      status: NodeStatusX.fromApi(json['status'] as String?),
      lockReason: json['lockReason'] as String?,
    );
  }
}

/// Detail petak: deskripsi, unit, dan ujian akhir.
class LevelDetail {
  const LevelDetail({
    required this.levelId,
    required this.code,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.units,
    this.finalTest,
  });

  final String levelId;
  final String code;
  final String title;
  final String description;
  final int estimatedMinutes;
  final List<LevelUnitSummary> units;
  final LevelFinalTest? finalTest;

  factory LevelDetail.fromJson(Map<String, dynamic> json) {
    return LevelDetail(
      levelId: json['levelId'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
      units:
          (json['units'] as List<dynamic>?)
              ?.map(
                (e) => LevelUnitSummary.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
      finalTest: json['finalTest'] == null
          ? null
          : LevelFinalTest.fromJson(
              (json['finalTest'] as Map).cast<String, dynamic>(),
            ),
    );
  }
}

/// Ringkasan satu materi di dalam unit.
class UnitLessonSummary {
  const UnitLessonSummary({
    required this.lessonId,
    required this.type,
    required this.title,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.status,
    required this.order,
    this.durationSeconds,
    this.isOfflineCapable = false,
  });

  final String lessonId;
  final LessonType type;
  final String title;
  final int estimatedMinutes;
  final int? durationSeconds;
  final int xpReward;
  final NodeStatus status;
  final int order;
  final bool isOfflineCapable;

  factory UnitLessonSummary.fromJson(Map<String, dynamic> json) {
    return UnitLessonSummary(
      lessonId: json['lessonId'] as String? ?? '',
      type: LessonTypeX.fromApi(json['type'] as String?),
      title: json['title'] as String? ?? '',
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int?,
      xpReward: json['xpReward'] as int? ?? 0,
      status: NodeStatusX.fromApi(json['status'] as String?),
      order: json['order'] as int? ?? 0,
      isOfflineCapable: json['isOfflineCapable'] as bool? ?? false,
    );
  }
}

/// Alias nama ringkas untuk [UnitLessonSummary].
typedef LessonSummary = UnitLessonSummary;

/// Kartu kuis pemahaman unit.
class UnitQuizSummary {
  const UnitQuizSummary({
    required this.quizId,
    required this.questionCount,
    required this.passThreshold,
    required this.status,
  });

  final String quizId;
  final int questionCount;
  final int passThreshold;
  final NodeStatus status;

  factory UnitQuizSummary.fromJson(Map<String, dynamic> json) {
    return UnitQuizSummary(
      quizId: json['quizId'] as String? ?? '',
      questionCount: json['questionCount'] as int? ?? 0,
      passThreshold: json['passThreshold'] as int? ?? 0,
      status: NodeStatusX.fromApi(json['status'] as String?),
    );
  }
}

/// Daftar materi dan kuis sebuah unit.
class UnitLessons {
  const UnitLessons({
    required this.unitId,
    required this.title,
    required this.progressPercent,
    required this.lessons,
    this.quiz,
  });

  final String unitId;
  final String title;
  final int progressPercent;
  final List<UnitLessonSummary> lessons;
  final UnitQuizSummary? quiz;

  factory UnitLessons.fromJson(Map<String, dynamic> json) {
    return UnitLessons(
      unitId: json['unitId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      progressPercent: json['progressPercent'] as int? ?? 0,
      lessons:
          (json['lessons'] as List<dynamic>?)
              ?.map(
                (e) => UnitLessonSummary.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
      quiz: json['quiz'] == null
          ? null
          : UnitQuizSummary.fromJson(
              (json['quiz'] as Map).cast<String, dynamic>(),
            ),
    );
  }
}

/// Tipe blok materi CARD.
enum LessonBlockType { heading, image, paragraph, callout, unknown }

extension LessonBlockTypeX on LessonBlockType {
  static LessonBlockType fromApi(String? value) {
    return LessonBlockType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => LessonBlockType.unknown,
    );
  }

  String get apiValue => name.toUpperCase();
}

/// Satu halaman dalam materi CARD (HEADING/IMAGE/PARAGRAPH/CALLOUT).
class LessonBlock {
  const LessonBlock({
    required this.type,
    this.text,
    this.url,
    this.caption,
    this.variant,
    this.title,
  });

  final LessonBlockType type;

  /// Isi teks untuk HEADING dan PARAGRAPH.
  final String? text;

  /// URL gambar untuk IMAGE.
  final String? url;

  /// Keterangan gambar untuk IMAGE.
  final String? caption;

  /// Variasi kotak CALLOUT (mis. `MISTAKE`).
  final String? variant;

  /// Judul untuk CALLOUT.
  final String? title;

  factory LessonBlock.fromJson(Map<String, dynamic> json) {
    return LessonBlock(
      type: LessonBlockTypeX.fromApi(json['type'] as String?),
      text: json['text'] as String?,
      url: json['url'] as String?,
      caption: json['caption'] as String?,
      variant: json['variant'] as String?,
      title: json['title'] as String?,
    );
  }
}

/// Lesson CARD atau VIDEO.
class LessonDetail {
  const LessonDetail({
    required this.lessonId,
    required this.type,
    required this.title,
    this.blocks = const [],
    this.videoKind = VideoKind.unknown,
    this.videoUrl360p,
    this.videoUrl720p,
    this.subtitleUrl,
    this.youtubeVideoId,
    this.transcript,
    this.durationSeconds,
    this.lastPositionSeconds = 0,
    this.attribution,
    this.sourceReference,
    this.reviewedBy,
    this.xpReward = 0,
    this.nextLessonId,
    this.isOfflineCapable = false,
  });

  final String lessonId;
  final LessonType type;
  final String title;

  /// Blok materi untuk tipe CARD.
  final List<LessonBlock> blocks;

  /// Kelengkapan video untuk tipe VIDEO.
  final VideoKind videoKind;
  final String? videoUrl360p;
  final String? videoUrl720p;
  final String? subtitleUrl;
  final String? youtubeVideoId;

  /// Transkrip untuk tipe VIDEO bila tersedia.
  final String? transcript;
  final int? durationSeconds;
  final int lastPositionSeconds;

  /// Atribusi/kredit sumber video.
  final String? attribution;

  /// Rujukan sumber materi.
  final String? sourceReference;

  /// Peninjau materi.
  final String? reviewedBy;
  final int xpReward;
  final String? nextLessonId;
  final bool isOfflineCapable;

  factory LessonDetail.fromJson(Map<String, dynamic> json) {
    return LessonDetail(
      lessonId: json['lessonId'] as String? ?? '',
      type: LessonTypeX.fromApi(json['type'] as String?),
      title: json['title'] as String? ?? '',
      blocks:
          (json['blocks'] as List<dynamic>?)
              ?.map(
                (e) => LessonBlock.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
      videoKind: VideoKindX.fromApi(json['videoKind'] as String?),
      videoUrl360p: json['videoUrl360p'] as String?,
      videoUrl720p: json['videoUrl720p'] as String?,
      subtitleUrl: json['subtitleUrl'] as String?,
      youtubeVideoId: json['youtubeVideoId'] as String?,
      transcript: json['transcript'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      lastPositionSeconds: json['lastPositionSeconds'] as int? ?? 0,
      attribution: json['attribution'] as String?,
      sourceReference: json['sourceReference'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      xpReward: json['xpReward'] as int? ?? 0,
      nextLessonId: json['nextLessonId'] as String?,
      isOfflineCapable: json['isOfflineCapable'] as bool? ?? false,
    );
  }
}

/// Pilihan jawaban latihan (key + teks).
class ExerciseOption {
  const ExerciseOption({required this.key, required this.text});

  final String key;
  final String text;

  factory ExerciseOption.fromJson(Map<String, dynamic> json) {
    return ExerciseOption(
      key: json['key'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

/// Satu soal latihan.
class ExerciseQuestion {
  const ExerciseQuestion({
    required this.exerciseId,
    required this.prompt,
    required this.options,
    this.imageUrl,
    this.order = 0,
  });

  final String exerciseId;
  final String prompt;
  final String? imageUrl;
  final List<ExerciseOption> options;
  final int order;

  factory ExerciseQuestion.fromJson(Map<String, dynamic> json) {
    return ExerciseQuestion(
      exerciseId: json['exerciseId'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ExerciseOption.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
      order: json['order'] as int? ?? 0,
    );
  }
}

/// Paket latihan untuk satu lesson bertipe EXERCISE_*.
class ExerciseDetail {
  const ExerciseDetail({
    required this.lessonId,
    required this.type,
    required this.questions,
  });

  final String lessonId;
  final LessonType type;
  final List<ExerciseQuestion> questions;

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    return ExerciseDetail(
      lessonId: json['lessonId'] as String? ?? '',
      type: LessonTypeX.fromApi(json['type'] as String?),
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (e) => ExerciseQuestion.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

/// Penilaian per soal latihan.
class ExerciseAnswerResult {
  const ExerciseAnswerResult({
    required this.exerciseId,
    required this.correct,
    required this.correctAnswer,
    this.explanation,
  });

  final String exerciseId;
  final bool correct;
  final String correctAnswer;
  final String? explanation;

  factory ExerciseAnswerResult.fromJson(Map<String, dynamic> json) {
    return ExerciseAnswerResult(
      exerciseId: json['exerciseId'] as String? ?? '',
      correct: json['correct'] as bool? ?? false,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String?,
    );
  }
}

/// Hasil submit latihan.
class ExerciseResult {
  const ExerciseResult({
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.xpEarned,
    required this.results,
  });

  final int score;
  final int correctCount;
  final int totalCount;
  final int xpEarned;
  final List<ExerciseAnswerResult> results;

  factory ExerciseResult.fromJson(Map<String, dynamic> json) {
    return ExerciseResult(
      score: json['score'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      results:
          (json['results'] as List<dynamic>?)
              ?.map(
                (e) => ExerciseAnswerResult.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

/// Pilihan jawaban kuis/ujian.
class QuizOption {
  const QuizOption({required this.key, required this.text});

  final String key;
  final String text;

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      key: json['key'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

/// Soal kuis/ujian.
class QuizQuestion {
  const QuizQuestion({
    required this.questionId,
    required this.prompt,
    required this.options,
    this.imageUrl,
  });

  final String questionId;
  final String prompt;
  final String? imageUrl;
  final List<QuizOption> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      questionId: json['questionId'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map(
                (e) => QuizOption.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
    );
  }
}

/// Kuis pemahaman unit, termasuk nyawa yang tersedia.
class QuizDetail {
  const QuizDetail({
    required this.quizId,
    required this.unitTitle,
    required this.questionCount,
    required this.passThreshold,
    required this.livesAvailable,
    required this.questions,
  });

  final String quizId;
  final String unitTitle;
  final int questionCount;
  final int passThreshold;
  final int livesAvailable;
  final List<QuizQuestion> questions;

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    return QuizDetail(
      quizId: json['quizId'] as String? ?? '',
      unitTitle: json['unitTitle'] as String? ?? '',
      questionCount: json['questionCount'] as int? ?? 0,
      passThreshold: json['passThreshold'] as int? ?? 0,
      livesAvailable: json['livesAvailable'] as int? ?? 0,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    QuizQuestion.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
    );
  }
}

/// Hasil submit kuis. `passed:false` adalah jawaban normal (200), bukan galat.
class QuizResult {
  const QuizResult({
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.passed,
    required this.livesSpent,
    required this.livesRemaining,
    required this.xpEarned,
    required this.unitCompleted,
    this.nextUnitId,
    this.weakTopics = const [],
  });

  final int score;
  final int correctCount;
  final int totalCount;
  final bool passed;
  final int livesSpent;
  final int livesRemaining;
  final int xpEarned;
  final bool unitCompleted;
  final String? nextUnitId;
  final List<String> weakTopics;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      livesSpent: json['livesSpent'] as int? ?? 0,
      livesRemaining: json['livesRemaining'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      unitCompleted: json['unitCompleted'] as bool? ?? false,
      nextUnitId: json['nextUnitId'] as String?,
      weakTopics:
          (json['weakTopics'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}

/// Sesi ujian akhir yang sedang berjalan (hasil start).
class FinalTestDetail {
  const FinalTestDetail({
    required this.attemptId,
    required this.questions,
    this.startedAt,
    this.expiresAt,
  });

  final String attemptId;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final List<QuizQuestion> questions;

  factory FinalTestDetail.fromJson(Map<String, dynamic> json) {
    return FinalTestDetail(
      attemptId: json['attemptId'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    QuizQuestion.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
    );
  }
}

/// Hasil submit ujian akhir. `passed:false` adalah jawaban normal (200).
class FinalTestResult {
  const FinalTestResult({
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.passed,
    required this.stars,
    required this.xpEarned,
    required this.levelCompleted,
    this.nextLevelId,
    this.badgeEarned,
    this.celebration,
    this.cooldownUntil,
    this.attemptsRemaining = 0,
    this.weakTopics = const [],
  });

  final int score;
  final int correctCount;
  final int totalCount;
  final bool passed;
  final int stars;
  final int xpEarned;
  final bool levelCompleted;
  final String? nextLevelId;
  final String? badgeEarned;
  final String? celebration;
  final DateTime? cooldownUntil;
  final int attemptsRemaining;
  final List<String> weakTopics;

  factory FinalTestResult.fromJson(Map<String, dynamic> json) {
    return FinalTestResult(
      score: json['score'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      passed: json['passed'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
      levelCompleted: json['levelCompleted'] as bool? ?? false,
      nextLevelId: json['nextLevelId'] as String?,
      badgeEarned: json['badgeEarned'] as String?,
      celebration: json['celebration'] as String?,
      cooldownUntil: DateTime.tryParse(json['cooldownUntil'] as String? ?? ''),
      attemptsRemaining: json['attemptsRemaining'] as int? ?? 0,
      weakTopics:
          (json['weakTopics'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}

/// Satu aset dalam paket unduhan luring.
class BundleAsset {
  const BundleAsset({
    required this.kind,
    required this.url,
    required this.bytes,
  });

  final String kind;
  final String url;
  final int bytes;

  factory BundleAsset.fromJson(Map<String, dynamic> json) {
    return BundleAsset(
      kind: json['kind'] as String? ?? '',
      url: json['url'] as String? ?? '',
      bytes: json['bytes'] as int? ?? 0,
    );
  }
}

/// Paket unduhan luring satu unit (gambar + video, embed dilewati).
class UnitBundle {
  const UnitBundle({
    required this.unitId,
    required this.totalBytes,
    required this.assets,
    required this.skippedEmbedCount,
  });

  final String unitId;
  final int totalBytes;
  final List<BundleAsset> assets;
  final int skippedEmbedCount;

  factory UnitBundle.fromJson(Map<String, dynamic> json) {
    return UnitBundle(
      unitId: json['unitId'] as String? ?? '',
      totalBytes: json['totalBytes'] as int? ?? 0,
      assets:
          (json['assets'] as List<dynamic>?)
              ?.map(
                (e) => BundleAsset.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          const [],
      skippedEmbedCount: json['skippedEmbedCount'] as int? ?? 0,
    );
  }
}

/// Hasil menandai lesson selesai.
class LessonCompletion {
  const LessonCompletion({
    required this.lessonId,
    required this.xpEarned,
    required this.totalXp,
    required this.streakDays,
    required this.streakExtended,
    required this.unitCompleted,
    required this.levelCompleted,
    this.nextLessonId,
  });

  final String lessonId;
  final int xpEarned;
  final int totalXp;
  final int streakDays;
  final bool streakExtended;
  final String? nextLessonId;
  final bool unitCompleted;
  final bool levelCompleted;

  factory LessonCompletion.fromJson(Map<String, dynamic> json) {
    return LessonCompletion(
      lessonId: json['lessonId'] as String? ?? '',
      xpEarned: json['xpEarned'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      streakExtended: json['streakExtended'] as bool? ?? false,
      nextLessonId: json['nextLessonId'] as String?,
      unitCompleted: json['unitCompleted'] as bool? ?? false,
      levelCompleted: json['levelCompleted'] as bool? ?? false,
    );
  }
}

/// Repository Kelas Tandur. Semua method melempar ApiException yang sudah
/// ternormalisasi (lihat CATATAN_FE_FLUTTER.md 3.4).
class LearningRepository {
  LearningRepository(this._dio);

  final Dio _dio;

  /// Peta pembelajaran + stats gamifikasi (bagian 3.1).
  Future<LearningMap> getMap({String? commodity}) async {
    final res = await guardApi(
      () =>
          _dio.get('/learning/map', queryParameters: {'commodity': ?commodity}),
    );
    return LearningMap.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Detail petak: unit + ujian akhir (bagian 3.1).
  Future<LevelDetail> getLevel(String id) async {
    final res = await guardApi(() => _dio.get('/learning/levels/$id'));
    return LevelDetail.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Daftar materi dan kuis sebuah unit (bagian 3.1).
  Future<UnitLessons> getUnitLessons(String id) async {
    final res = await guardApi(() => _dio.get('/learning/units/$id/lessons'));
    return UnitLessons.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Lesson CARD atau VIDEO (bagian 3.2).
  Future<LessonDetail> getLesson(String id) async {
    final res = await guardApi(() => _dio.get('/learning/lessons/$id'));
    return LessonDetail.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Simpan posisi terakhir video (bagian 3.2).
  Future<void> saveVideoPosition(String id, int positionSeconds) async {
    await guardApi(
      () => _dio.post(
        '/learning/lessons/$id/position',
        data: {'positionSeconds': positionSeconds},
      ),
    );
  }

  /// Tandai lesson selesai dan terima XP (bagian 3.2).
  Future<LessonCompletion> completeLesson(
    String id, {
    required int watchedPercent,
    int? durationSeconds,
  }) async {
    final res = await guardApi(
      () => _dio.post(
        '/learning/lessons/$id/complete',
        data: {
          'watchedPercent': watchedPercent,
          'durationSeconds': ?durationSeconds,
        },
      ),
    );
    return LessonCompletion.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Paket unduhan luring satu unit (bagian 3.2).
  Future<UnitBundle> getUnitBundle(String id) async {
    final res = await guardApi(() => _dio.get('/learning/units/$id/bundle'));
    return UnitBundle.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Soal latihan sebuah lesson bertipe EXERCISE_* (bagian 3.3).
  Future<ExerciseDetail> getExercise(String lessonId) async {
    final res = await guardApi(() => _dio.get('/learning/exercises/$lessonId'));
    return ExerciseDetail.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Kirim jawaban latihan untuk dinilai (bagian 3.3).
  Future<ExerciseResult> submitExercise(
    String lessonId, {
    required List<Map<String, dynamic>> answers,
    int? durationSeconds,
  }) async {
    final res = await guardApi(
      () => _dio.post(
        '/learning/exercises/$lessonId/submit',
        data: {'answers': answers, 'durationSeconds': ?durationSeconds},
      ),
    );
    return ExerciseResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Kuis pemahaman unit (bagian 3.3).
  Future<QuizDetail> getQuiz(String id) async {
    final res = await guardApi(() => _dio.get('/learning/quizzes/$id'));
    return QuizDetail.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Kirim jawaban kuis. Gagal lulus dikembalikan sebagai [QuizResult] biasa
  /// dengan `passed:false`, bukan galat (bagian 3.3).
  Future<QuizResult> submitQuiz(
    String id, {
    required List<Map<String, dynamic>> answers,
  }) async {
    final res = await guardApi(
      () =>
          _dio.post('/learning/quizzes/$id/submit', data: {'answers': answers}),
    );
    return QuizResult.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Mulai ujian akhir dan terima sesi bertenggat (bagian 3.3).
  Future<FinalTestDetail> startFinalTest(String id) async {
    final res = await guardApi(
      () => _dio.post('/learning/final-tests/$id/start'),
    );
    return FinalTestDetail.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Kirim jawaban ujian akhir. Gagal lulus dikembalikan sebagai
  /// [FinalTestResult] biasa dengan `passed:false` (bagian 3.3).
  Future<FinalTestResult> submitFinalTest(
    String id, {
    required String attemptId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final res = await guardApi(
      () => _dio.post(
        '/learning/final-tests/$id/submit',
        data: {'attemptId': attemptId, 'answers': answers},
      ),
    );
    return FinalTestResult.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(ref.watch(dioProvider));
});
