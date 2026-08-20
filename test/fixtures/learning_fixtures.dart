// Cuplikan respons nyata backend TANDUR (produksi Railway, 20 Agustus 2026)
// setelah kurikulum "materi" di-seed ulang. Dipakai sebagai kontrak: kalau
// backend mengubah bentuk respons, tes parsing di
// test/features/kelas/learning_models_test.dart yang gagal lebih dulu,
// bukan layar di perangkat pengguna.
//
// Cara memperbarui: panggil endpoint terkait dengan token yang sah, lalu
// tempel isi bagian data (envelope { msg, data } sudah dikupas interceptor).

/// GET /api/learning/map (tanpa filter komoditas)
const Map<String, dynamic> learningMapJson = {
  "totalXp": 0,
  "streakDays": 0,
  "lives": 5,
  "nextLifeAt": null,
  "nodes": [
    {
      "levelId": "f3b8e946-34b9-4a33-bc6f-f4be271b3395",
      "code": "C1",
      "title": "Semai & Tanam",
      "status": "AVAILABLE",
      "progressPercent": 0,
      "stars": 0,
      "shapeVariant": 2,
      "mapX": 80,
      "mapY": 620,
    },
    {
      "levelId": "8ea3cdd7-04e0-4c80-a73b-e70748cef670",
      "code": "T1",
      "title": "Terong dari Semai ke Panen",
      "status": "AVAILABLE",
      "progressPercent": 0,
      "stars": 0,
      "shapeVariant": 0,
      "mapX": 90,
      "mapY": 600,
    },
    {
      "levelId": "59ffce3e-c32c-42e6-976d-7f9077913800",
      "code": "P1",
      "title": "Padi Sawah Satu Musim",
      "status": "AVAILABLE",
      "progressPercent": 0,
      "stars": 0,
      "shapeVariant": 3,
      "mapX": 100,
      "mapY": 580,
    },
    {
      "levelId": "c3dd2863-2e5b-4f71-9dad-95dafb6fcf9a",
      "code": "C2",
      "title": "Rawat, Lindungi, Panen",
      "status": "LOCKED",
      "progressPercent": 0,
      "stars": 0,
      "lockReason": "Selesaikan C2 sebelumnya dulu",
      "shapeVariant": 1,
      "mapX": 250,
      "mapY": 430,
    },
  ],
};

/// GET /api/learning/levels/{id} - petak C1 Cabai
const Map<String, dynamic> levelDetailJson = {
  "levelId": "f3b8e946-34b9-4a33-bc6f-f4be271b3395",
  "code": "C1",
  "title": "Semai & Tanam",
  "description": "Dari memilih benih sampai bibit berdiri tegak di polybag. Tujuh unit, dikerjakan berurutan.",
  "estimatedMinutes": 120,
  "units": [
    {
      "unitId": "08183394-b82b-4cdb-b519-622e76062229",
      "title": "Unit 1 · Kenal Cabai Rawit",
      "lessonCount": 4,
      "completedCount": 0,
      "status": "AVAILABLE",
    },
    {
      "unitId": "67923cea-b2a2-4c35-84b1-250c2c514b74",
      "title": "Unit 2 · Memilih Benih",
      "lessonCount": 5,
      "completedCount": 0,
      "status": "LOCKED",
    },
    {
      "unitId": "221afee4-da60-427d-b098-7d0327cf5eeb",
      "title": "Unit 3 · Media & Wadah Semai",
      "lessonCount": 4,
      "completedCount": 0,
      "status": "LOCKED",
    },
    {
      "unitId": "0b97a0cb-cb85-43df-8091-61c6e7358081",
      "title": "Unit 4 · Merawat Persemaian",
      "lessonCount": 4,
      "completedCount": 0,
      "status": "LOCKED",
    },
    {
      "unitId": "6590d1dc-24ac-47c0-a10a-54cdea00923c",
      "title": "Unit 5 · Menyiapkan Rumah Tetap",
      "lessonCount": 4,
      "completedCount": 0,
      "status": "LOCKED",
    },
    {
      "unitId": "2ea04195-4e9e-41eb-9ebb-fd0b6c49fa11",
      "title": "Unit 6 · Pindah Tanam",
      "lessonCount": 4,
      "completedCount": 0,
      "status": "LOCKED",
    },
    {
      "unitId": "a4d3e3f0-6e2c-4f18-b40e-7ecc62ca89ff",
      "title": "Unit 7 · Minggu Pertama Setelah Tanam",
      "lessonCount": 4,
      "completedCount": 0,
      "status": "LOCKED",
    },
  ],
  "finalTest": {
    "testId": "e9faf9db-aaf5-4a9c-8f01-96e902733cab",
    "questionCount": 10,
    "passThreshold": 80,
    "status": "LOCKED",
    "lockReason": "Selesaikan semua unit dulu",
  },
};

