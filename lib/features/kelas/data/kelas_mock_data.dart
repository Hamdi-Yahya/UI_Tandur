enum TerraceNodeStatus {
  locked,
  available,
  inProgress,
  completed,
  perfect,
}

class TerraceNode {
  final String id;
  final String title;
  final String code;
  final TerraceNodeStatus status;
  final double progress; // 0.0 to 1.0

  const TerraceNode({
    required this.id,
    required this.title,
    required this.code,
    required this.status,
    this.progress = 0.0,
  });
}

class KelasMockData {
  // Gamification Stats
  static const int currentXp = 1240;
  static const int currentStreak = 12;
  static const int currentLives = 5;

  // Learning Map Nodes (Cabai)
  // Judul dibuat singkat sesuai label pada peta isometrik di desain.
  static const List<TerraceNode> cabaiNodes = [
    TerraceNode(
      id: 'c1',
      title: 'Persiapan',
      code: 'C1',
      status: TerraceNodeStatus.completed,
      progress: 1.0,
    ),
    TerraceNode(
      id: 'c2',
      title: 'Hama',
      code: 'C2',
      status: TerraceNodeStatus.inProgress,
      progress: 0.6,
    ),
    TerraceNode(
      id: 'c3',
      title: 'Panen',
      code: 'C3',
      status: TerraceNodeStatus.available,
      progress: 0.0,
    ),
    TerraceNode(
      id: 'c4',
      title: 'Tingkat Lanjut',
      code: 'C4',
      status: TerraceNodeStatus.locked,
      progress: 0.0,
    ),
  ];
  
  static const List<TerraceNode> terongNodes = [
    TerraceNode(
      id: 't1',
      title: 'Persiapan Lahan',
      code: 'T1',
      status: TerraceNodeStatus.perfect,
      progress: 1.0,
    ),
    TerraceNode(
      id: 't2',
      title: 'Perawatan Terong',
      code: 'T2',
      status: TerraceNodeStatus.inProgress,
      progress: 0.3,
    ),
  ];

  static const List<TerraceNode> padiNodes = [
    TerraceNode(
      id: 'p1',
      title: 'Pengolahan Sawah',
      code: 'P1',
      status: TerraceNodeStatus.available,
      progress: 0.0,
    ),
    TerraceNode(
      id: 'p2',
      title: 'Pemupukan Dasar',
      code: 'P2',
      status: TerraceNodeStatus.locked,
      progress: 0.0,
    ),
  ];

  // Level / Petak Detail Mock
  static LevelDetail getLevelDetail(String id) {
    if (id == 'c4') {
      return const LevelDetail(
        id: 'c4',
        title: 'Tingkat Lanjut',
        code: 'C4',
        description: 'Materi lanjutan budidaya cabai.',
        estimatedTime: '3 Jam',
        progress: 0.0,
        status: TerraceNodeStatus.locked,
        lockReason: 'Selesaikan Petak C3 (Panen & Pascapanen) terlebih dahulu untuk membuka petak ini.',
        units: [],
        finalTestStatus: FinalTestStatus.locked,
      );
    }
    
    // Default mock (like C2)
    return const LevelDetail(
      id: 'c2',
      title: 'Hama & Penyakit',
      code: 'C2',
      description: 'Kenali musuh utama cabai rawit dari kutu daun sampai patek, dan cara mencegahnya sebelum terlambat.',
      estimatedTime: '2 Jam',
      progress: 0.6,
      status: TerraceNodeStatus.inProgress,
      lockReason: null,
      units: [
        UnitSummary(
          id: 'u1',
          title: 'Hama Kutu & Serangga',
          progress: 1.0,
          status: UnitStatus.completed,
        ),
        UnitSummary(
          id: 'u2',
          title: 'Penyakit Jamur & Virus',
          progress: 0.2,
          status: UnitStatus.inProgress,
        ),
        UnitSummary(
          id: 'u3',
          title: 'Pencegahan Rutin',
          progress: 0.0,
          status: UnitStatus.locked,
        ),
      ],
      finalTestStatus: FinalTestStatus.locked,
    );
  }
}

enum UnitStatus {
  locked,
  available,
  inProgress,
  completed,
}

enum FinalTestStatus {
  locked,
  available,
  completed,
}

class UnitSummary {
  final String id;
  final String title;
  final double progress;
  final UnitStatus status;

  const UnitSummary({
    required this.id,
    required this.title,
    required this.progress,
    required this.status,
  });
}

