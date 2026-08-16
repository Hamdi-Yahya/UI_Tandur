/// Model data F3 Warung Tani. Nama field mengikuti camelCase di
/// SourceOfTruth/API_DOCS_NEW.md §5, siap diganti sumbernya belakangan.
library;

class Author {
  final String userId;
  final String fullName;
  final int reputation;
  final bool isVerified;

  const Author({
    required this.userId,
    required this.fullName,
    this.reputation = 0,
    this.isVerified = false,
  });
}

class AttachedScan {
  final String scanId;
  final String? label;
  final String status;
  final int daysAfterPlanting;

  const AttachedScan({
    required this.scanId,
    this.label,
    required this.status,
    required this.daysAfterPlanting,
  });
}

class Question {
  final String questionId;
  final String title;
  final String body;
  final String commodity; // CABAI, TERONG, PADI, atau UMUM
  final List<String> tags;
  final String? district;
  final Author author;
  final int score;
  final int myVote;
  final int replyCount;
  final bool hasBestAnswer;
  final bool isAnswered;
  final DateTime createdAt;
  final AttachedScan? attachedScan;
  final List<String> photos;

  const Question({
    required this.questionId,
    required this.title,
    required this.body,
    required this.commodity,
    this.tags = const [],
    this.district,
    required this.author,
    this.score = 0,
    this.myVote = 0,
    this.replyCount = 0,
    this.hasBestAnswer = false,
    this.isAnswered = false,
    required this.createdAt,
    this.attachedScan,
    this.photos = const [],
  });

  Question copyWith({int? score, int? myVote}) => Question(
        questionId: questionId,
        title: title,
        body: body,
        commodity: commodity,
        tags: tags,
        district: district,
        author: author,
        score: score ?? this.score,
        myVote: myVote ?? this.myVote,
        replyCount: replyCount,
        hasBestAnswer: hasBestAnswer,
        isAnswered: isAnswered,
        createdAt: createdAt,
        attachedScan: attachedScan,
        photos: photos,
      );
}

class Reply {
  final String replyId;
  final String? parentId;
  final String body;
  final Author author;
  final int score;
  final int myVote;
  final int depth;
  final bool isBestAnswer;
  final List<Reply> children;
  final DateTime createdAt;

  const Reply({
    required this.replyId,
    this.parentId,
    required this.body,
    required this.author,
    this.score = 0,
    this.myVote = 0,
    this.depth = 0,
    this.isBestAnswer = false,
    this.children = const [],
    required this.createdAt,
  });
}

enum QuestionSort { newest, top, active, unanswered }

class WarungMockData {
  static const _reza = Author(userId: 'u1', fullName: 'Reza P', reputation: 42);
  static const _dimas = Author(userId: 'u2', fullName: 'Dimas W', reputation: 1240, isVerified: true);
  static const _bagas = Author(userId: 'u3', fullName: 'Bagas', reputation: 88);
  static const _sari = Author(userId: 'u4', fullName: 'Sari', reputation: 15);
  static const _nuraini = Author(userId: 'u5', fullName: 'Nuraini', reputation: 210);

  static final List<Question> questions = [
    Question(
      questionId: 'q1',
      title: 'Daun cabai keriting tapi tidak ada kutunya, kenapa?',
      body:
          'Cabai saya HST 30, daun mudanya keriting ke atas. Sudah saya cek bawah daun, tidak ada kutu '
          'atau serangga yang terlihat. Apa penyebabnya?',
      commodity: 'CABAI',
      tags: const ['hama'],
      district: 'Grobogan',
      author: _reza,
      score: 24,
      replyCount: 14,
      hasBestAnswer: true,
      isAnswered: true,
      createdAt: DateTime(2026, 8, 11, 0, 12),
      photos: const ['placeholder1', 'placeholder2'],
    ),
    Question(
      questionId: 'q2',
      title: 'Terong berbunga tapi rontok semua sebelum jadi buah',
      body: 'Sudah dua minggu bunga terong selalu rontok sebelum jadi buah. Apa yang salah?',
      commodity: 'TERONG',
      tags: const ['budidaya'],
      district: 'Grobogan',
      author: _nuraini,
      score: 8,
      replyCount: 5,
      createdAt: DateTime(2026, 8, 10, 22, 0),
    ),
    Question(
      questionId: 'q3',
      title: 'Pupuk kandang ayam boleh langsung dipakai?',
      body: 'Baru dapat pupuk kandang ayam segar, boleh langsung ditabur atau harus difermentasi dulu?',
      commodity: 'UMUM',
      tags: const ['pupuk'],
      author: _bagas,
      score: 3,
      replyCount: 0,
      createdAt: DateTime(2026, 8, 11, 3, 40),
    ),
  ];

  static Question questionById(String id) => questions.firstWhere((q) => q.questionId == id, orElse: () => questions.first);

  static List<Reply> repliesFor(String questionId) => [
        Reply(
          replyId: 'r1',
          body:
              'Kalau keritingnya ke atas dan daun mudanya yang kena, itu ciri trips, bukan kutu daun. Trips '
              'ukurannya sangat kecil, sulit terlihat mata telanjang.',
          author: _dimas,
          score: 31,
          isBestAnswer: true,
          createdAt: DateTime(2026, 8, 11, 1, 0),
        ),
        Reply(
          replyId: 'r2',
          body: 'Punya saya juga begitu, ternyata benar trips.',
          author: _bagas,
          score: 5,
          createdAt: DateTime(2026, 8, 11, 2, 0),
          children: [
            Reply(
              replyId: 'r3',
              parentId: 'r2',
              body: 'Pakai apa nanganinya?',
              author: _sari,
              score: 2,
              depth: 1,
              createdAt: DateTime(2026, 8, 11, 2, 30),
              children: [
                Reply(
                  replyId: 'r4',
                  parentId: 'r3',
                  body: 'Pestisida nabati dari daun mimba bisa dicoba.',
                  author: _nuraini,
                  score: 4,
                  depth: 2,
                  createdAt: DateTime(2026, 8, 11, 3, 0),
                ),
              ],
            ),
          ],
        ),
      ];

  static const publicProfile = (
    author: _dimas,
    verifiedNote: 'Mahasiswa Agroteknologi UNS',
    bestAnswerCount: 18,
    questionCount: 4,
    replyCount: 92,
    topCommodities: ['CABAI', 'TERONG'],
  );

  static const tags = [
    (tag: 'hama', count: 142),
    (tag: 'pupuk', count: 98),
    (tag: 'benih', count: 54),
    (tag: 'panen', count: 31),
  ];
}