/// GET /api/learning/units/{id}/lessons - Unit 1
const Map<String, dynamic> unitLessonsJson = {
  "unitId": "08183394-b82b-4cdb-b519-622e76062229",
  "title": "Unit 1 · Kenal Cabai Rawit",
  "progressPercent": 0,
  "lessons": [
    {
      "lessonId": "088df04b-162f-4ba2-9d25-618d900cf6e1",
      "type": "CARD",
      "title": "Mulai dari 30 polybag, bukan dari sawah",
      "estimatedMinutes": 4,
      "durationSeconds": null,
      "xpReward": 10,
      "status": "AVAILABLE",
      "order": 1,
      "isOfflineCapable": true,
    },
    {
      "lessonId": "f58da386-5d01-4310-b18a-05898fc6f00e",
      "type": "CARD",
      "title": "Siklus 90 hari: apa yang terjadi di tiap fase",
      "estimatedMinutes": 4,
      "durationSeconds": null,
      "xpReward": 10,
      "status": "LOCKED",
      "order": 2,
      "isOfflineCapable": true,
    },
    {
      "lessonId": "35e444ea-c0fc-4403-a564-fc85bbedf266",
      "type": "VIDEO",
      "title": "Menonton satu siklus penuh cabai di polybag",
      "estimatedMinutes": 11,
      "durationSeconds": null,
      "xpReward": 15,
      "status": "LOCKED",
      "order": 3,
      "isOfflineCapable": false,
    },
    {
      "lessonId": "34415f13-506f-4579-99ac-44f0079c578d",
      "type": "EXERCISE_MCQ",
      "title": "Latihan · Mengenal cabai rawit",
      "estimatedMinutes": 3,
      "durationSeconds": null,
      "xpReward": 25,
      "status": "LOCKED",
      "order": 4,
      "isOfflineCapable": true,
    },
  ],
  "quiz": null,
};

/// GET /api/learning/lessons/{id} - tipe CARD
const Map<String, dynamic> lessonCardJson = {
  "lessonId": "088df04b-162f-4ba2-9d25-618d900cf6e1",
  "type": "CARD",
  "title": "Mulai dari 30 polybag, bukan dari sawah",
  "xpReward": 10,
  "nextLessonId": "f58da386-5d01-4310-b18a-05898fc6f00e",
  "blocks": [
    {"text": "Kenapa 30 polybag sudah cukup", "type": "HEADING"},
    {
      "text": "Tiga puluh polybag cabai rawit butuh lahan sekitar 3 x 4 meter dan modal di kisaran Rp300 ribu untuk benih, media, polybag, dan pupuk. Kalau gagal, yang hilang segitu. Kalau berhasil, satu tanaman sehat bisa memberi 0,5 sampai 1 kg cabai sepanjang masa panen.",
      "type": "PARAGRAPH",
    },
    {
      "text": "Jumlah segitu juga masih bisa disiram dan diperiksa satu per satu tiap hari. Ini penting: cabai gagal biasanya bukan karena kurang pupuk, tapi karena masalah kecil tidak ketahuan sejak awal.",
      "type": "PARAGRAPH",
    },
    {
      "text": "Polybag butuh sinar matahari langsung minimal 6 jam sehari. Halaman yang teduh sepanjang hari lebih baik dipakai untuk hal lain.",
      "type": "CALLOUT",
      "title": "Ukur dulu tempatnya",
      "variant": "TIP",
    },
    {
      "text": "Menanam 200 polybag di percobaan pertama. Yang terjadi biasanya bukan panen besar, tapi 200 tanaman yang sama-sama tidak terurus.",
      "type": "CALLOUT",
      "title": "Sering keliru",
      "variant": "MISTAKE",
    },
  ],
  "sourceReference": "Balitsa, Petunjuk Teknis Budidaya Cabai Rawit",
  "reviewedBy": "Tim Kurikulum Tandur",
};