class LevelDetail {
  final String id;
  final String title;
  final String code;
  final String description;
  final String estimatedTime;
  final double progress;
  final TerraceNodeStatus status;
  final String? lockReason;
  final List<UnitSummary> units;
  final FinalTestStatus finalTestStatus;

  const LevelDetail({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.estimatedTime,
    required this.progress,
    required this.status,
    this.lockReason,
    required this.units,
    required this.finalTestStatus,
  });
}

enum LessonType {
  video,
  kartu,
  latihan,
}

enum LessonStatus {
  locked,
  available,
  completed,
}

class LessonSummary {
  final String id;
  final String title;
  final LessonType type;
  final String duration;
  final LessonStatus status;

  /// XP yang didapat bila materi diselesaikan. 0 berarti tidak ditampilkan.
  final int xpReward;

  const LessonSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.status,
    this.xpReward = 0,
  });
}

class UnitDetail {
  final String id;
  final String title;
  final String description;
  final List<LessonSummary> lessons;
  final FinalTestStatus quizStatus; // Unit quiz
  
  const UnitDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
    required this.quizStatus,
  });

  static UnitDetail getMock(String id) {
    return const UnitDetail(
      id: 'u2',
      title: 'Penyakit Jamur & Virus',
      description: 'Kenali dan basmi penyakit yang sering menyerang daun dan batang cabai.',
      quizStatus: FinalTestStatus.locked,
      lessons: [
        LessonSummary(
          id: 'l1',
          title: 'Mengenal Patek (Antraknosa)',
          type: LessonType.video,
          duration: '3:45',
          status: LessonStatus.completed,
        ),
        LessonSummary(
          id: 'l2',
          title: 'Gejala Virus Kuning',
          type: LessonType.kartu,
          duration: '4 Kartu',
          status: LessonStatus.available,
        ),
        LessonSummary(
          id: 'l3',
          title: 'Cara Pembuatan Fungisida Alami',
          type: LessonType.video,
          duration: '5:12',
          status: LessonStatus.locked,
        ),
      ],
    );
  }
}

abstract class LessonDetail {
  final String id;
  final String title;
  final LessonType type;

  const LessonDetail({
    required this.id,
    required this.title,
    required this.type,
  });

  static LessonDetail getMock(String id) {
    if (id == 'l1') {
      return const VideoLessonDetail(
        id: 'l1',
        title: 'Mengenal Patek (Antraknosa)',
        videoUrl: 'https://example.com/video.mp4',
        transcript: 'Patek atau antraknosa adalah penyakit jamur yang sangat mematikan bagi cabai. Jamur ini berkembang pesat di musim hujan. Cara pencegahannya adalah dengan memperbaiki drainase dan penyemprotan fungisida berbahan aktif propineb.',
      );
    }
    
    // Default to card lesson (like l2)
    return const CardLessonDetail(
      id: 'l2',
      title: 'Gejala Virus Kuning',
      cards: [
        LessonCardContent(
          imageUrl: 'placeholder',
          content: 'Virus kuning atau Gemini virus ditularkan oleh kutu kebul.',
        ),
        LessonCardContent(
          imageUrl: 'placeholder',
          content: 'Gejalanya ditandai dengan daun yang menguning terang dan tulang daun yang menebal.',
        ),
        LessonCardContent(
          imageUrl: 'placeholder',
          content: 'Tanaman yang terserang parah akan kerdil dan tidak menghasilkan buah.',
        ),
        LessonCardContent(
          imageUrl: 'placeholder',
          content: 'Cabut dan bakar tanaman yang terinfeksi untuk mencegah penularan.',
        ),
      ],
    );
  }
}

class VideoLessonDetail extends LessonDetail {
  final String videoUrl;
  final String transcript;

  const VideoLessonDetail({
    required super.id,
    required super.title,
    super.type = LessonType.video,
    required this.videoUrl,
    required this.transcript,
  });
}

class LessonCardContent {
  final String imageUrl;
  final String content;

  const LessonCardContent({
    required this.imageUrl,
    required this.content,
  });
}

class CardLessonDetail extends LessonDetail {
  final List<LessonCardContent> cards;

  const CardLessonDetail({
    required super.id,
    required super.title,
    super.type = LessonType.kartu,
    required this.cards,
  });
}

class ExerciseQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  const ExerciseQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class ExerciseDetail {
  final String id;
  final String title;
  final List<ExerciseQuestion> questions;

  const ExerciseDetail({
    required this.id,
    required this.title,
    required this.questions,
  });