/// GET /api/learning/lessons/{id} - tipe VIDEO (embed YouTube)
const Map<String, dynamic> lessonVideoJson = {
  "lessonId": "35e444ea-c0fc-4403-a564-fc85bbedf266",
  "type": "VIDEO",
  "title": "Menonton satu siklus penuh cabai di polybag",
  "xpReward": 15,
  "nextLessonId": "34415f13-506f-4579-99ac-44f0079c578d",
  "videoKind": "EMBED",
  "youtubeVideoId": "Bi6HHvO29gw",
  "attribution": "Sumber: ook tani 93 (YouTube)",
  "isOfflineCapable": false,
};

/// GET /api/learning/exercises/{lessonId}
const Map<String, dynamic> exerciseJson = {
  "lessonId": "34415f13-506f-4579-99ac-44f0079c578d",
  "questions": [
    {
      "exerciseId": "6dbbff33-fe84-4d1b-8c11-44aaca02ce51",
      "prompt":
          "Berapa lama benih cabai biasanya mulai berkecambah setelah disemai?",
      "imageUrl": null,
      "options": [
        {"key": "A", "text": "1 sampai 2 hari"},
        {"key": "B", "text": "5 sampai 7 hari"},
        {"key": "C", "text": "20 sampai 25 hari"},
      ],
      "order": 1,
    },
    {
      "exerciseId": "da798cd5-fd13-48f9-990d-038df49e6cb9",
      "prompt":
          "Cabai mulai butuh lebih banyak fosfor dan kalium pada fase apa?",
      "imageUrl": null,
      "options": [
        {"key": "A", "text": "Fase semai"},
        {"key": "B", "text": "Fase vegetatif"},
        {"key": "C", "text": "Fase generatif saat mulai berbunga"},
      ],
      "order": 2,
    },
    {
      "exerciseId": "7cb7fb0e-8d5d-4f91-973d-6536dd5e9012",
      "prompt": "Berapa jam sinar matahari langsung minimal yang dibutuhkan cabai per hari?",
      "imageUrl": null,
      "options": [
        {"key": "A", "text": "2 jam"},
        {"key": "B", "text": "4 jam"},
        {"key": "C", "text": "6 jam"},
      ],
      "order": 3,
    },
  ],
};

/// POST /api/learning/exercises/{lessonId}/submit
const Map<String, dynamic> exerciseResultJson = {
  "score": 0,
  "correctCount": 0,
  "totalCount": 3,
  "xpEarned": 0,
  "results": [
    {
      "exerciseId": "6dbbff33-fe84-4d1b-8c11-44aaca02ce51",
      "correct": false,
      "correctAnswer": "B",
      "explanation": "Pada media dan kelembapan yang benar, kecambah muncul di hari ke-5 sampai ke-7. Kalau lewat 14 hari belum ada, benih atau medianya bermasalah.",
    },
    {
      "exerciseId": "da798cd5-fd13-48f9-990d-038df49e6cb9",
      "correct": false,
      "correctAnswer": "C",
      "explanation": "Nitrogen menumbuhkan daun. Begitu masuk fase berbunga, giliran fosfor dan kalium yang menentukan bunga jadi buah atau rontok.",
    },
    {
      "exerciseId": "7cb7fb0e-8d5d-4f91-973d-6536dd5e9012",
      "correct": false,
      "correctAnswer": "C",
      "explanation": "Di bawah 6 jam, tanaman tumbuh memanjang dan kurus, bunganya sedikit, buahnya kecil.",
    },
  ],
};