  static ExerciseDetail getMock(String id) {
    return const ExerciseDetail(
      id: 'ex1',
      title: 'Latihan: Jamur & Virus',
      questions: [
        ExerciseQuestion(
          question: 'Apa penyebab utama penyakit patek pada cabai?',
          options: ['Virus Gemini', 'Kutu Kebul', 'Jamur Antraknosa', 'Kekurangan Air'],
          correctAnswerIndex: 2,
        ),
        ExerciseQuestion(
          question: 'Bagaimana cara mencegah penyebaran virus kuning?',
          options: ['Cabut dan bakar tanaman terinfeksi', 'Beri pupuk urea lebih banyak', 'Siram dengan air garam', 'Biarkan saja'],
          correctAnswerIndex: 0,
        ),
      ],
    );
  }
}

class QuizDetail {
  final String id;
  final String title;
  final List<ExerciseQuestion> questions;

  const QuizDetail({
    required this.id,
    required this.title,
    required this.questions,
  });

  static QuizDetail getMock(String id) {
    return const QuizDetail(
      id: 'qz1',
      title: 'Ujian: Hama & Penyakit',
      questions: [
        ExerciseQuestion(
          question: 'Serangga apa yang menjadi vektor utama virus kuning (Gemini) pada tanaman cabai?',
          options: ['Ulat grayak', 'Kutu kebul', 'Tungau merah', 'Lalat buah'],
          correctAnswerIndex: 1,
        ),
        ExerciseQuestion(
          question: 'Bercak cokelat kehitaman melingkar pada buah cabai yang sedang matang adalah gejala khas dari penyakit?',
          options: ['Patek (Antraknosa)', 'Layu Fusarium', 'Bercak Daun Cercospora', 'Busuk Phytophthora'],
          correctAnswerIndex: 0,
        ),
        ExerciseQuestion(
          question: 'Penggunaan mulsa plastik perak pada bedengan cabai paling efektif untuk mengusir hama apa?',
          options: ['Tikus', 'Bekicot', 'Kutu daun', 'Nematoda akar'],
          correctAnswerIndex: 2,
        ),
      ],
    );
  }
}

class FinalTestDetail {
  final String id;
  final String title;
  final List<ExerciseQuestion> questions;

  const FinalTestDetail({
    required this.id,
    required this.title,
    required this.questions,
  });

  static FinalTestDetail getMock(String id) {
    return const FinalTestDetail(
      id: 'ft1',
      title: 'Ujian Akhir Petak: Hama & Penyakit',
      questions: [
        ExerciseQuestion(
          question: 'Apa langkah pertama yang harus dilakukan saat melihat gejala awal serangan patek?',
          options: ['Biarkan saja', 'Petik dan buang buah yang terinfeksi jauh dari lahan', 'Siram tanaman tiap hari', 'Beri pupuk kandang'],
          correctAnswerIndex: 1,
        ),
        ExerciseQuestion(
          question: 'Penyakit layu bakteri pada cabai paling mudah dikenali dari gejala apa?',
          options: ['Daun keriting ke atas', 'Tanaman layu di siang hari dan segar kembali di pagi/sore hari', 'Buah membusuk', 'Bercak putih pada daun'],
          correctAnswerIndex: 1,
        ),
        ExerciseQuestion(
          question: 'Untuk mencegah layu fusarium, jamur antagonis apa yang disarankan untuk diaplikasikan sebelum tanam?',
          options: ['Trichoderma', 'Rhizobium', 'Mycorrhiza', 'Phytophthora'],
          correctAnswerIndex: 0,
        ),
        ExerciseQuestion(
          question: 'Pengendalian hama secara mekanis dapat dilakukan dengan cara?',
          options: ['Penyemprotan pestisida kimia', 'Pemasangan yellow sticky trap (perangkap kuning)', 'Rotasi tanaman', 'Penyiangan gulma'],
          correctAnswerIndex: 1,
        ),
      ],
    );
  }
}





class DownloadedUnit {
  final String unitId;
  final String title;
  final String petakName;
  final String size;

  const DownloadedUnit({
    required this.unitId,
    required this.title,
    required this.petakName,
    required this.size,
  });
}

class DownloadedMockData {
  static const List<DownloadedUnit> items = [
    DownloadedUnit(
      unitId: 'u1',
      title: 'Mengenal Cabai Rawit Merah',
      petakName: 'Petak 1: Persiapan',
      size: '12 MB',
    ),
    DownloadedUnit(
      unitId: 'u2',
      title: 'Penyakit Jamur & Virus',
      petakName: 'Petak 1: Persiapan',
      size: '45 MB',
    ),
  ];
}

