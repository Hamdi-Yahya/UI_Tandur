# API Documentation — TANDUR

| | |
|---|---|
| **Versi** | 3.2 |
| **Perubahan 3.2** | Lihat blok "Ringkasan Perubahan 3.2" tepat di bawah tabel ini |
| **Perubahan 3.1** | Lihat blok "Ringkasan Perubahan 3.1". Semua baris yang berubah diberi penanda `[UBAH v3.1]` |
| **Base URL** | `https://api.tandur.id` |
| **Prefix** | Semua endpoint diawali `/api` |
| **Format** | JSON, `camelCase` |
| **Auth** | `Authorization: Bearer <accessToken>` |
| **Dokumen terkait** | `PRD.md`, `DESAIN.md` |

---

## Ringkasan Perubahan 3.2

Ditulis 16 Agustus 2026 setelah model Terong v1.0.0 dan Padi v1.0.0 selesai dilatih dan diukur. Dasarnya ada di `PRD.md` bagian **7.3.2** dan **7.3.3**.

**A. Tiga model sekarang lengkap, dan ketiganya berbeda.** Inilah alasan manifes dibuat per komoditas.

| Komoditas | `labels` (urutan adalah kontrak) | `inputSize` | `confidenceThreshold` | `healthyConfidenceThreshold` | Akurasi uji |
|---|---|---|---|---|---|
| `CABAI` | `["BERCAK_DAUN","SEHAT","VIRUS_KUNING_KERITING"]` | 224 | 0.70 | **0.85** | 90,16 persen |
| `TERONG` | `["SEHAT","HAMA_SERANGGA","BERCAK_DAUN","VIRUS_MOSAIK","DAUN_KERDIL","EMBUN_TEPUNG_PUTIH","LAYU"]` | 224 | 0.70 | **0.90** | 86,27 persen |
| `PADI` | `["BERCAK_COKELAT","BLAS_DAUN","SEHAT"]` | **320** | 0.70 | **0.90** | 90,89 persen |

**B. Dua medan yang sebelumnya boleh dianggap tetap sekarang wajib dibaca dari manifes.**

```
inputSize                  : 224 untuk semua  ->  224 atau 320, bergantung komoditas
healthyConfidenceThreshold : 0.85 untuk semua ->  0.85 atau 0.90, bergantung komoditas
```

Menanam salah satu angka ini di kode klien menyebabkan kegagalan diam-diam. Foto padi yang diperkecil ke 224 akan tetap menghasilkan angka keyakinan yang tampak wajar, tetapi labelnya bisa salah, dan tidak ada galat yang muncul.

**C. `sha256` dan `bytes` wajib diverifikasi setelah pengunduhan model.** Berkas model diunduh dari CDN di luar API, sehingga integritasnya tidak dijamin oleh lapisan HTTP saja. Kalau sidik tidak cocok, berkas dibuang dan diunduh ulang, bukan dipakai.

**D. Padi hanya mengenali tiga kondisi.** Tungro, hispa, hawar pelepah, dan hawar daun bakteri **tidak** ada dalam model dan tidak boleh dipetakan ke label terdekat. Aturan "penyakit di luar daftar label dinyatakan apa adanya" berlaku penuh di sini.

**E. Ketiga berkas model sudah terunggah dan alamatnya final.** Disimpan di Supabase Storage, bucket `models`, bersifat publik. Awalan sama untuk ketiganya:

```
https://znsifcxggkbvpbcstawe.supabase.co/storage/v1/object/public/
```

| Komoditas | Sisa alamat (`fileUrl`) | `sha256` | `bytes` |
|---|---|---|---|
| `CABAI` | `models/cabai/cabai_v100_fp16.tflite` | `0c8b84f896736fb0b63645ef60585f1b528e46137d524919802620e5a74facc5` | 5996812 |
| `TERONG` | `models/terong/terong_v100_fp16.tflite` | `3c301079ce022e89d46a467fdeb4a059b480200507699ea0b1aa5e009d54f748` | 5995556 |
| `PADI` | `models/padi/padi_v100_fp16.tflite` | `c8ab7da9e5d4387c6b1befc737252f3d470e834e370916a16df4bf379aa8c5ab` | 5987608 |

Ketiga sidik di atas sudah diverifikasi dengan mengunduh ulang berkasnya dari alamat publik tersebut, bukan disalin dari catatan pelatihan. Alamat `cdn.tandur.id` yang muncul pada contoh respons di bagian 4.2 adalah contoh lama dan **tidak pernah ada**; pakai tabel ini.

Versi model tertulis di nama berkas, bukan di jalur folder. Rilis berikutnya bernama `cabai_v110_fp16.tflite` dan seterusnya, sehingga alamatnya berbeda dan cache di perangkat tidak mungkin menyajikan model lama.

**F. Angka akurasi cabai berdiri di atas set uji yang kecil.** Cabai diuji pada 61 foto, terong pada 204, padi pada 417. Pada 61 sampel, selisih satu foto menggeser persentase lebih dari satu poin, jadi 90,16 persen tidak sebanding langsung dengan 90,89 persen milik padi. Manifes cabai juga memuat `note` bahwa modelnya belum diuji pada foto lapangan asli — seluruh datanya foto daun tunggal berlatar polos. Angka-angka ini tidak boleh dipajang sebagai jaminan mutu di layar pengguna.

**G. Layanan AI sudah berjalan, dan ini kontraknya.** Ini satu-satunya endpoint yang dipanggil backend ke layanan AI. Bukan endpoint publik — aplikasi tidak boleh memanggilnya langsung.

```
POST  https://tandur-ai-production.up.railway.app/internal/rag/answer
Authorization: Bearer <AI_SERVICE_SHARED_SECRET>
Content-Type: application/json
```

Rahasia bersamanya dikirim ke backend di luar dokumen ini, tidak lewat obrolan grup dan tidak lewat repositori.

Alamat di atas sudah hidup dan sudah diuji ujung ke ujung pada 18 Agustus 2026: permintaan contoh di bawah menghasilkan `200` dengan `grounded: true` dan satu sitasi bernomor halaman, dalam 6 detik.

**Badan permintaan.** Hanya `question` yang wajib.

| Medan | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `question` | string, 1–1000 | ya | Pertanyaan pengguna apa adanya. Jangan disisipi hasil pindai |
| `commodity` | `"CABAI"` \| `"TERONG"` \| `"PADI"` \| null | tidak | Menyempitkan pencarian; potongan lintas-komoditas tetap ikut |
| `scanLabel` | string \| null | tidak | Label mentah hasil pindai, misalnya `VIRUS_KUNING_KERITING` |
| `discussionId` | string \| null | tidak | Ikut tercatat di `LlmCallLog` untuk penelusuran |
| `history` | array `{role, content}` | tidak | Enam pesan terakhir. Lebih dari itu dipangkas oleh layanan |

**Badan respons.**

```json
{
  "answer": "Virus kuning keriting memang merugikan kalau dibiarkan...",
  "citations": [
    {"title": "Hama dan Penyakit pada Tanaman Cabai serta Pengendaliannya",
     "publisher": "Kementerian Pertanian", "year": 2019, "page": 12,
     "url": "https://repository.pertanian.go.id/..."}
  ],
  "grounded": true,
  "provider": "omniroute",
  "usage": {"prompt_tokens": 7412, "completion_tokens": 188}
}
```

| Keadaan | Kode | Yang harus dilakukan backend |
|---|---|---|
| Terjawab | 200, `grounded: true` | Simpan `answer` dan `citations` |
| Tidak tahu | 200, `grounded: false`, `citations` kosong | **Tetap simpan dan tampilkan.** Ini jawaban jujur, bukan galat. Arahkan ke Warung Tani |
| Rahasia salah | 401 | Jangan diteruskan ke pengguna |
| Semua penyedia gagal | 503 | Pakai `ALL_PROVIDERS_FAILED` di bagian 4.3 |

**`scanLabel` bukan sekadar hiasan.** Kalau ia dikirim, layanan menaruhnya sebagai catatan keadaan terpisah untuk model, sehingga pertanyaan seperti "ini bahaya nggak?" punya rujukan. Tanpa `scanLabel`, pertanyaan itu dijawab tidak tahu — dan itu benar, karena "ini" tidak menunjuk apa pun. Yang penting: pertanyaan pengguna tidak pernah diubah isinya; hasil pindai diberikan sebagai konteks di sebelahnya.

**Jaminan sitasi bersifat mekanis, bukan sekadar imbauan di perintah.** Model diwajibkan menutup jawabannya dengan nomor potongan yang dipakai. Kode memeriksa nomor itu; kalau tidak ada atau di luar jangkauan, jawabannya dibuang dan diganti penolakan baku. Artinya `citations` yang kosong bersamaan dengan `grounded: true` tidak mungkin terjadi.

**Pemeriksaan kesehatan.** `GET https://tandur-ai-production.up.railway.app/health`, tanpa autentikasi. Balasannya `503` kalau basis data tidak terjangkau atau korpusnya kosong, jadi aman dipakai sebagai Healthcheck Path.

```json
{"status":"ok","database":"ok","korpus":"193 potongan","llm":"1 penyedia terkonfigurasi"}
```

---

## Ringkasan Perubahan 3.1

Ditulis 14 Agustus 2026 setelah model Cabai v1.0.0 selesai dilatih dan diukur. **Baca blok ini saja, tidak perlu membaca ulang seluruh dokumen.** Setiap baris yang berubah di bawah diberi penanda `[UBAH v3.1]` sehingga bisa dicari dengan Ctrl+F.

Dasar seluruh perubahan ada di `PRD.md` bagian **7.3.1**, yang berisi angka hasil pengukurannya.

**A. Daftar label model dipangkas dari 10 menjadi 3.** Berlaku untuk Cabai.

```
sebelum : SEHAT, ANTRAKNOSA, BERCAK_DAUN_CERCOSPORA, LAYU_FUSARIUM, KUTU_KEBUL,
          TRIPS, VIRUS_KUNING_KERITING, DEFISIENSI_N, DEFISIENSI_K, TIDAK_TERIDENTIFIKASI
sesudah : BERCAK_DAUN, SEHAT, VIRUS_KUNING_KERITING
```

Alasannya: dari 6 dataset cabai yang disurvei, hanya satu yang layak, dan isinya 3 kelas. Tujuh label sisanya tidak punya data sama sekali sehingga tidak mungkin dilatih. **Urutan abjad di atas adalah kontrak** — TFLite mengembalikan indeks, bukan nama, jadi urutan yang berbeda di klien membuat hasilnya tertukar tanpa memunculkan galat apa pun.

**B. `ANTRAKNOSA` dihapus dari seluruh alur pindai.** Gejalanya ada di buah sedangkan semua dataset layak adalah penyakit daun. Dua dataset antraknosa sudah diuji dan ditolak, alasannya tercatat di `PRD.md` bagian 7.3.

> **Antraknosa tetap boleh muncul di materi Kelas Tandur, di basis pengetahuan RAG, dan di jawaban asisten.** Penyakitnya nyata dan penting bagi petani cabai. Yang tidak bisa hanya **mendeteksinya dari foto**. Karena itu contoh di bagian 3 dan dokumen basis pengetahuan di bagian 7 sengaja **tidak** diubah. Yang diubah hanya contoh di bagian 4, karena di sana `ANTRAKNOSA` dipakai sebagai label keluaran model — dan label itu tidak ada.

**C. Kuantisasi INT8 diganti FLOAT16.** INT8 penuh sudah diuji dan menjatuhkan akurasi dari 90,2 ke 59,0 persen. Lebih berbahaya lagi, model INT8 memvonis `SEHAT` sebanyak 30 kali padahal kebenarannya hanya 14, artinya banyak daun sakit dinyatakan sehat. FLOAT16 berukuran 6,00 MB, masih di bawah anggaran 8 MB, dan tidak kehilangan akurasi sama sekali.

**D. Ambang keyakinan naik, dan sekarang tidak simetris.**

```
umum          : 0.60  ->  0.70
vonis SEHAT   :   -   ->  0.85   (field baru: healthyConfidenceThreshold)
```

Ambang `SEHAT` sengaja dibuat lebih ketat karena akibat dua jenis kesalahan tidak setara. Salah menyatakan sakit padahal sehat hanya membuat pengguna memotret ulang. Salah menyatakan sehat padahal sakit membuat pengguna kehilangan satu musim.

**E. Aturan "tiga dugaan teratas" diganti.** Menjadi: **tampilkan setiap dugaan dengan keyakinan di atas 0,10, maksimal tiga.** Dengan model 3 kelas, "tiga teratas" berarti menampilkan seluruh isi model dan tidak menyampaikan informasi apa pun.

**F. Field baru di manifest: `inputDtype`.** Nilainya `"float32"`, konsekuensi dari pindah ke FLOAT16. Klien mengirim piksel mentah 0 sampai 255 sebagai `float32`. Normalisasi tetap berada di dalam model, klien tidak perlu melakukannya. Ini satu baris berbeda di Flutter, tetapi kalau terlewat hasilnya ngawur tanpa galat.

### Daftar baris yang berubah

| Bagian | Endpoint | Yang berubah |
|---|---|---|
| 4.1 | Get My Plants, Get Plant Detail | contoh `lastDiagnosis` dan `patterns.label` |
| 4.2 | **Get Model Manifest** | **kontrak sesungguhnya**: `version`, `fileUrl`, `bytes`, `quantization`, `labels`, `confidenceThreshold`, `healthyConfidenceThreshold`, `inputDtype` |
| 4.2 | Save Scan, Save Low Confidence Scan | label contoh, aturan ambang, aturan jumlah dugaan |
| 4.2 | Get Scan, Get Scan Timeline, Flag Wrong Result | label contoh |
| 4.3 | Start Discussion | `context.diagnosis` |
| 7 | Scan Flag Queue, Model Metrics, Publish Model Version | label contoh dan field ambang |

### Yang belum bisa diselesaikan di dokumen ini

Tiga hal berikut ada di sisi backend, bukan di dokumen ini, dan masih menunggu:

1. ~~**`RagChunk` belum punya kolom `page`.**~~ **SELESAI** — kolom `page` dan `heading` sudah ada dan sudah terisi untuk seluruh 193 potongan. Tidak ada `ALTER TABLE` yang perlu dijalankan. Teks aslinya: Format sitasi di bagian 4.3 mensyaratkan `{title, publisher, year, page, url}`. Title, publisher, year, dan url bisa diambil dari join ke `RagDocument`, tetapi `page` tidak ada sumbernya sehingga setiap sitasi keluar `page: null`. Perlu `ALTER TABLE "RagChunk" ADD COLUMN "page" INTEGER, ADD COLUMN "heading" TEXT;`
2. ~~**Payload `/internal/rag/answer` belum membawa riwayat percakapan.**~~ **SELESAI di sisi layanan AI** — endpointnya sudah menerima `history`, dan juga `scanLabel` serta `discussionId`. Yang tersisa: backend harus benar-benar mengirimkannya. Kontrak lengkapnya ada di bagian **G** di atas. Teks aslinya: Akibatnya pertanyaan lanjutan seperti "berapa lama sampai pulih?" kehilangan konteks, padahal `suggestedPrompts` kita sendiri yang memancing pertanyaan seperti itu. Perlu tambahan `history` berisi enam pesan terakhir.
3. **Konteks cuaca 7 hari sudah dicoret dari PRD** karena tidak pernah punya sumber data. Bagian 4.3 tidak menyebutnya, jadi tidak ada yang perlu diubah di sini, hanya perlu diketahui agar tidak ditambahkan kembali.

---

## Konvensi

**Envelope respons**

```json
{ "msg": "Pesan singkat", "data": { } }
```

**Kode HTTP**

| Kode | Arti |
|---|---|
| 200 | Berhasil |
| 201 | Data dibuat |
| 202 | Diterima, diproses asinkron |
| 400 | Validasi gagal |
| 401 | Token tidak valid atau kedaluwarsa |
| 403 | Peran tidak berhak |
| 404 | Tidak ditemukan |
| 409 | Konflik, duplikat atau status tidak sesuai |
| 422 | Aturan bisnis gagal |
| 429 | Melebihi kuota atau batas laju |
| 500 | Galat server |

**Error validasi**

```json
{
  "msg": {
    "email": ["Format email tidak valid."],
    "plantedAt": ["Tanggal tanam tidak boleh di masa depan."]
  }
}
```

**Header wajib pada semua `POST`, `PATCH`, `PUT`, `DELETE`**

```
Idempotency-Key: <uuid-v4>
```

Server menyimpan respons per kunci selama 24 jam. Kirim ulang dengan kunci yang sama mengembalikan respons tersimpan, bukan memproses ulang. Ini prasyarat mode luring, bukan opsional.

**Paginasi** memakai kursor, bukan offset.

```
GET /api/community/questions?limit=20&cursor=2026-08-11T03:00:00Z
```

```json
{ "data": { "items": [], "nextCursor": "2026-08-10T09:12:00Z" } }
```

**Enum**

| Enum | Nilai |
|---|---|
| `commodity` | `CABAI`, `TERONG`, `PADI` |
| `role` | `USER`, `MODERATOR`, `ADMIN` |
| `lessonType` | `CARD`, `VIDEO`, `EXERCISE_MCQ`, `EXERCISE_MATCH`, `EXERCISE_ORDER`, `EXERCISE_IMAGE` |
| `nodeStatus` | `LOCKED`, `AVAILABLE`, `IN_PROGRESS`, `COMPLETED`, `PERFECT` |
| `scanStatus` | `PROCESSING`, `DONE`, `LOW_CONFIDENCE`, `REJECTED` |
| `plantStatus` | `ACTIVE`, `HARVESTED`, `ENDED` |
| `questionSort` | `NEWEST`, `TOP`, `ACTIVE`, `UNANSWERED` |
| `voteValue` | `1`, `-1`, `0` (nol berarti batalkan suara) |
| `reportReason` | `SPAM`, `HARASSMENT`, `MISINFORMATION`, `OFF_TOPIC`, `OTHER` |

---

## 1. Authentication

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Sign Up | POST | `/api/auth/signup` | NONE | `{"fullName":"Reza Pratama","email":"reza@mail.com","password":"RahasiaKuat123"}` | `{"msg":"Akun dibuat","data":{"userId":"uuid","accessToken":"eyJ...","refreshToken":"eyJ...","expiresIn":3600}}` | `{"msg":{"email":["Email sudah terdaftar."],"password":["Password minimal 8 karakter."]}}` |
| Sign In | POST | `/api/auth/signin` | NONE | `{"email":"reza@mail.com","password":"RahasiaKuat123"}` | `{"msg":"Login berhasil","data":{"userId":"uuid","fullName":"Reza Pratama","roles":["USER"],"accessToken":"eyJ...","refreshToken":"eyJ...","expiresIn":3600}}` | `{"msg":"Email atau password salah."}` |
| Google Sign In | POST | `/api/auth/google` | NONE | `{"idToken":"ya29..."}` | `{"msg":"Login berhasil","data":{"userId":"uuid","isNewUser":true,"accessToken":"eyJ...","refreshToken":"eyJ...","expiresIn":3600}}` | `{"msg":"Token Google tidak valid."}` |
| Refresh Token | POST | `/api/auth/refresh` | NONE | `{"refreshToken":"eyJ..."}` | `{"msg":"Token diperbarui","data":{"accessToken":"eyJ...","expiresIn":3600}}` | `{"msg":"Refresh token tidak valid atau kedaluwarsa."}` |
| Forgot Password | POST | `/api/auth/forgot-password` | NONE | `{"email":"reza@mail.com"}` | `{"msg":"Kalau email terdaftar, kami kirim tautan reset."}` | `{"msg":{"email":["Format email tidak valid."]}}` |
| Reset Password | POST | `/api/auth/reset-password` | NONE | `{"token":"abc123","newPassword":"BaruKuat123","confirmPassword":"BaruKuat123"}` | `{"msg":"Password diubah. Silakan masuk."}` | `{"msg":{"token":["Tautan tidak valid atau kedaluwarsa."],"confirmPassword":["Konfirmasi tidak cocok."]}}` |
| Log Out | POST | `/api/auth/logout` | YES | `{"refreshToken":"eyJ..."}` | `{"msg":"Berhasil keluar."}` | `{"msg":"Token tidak valid."}` |

---

## 2. Onboarding & Profile

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Get Onboarding Content | GET | `/api/onboarding` | NONE | - | `{"msg":"Konten perkenalan","data":{"slides":[{"key":"INTRO","title":"Mulai dari pekarangan sendiri","body":"Tiga puluh polybag cabai cukup untuk mulai. Tidak perlu sawah.","illustration":"https://cdn.tandur.id/ill/intro-1.svg"}],"commodities":[{"commodity":"CABAI","name":"Cabai Rawit","cycleDays":90,"minUnit":"30 polybag","estCapitalIdr":300000,"iconUrl":"https://cdn.tandur.id/ic/cabai.svg"}]}}` | `{"msg":"Konten belum tersedia."}` |
| Save Onboarding | POST | `/api/onboarding/complete` | YES | `{"commodities":["CABAI","TERONG"],"hasFarmed":false,"district":"Grobogan","province":"Jawa Tengah"}` | `{"msg":"Preferensi tersimpan","data":{"startRoute":"/kelas","suggestedLevelId":"uuid"}}` | `{"msg":{"commodities":["Pilih minimal satu komoditas."]}}` |
| Get My Profile | GET | `/api/users/me` | YES | - | `{"msg":"Profil","data":{"userId":"uuid","fullName":"Reza Pratama","email":"reza@mail.com","avatarUrl":null,"roles":["USER"],"province":"Jawa Tengah","district":"Grobogan","commodities":["CABAI","TERONG"],"reputation":42,"joinedAt":"2026-08-01T02:00:00Z"}}` | `{"msg":"Token tidak valid."}` |
| Update Profile | PATCH | `/api/users/me` | YES | `{"fullName":"Reza Pratama","district":"Grobogan","commodities":["CABAI","PADI"]}` | `{"msg":"Profil diperbarui","data":{"userId":"uuid","fullName":"Reza Pratama"}}` | `{"msg":{"district":["Kabupaten tidak dikenal."]}}` |
| Upload Avatar | POST | `/api/users/me/avatar` | YES | `multipart/form-data: file` | `{"msg":"Foto profil diperbarui","data":{"avatarUrl":"https://cdn.tandur.id/av/abc.webp"}}` | `{"msg":"Ukuran file maksimal 2 MB."}` |
| Register Device | POST | `/api/users/me/devices` | YES | `{"fcmToken":"dXNlci1...","platform":"ANDROID"}` | `{"msg":"Perangkat terdaftar"}` | `{"msg":"Token FCM tidak valid."}` |
| Delete Account | DELETE | `/api/users/me` | YES | `{"password":"RahasiaKuat123"}` | `{"msg":"Akun dijadwalkan dihapus dalam 30 hari."}` | `{"msg":"Password salah."}` |

---

## 3. F1 — Kelas Tandur

### 3.1 Peta dan Struktur

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Get My Map | GET | `/api/learning/map` | YES | `?commodity=CABAI` | `{"msg":"Peta","data":{"commodity":"CABAI","totalXp":1240,"streakDays":12,"lives":5,"nextLifeAt":null,"nodes":[{"levelId":"uuid","code":"C1","title":"Semai & Tanam","status":"COMPLETED","progressPercent":100,"stars":3,"shapeVariant":2,"mapX":80,"mapY":620},{"levelId":"uuid","code":"C2","title":"Hama & Penyakit","status":"IN_PROGRESS","progressPercent":60,"stars":0,"shapeVariant":0,"mapX":150,"mapY":460},{"levelId":"uuid","code":"C3","title":"Panen & Pascapanen","status":"AVAILABLE","progressPercent":0,"shapeVariant":3,"mapX":110,"mapY":300},{"levelId":"uuid","code":"C4","title":"Benih Sendiri","status":"LOCKED","lockReason":"Selesaikan C3 dulu","shapeVariant":1,"mapX":200,"mapY":150}]}}` | `{"msg":"Komoditas tidak dikenal."}` |
| Get Level Detail | GET | `/api/learning/levels/:id` | YES | `id` | `{"msg":"Petak ditemukan","data":{"levelId":"uuid","code":"C2","title":"Hama & Penyakit","description":"Mengenali gejala dan menanganinya sebelum menyebar.","estimatedMinutes":48,"units":[{"unitId":"uuid","title":"Unit 1 · Mengenali Gejala","lessonCount":5,"completedCount":5,"status":"COMPLETED"},{"unitId":"uuid","title":"Unit 2 · Hama Utama","lessonCount":5,"completedCount":3,"status":"IN_PROGRESS"}],"finalTest":{"testId":"uuid","questionCount":20,"passThreshold":80,"status":"LOCKED","lockReason":"Selesaikan semua unit dulu"}}}` | `{"msg":"Petak tidak ditemukan."}` |
| Get Unit Lessons | GET | `/api/learning/units/:id/lessons` | YES | `id` | `{"msg":"Lesson","data":{"unitId":"uuid","title":"Unit 2 · Hama Utama","progressPercent":60,"lessons":[{"lessonId":"uuid","type":"CARD","title":"Kenapa daun cabai menguning dari bawah","estimatedMinutes":3,"xpReward":10,"status":"COMPLETED","order":1},{"lessonId":"uuid","type":"VIDEO","title":"Cara mengenali trips di bawah daun","durationSeconds":94,"xpReward":10,"status":"AVAILABLE","order":2,"isOfflineCapable":true},{"lessonId":"uuid","type":"EXERCISE_IMAGE","title":"Cocokkan gejala","xpReward":25,"status":"LOCKED","order":3}],"quiz":{"quizId":"uuid","questionCount":5,"passThreshold":80,"status":"LOCKED"}}}` | `{"msg":"Unit tidak ditemukan."}` |

### 3.2 Lesson

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Get Lesson | GET | `/api/learning/lessons/:id` | YES | `id` | `{"msg":"Lesson ditemukan","data":{"lessonId":"uuid","type":"CARD","title":"Kenapa daun cabai menguning dari bawah","blocks":[{"type":"HEADING","text":"Ciri kekurangan nitrogen"},{"type":"IMAGE","url":"https://cdn.tandur.id/ls/n-def.webp","caption":"Daun tua menguning merata, tulang daun ikut pucat"},{"type":"PARAGRAPH","text":"Kalau daun paling bawah yang duluan menguning..."},{"type":"CALLOUT","variant":"MISTAKE","title":"Sering keliru","text":"Kalau yang menguning justru daun muda di pucuk, itu bukan nitrogen."}],"sourceReference":"Balitsa, Petunjuk Teknis Budidaya Cabai, 2023","reviewedBy":"Ir. Sukirno, PPL Grobogan","xpReward":10,"nextLessonId":"uuid"}}` | `{"msg":"Lesson terkunci. Selesaikan lesson sebelumnya dulu."}` |
| Get Video Lesson | GET | `/api/learning/lessons/:id` | YES | `id` | `{"msg":"Lesson ditemukan","data":{"lessonId":"uuid","type":"VIDEO","title":"Cara mengenali trips di bawah daun","videoKind":"SELF_HOSTED","videoUrl360p":"https://cdn.tandur.id/v/trips_360p.mp4","videoUrl720p":"https://cdn.tandur.id/v/trips_720p.mp4","subtitleUrl":"https://cdn.tandur.id/v/trips.vtt","durationSeconds":94,"lastPositionSeconds":0,"attribution":null,"xpReward":10}}` | `{"msg":"Lesson tidak ditemukan."}` |
| Get Embedded Video | GET | `/api/learning/lessons/:id` | YES | `id` | `{"msg":"Lesson ditemukan","data":{"lessonId":"uuid","type":"VIDEO","title":"Pengendalian hama terpadu pada cabai","videoKind":"EMBED","youtubeVideoId":"dQw4w9WgXcQ","attribution":"Sumber: BSIP Jawa Tengah","isOfflineCapable":false,"xpReward":10}}` | `{"msg":"Lesson tidak ditemukan."}` |
| Save Video Position | POST | `/api/learning/lessons/:id/position` | YES | `{"positionSeconds":48}` | `{"msg":"Posisi tersimpan"}` | `{"msg":"Lesson tidak ditemukan."}` |
| Complete Lesson | POST | `/api/learning/lessons/:id/complete` | YES | `{"watchedPercent":93,"durationSeconds":180}` | `{"msg":"Lesson selesai","data":{"lessonId":"uuid","xpEarned":10,"totalXp":1250,"streakDays":13,"streakExtended":true,"nextLessonId":"uuid","unitCompleted":false,"levelCompleted":false}}` | `{"msg":"Video baru ditonton 40 persen. Minimal 90 persen."}` |
| Download Unit Bundle | GET | `/api/learning/units/:id/bundle` | YES | `id` | `{"msg":"Paket unduhan","data":{"unitId":"uuid","totalBytes":24680000,"assets":[{"kind":"IMAGE","url":"https://cdn.tandur.id/ls/n-def.webp","bytes":142000},{"kind":"VIDEO","url":"https://cdn.tandur.id/v/trips_360p.mp4","bytes":8200000}],"skippedEmbedCount":1}}` | `{"msg":"Unit tidak ditemukan."}` |

### 3.3 Latihan dan Ujian

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Get Exercise | GET | `/api/learning/exercises/:lessonId` | YES | `lessonId` | `{"msg":"Latihan","data":{"lessonId":"uuid","type":"EXERCISE_IMAGE","questions":[{"exerciseId":"uuid","prompt":"Gejala apa yang terlihat pada daun ini?","imageUrl":"https://cdn.tandur.id/ex/q1.webp","options":[{"key":"A","text":"Trips"},{"key":"B","text":"Kutu daun"},{"key":"C","text":"Kekurangan nitrogen"}],"order":1}]}}` | `{"msg":"Latihan tidak ditemukan."}` |
| Submit Exercise | POST | `/api/learning/exercises/:lessonId/submit` | YES | `{"answers":[{"exerciseId":"uuid","answer":"A"}],"durationSeconds":92}` | `{"msg":"Jawaban dinilai","data":{"score":80,"correctCount":4,"totalCount":5,"xpEarned":15,"results":[{"exerciseId":"uuid","correct":true,"correctAnswer":"A","explanation":"Keriting ke atas pada daun muda adalah ciri trips."}]}}` | `{"msg":{"answers":["Semua soal wajib dijawab."]}}` |
| Get Unit Quiz | GET | `/api/learning/quizzes/:id` | YES | `id` | `{"msg":"Kuis siap","data":{"quizId":"uuid","unitTitle":"Unit 2 · Hama Utama","questionCount":5,"passThreshold":80,"livesAvailable":4,"questions":[{"questionId":"uuid","prompt":"Kapan waktu terbaik menyemprot pestisida nabati?","imageUrl":null,"options":[{"key":"A","text":"Siang saat panas"},{"key":"B","text":"Pagi atau sore"}]}]}}` | `{"msg":"Nyawa kamu habis. Pulih lagi dalam 2 jam 15 menit."}` |
| Submit Unit Quiz | POST | `/api/learning/quizzes/:id/submit` | YES | `{"answers":[{"questionId":"uuid","answer":"B"}]}` | `{"msg":"Kuis lulus","data":{"score":80,"correctCount":4,"totalCount":5,"passed":true,"livesSpent":1,"livesRemaining":3,"xpEarned":50,"unitCompleted":true,"nextUnitId":"uuid"}}` | `{"msg":"Kuis belum lulus","data":{"score":60,"passed":false,"livesRemaining":2,"weakTopics":["Trips","Waktu penyemprotan"]}}` |
| Start Final Test | POST | `/api/learning/final-tests/:id/start` | YES | - | `{"msg":"Ujian dimulai","data":{"attemptId":"uuid","startedAt":"2026-08-11T09:00:00Z","expiresAt":"2026-08-11T09:35:00Z","questions":[{"questionId":"uuid","prompt":"...","options":[{"key":"A","text":"..."}]}]}}` | `{"msg":"Selesaikan semua unit di petak ini dulu."}` |
| Submit Final Test | POST | `/api/learning/final-tests/:id/submit` | YES | `{"attemptId":"uuid","answers":[{"questionId":"uuid","answer":"C"}]}` | `{"msg":"Selamat, kamu lulus!","data":{"score":88,"correctCount":18,"totalCount":20,"passed":true,"stars":3,"xpEarned":200,"levelCompleted":true,"nextLevelId":"uuid","badgeEarned":"CABAI_TAHAP_2","celebration":"IRRIGATION"}}` | `{"msg":"Belum lulus","data":{"score":68,"passed":false,"cooldownUntil":"2026-08-12T09:00:00Z","attemptsRemaining":2,"weakTopics":["Antraknosa","Layu bakteri"]}}` |

### 3.4 Gamifikasi

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Get My Stats | GET | `/api/gamification/stats` | YES | - | `{"msg":"Statistik","data":{"totalXp":1250,"level":4,"xpToNextLevel":250,"lives":3,"maxLives":5,"nextLifeAt":"2026-08-11T13:00:00Z","streakDays":13,"streakFreezeCount":1,"lastActivityDate":"2026-08-11","badgeCount":4,"completedLevels":2}}` | `{"msg":"Token tidak valid."}` |
| Get XP History | GET | `/api/gamification/xp-history` | YES | `?limit=20&cursor=` | `{"msg":"Riwayat XP","data":{"items":[{"id":"uuid","amount":50,"reason":"QUIZ_PASSED","referenceType":"QUIZ","referenceId":"uuid","createdAt":"2026-08-11T09:15:00Z"}],"nextCursor":"2026-08-10T10:00:00Z"}}` | `{"msg":"Token tidak valid."}` |
| Get My Badges | GET | `/api/gamification/badges` | YES | - | `{"msg":"Lencana","data":[{"badgeId":"uuid","code":"PANEN_PERTAMA","name":"Panen Pertama","description":"Catat panen pertamamu","iconUrl":"https://cdn.tandur.id/bg/panen.svg","earnedAt":"2026-08-02T08:00:00Z"},{"badgeId":"uuid","code":"STREAK_30","name":"Rajin Sebulan","earnedAt":null,"progress":13,"target":30}]}` | `{"msg":"Token tidak valid."}` |
| Buy Streak Freeze | POST | `/api/gamification/streak-freeze` | YES | - | `{"msg":"Pelindung Runtutan dibeli","data":{"streakFreezeCount":2,"xpSpent":200,"totalXp":1050}}` | `{"msg":"XP tidak cukup. Butuh 200 XP, kamu punya 120 XP."}` |

---

## 4. F2 — Periksa Tanaman

### 4.1 Tanaman

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Create Plant | POST | `/api/plants` | YES | `{"commodity":"CABAI","nickname":"Cabai Depan Rumah","unitCount":30,"unitType":"POLYBAG","plantedAt":"2026-06-30","variety":"Rawit Setan"}` | `{"msg":"Tanaman didaftarkan","data":{"plantId":"uuid","nickname":"Cabai Depan Rumah","commodity":"CABAI","daysAfterPlanting":42,"phase":"BERBUNGA","status":"ACTIVE"}}` | `{"msg":{"plantedAt":["Tanggal tanam tidak boleh di masa depan."],"unitCount":["Jumlah minimal 1."]}}` |
| Get My Plants `[UBAH v3.1]` | GET | `/api/plants` | YES | `?status=ACTIVE` | `{"msg":"Tanaman saya","data":[{"plantId":"uuid","nickname":"Cabai Depan Rumah","commodity":"CABAI","daysAfterPlanting":42,"phase":"BERBUNGA","unitCount":30,"unitType":"POLYBAG","lastScanAt":"2026-08-11T06:12:00Z","lastDiagnosis":"VIRUS_KUNING_KERITING","scanCount":4,"status":"ACTIVE"}]}` | `{"msg":"Token tidak valid."}` |
| Get Plant Detail `[UBAH v3.1]` | GET | `/api/plants/:id` | YES | `id` | `{"msg":"Tanaman ditemukan","data":{"plantId":"uuid","nickname":"Cabai Depan Rumah","commodity":"CABAI","variety":"Rawit Setan","plantedAt":"2026-06-30","daysAfterPlanting":42,"phase":"BERBUNGA","unitCount":30,"unitType":"POLYBAG","status":"ACTIVE","patterns":[{"type":"REPEATED_DIAGNOSIS","label":"VIRUS_KUNING_KERITING","occurrences":2,"withinDays":14,"note":"Muncul dua kali dalam dua minggu"}]}}` | `{"msg":"Tanaman tidak ditemukan."}` |
| Update Plant | PATCH | `/api/plants/:id` | YES | `{"nickname":"Cabai Pekarangan","unitCount":28}` | `{"msg":"Tanaman diperbarui","data":{"plantId":"uuid","nickname":"Cabai Pekarangan"}}` | `{"msg":"Tanaman tidak ditemukan."}` |
| End Plant | POST | `/api/plants/:id/end` | YES | `{"status":"HARVESTED","note":"Panen 3,2 kg total","endedAt":"2026-09-28"}` | `{"msg":"Tanaman ditutup","data":{"plantId":"uuid","status":"HARVESTED","totalDays":90,"scanCount":11,"xpEarned":500}}` | `{"msg":"Tanaman sudah ditutup sebelumnya."}` |
| Delete Plant | DELETE | `/api/plants/:id` | YES | - | `{"msg":"Tanaman dan seluruh riwayat pindainya dihapus."}` | `{"msg":"Tanaman tidak ditemukan."}` |

### 4.2 Pindai

Klasifikasi dijalankan **di perangkat** dengan model TFLite. Endpoint di bawah menyimpan hasilnya, bukan menjalankan inferensinya. Endpoint `classify` hanya dipakai sebagai cadangan untuk perangkat yang gagal memuat model.

**Aturan wajib untuk seluruh bagian ini `[UBAH v3.1]`:**

| Aturan | Nilai |
|---|---|
| Urutan `labels` | **Kontrak.** TFLite mengembalikan indeks, bukan nama. Urutan yang berbeda di klien membuat hasil tertukar diam-diam tanpa galat. **Salin urutannya apa adanya dari manifes; jangan pernah diurutkan ulang di klien.** Urutannya mengikuti nama folder yang dipakai saat melatih, dan itu tidak selalu berbahasa Indonesia: terong urut abjad Inggris (`Healthy`, `Insect Pest`, `Leaf Spot`, ...) lalu diterjemahkan, sedangkan cabai dan padi urut abjad Indonesia. Daftar lengkap ketiganya ada di tabel "Ringkasan Perubahan 3.2" bagian A |
| Jumlah dugaan yang ditampilkan | Setiap dugaan dengan keyakinan **di atas 0,10**, maksimal tiga. Bukan lagi "selalu tiga teratas" |
| Ambang "belum yakin" | **0,70** untuk umum, sama pada ketiga komoditas |
| Ambang khusus vonis `SEHAT` | **Dibaca dari medan `healthyConfidenceThreshold` pada manifes, jangan ditanam di kode.** Cabai 0,85, terong 0,90, padi 0,90. Lebih ketat dengan sengaja: salah menyatakan sehat padahal sakit membuat pengguna kehilangan satu musim, sedangkan salah menyatakan sakit padahal sehat hanya membuat pengguna memotret ulang |
| Masukan model | `float32`, piksel mentah 0 sampai 255. **Ukurannya dibaca dari medan `inputSize`, jangan ditanam di kode** — cabai dan terong 224 x 224, padi 320 x 320. Normalisasi sudah di dalam model, klien tidak melakukannya |
| Penyakit di luar daftar label | Dinyatakan apa adanya sebagai belum didukung. **Jangan** dipaksakan ke label terdekat. Antraknosa termasuk di sini |

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| **Get Model Manifest** `[UBAH v3.1]` | GET | `/api/vision/model` | YES | `?commodity=CABAI` | `{"msg":"Manifest model","data":{"commodity":"CABAI","version":"1.0.0","fileUrl":"https://cdn.tandur.id/ml/cabai_v100_fp16.tflite","sha256":"9f2c...","bytes":6000000,"inputSize":224,"inputDtype":"float32","quantization":"FLOAT16","labels":["BERCAK_DAUN","SEHAT","VIRUS_KUNING_KERITING"],"confidenceThreshold":0.70,"healthyConfidenceThreshold":0.85,"releasedAt":"2026-08-14T00:00:00Z"}}` | `{"msg":"Model untuk komoditas ini belum tersedia."}` |
| Get Upload URL | POST | `/api/uploads/signed-url` | YES | `{"purpose":"SCAN","contentType":"image/webp","sizeBytes":186420}` | `{"msg":"URL unggah dibuat","data":{"uploadUrl":"https://xxx.supabase.co/storage/v1/object/upload/...","fileUrl":"https://cdn.tandur.id/scan/abc.webp","expiresIn":3600}}` | `{"msg":"Ukuran file maksimal 5 MB."}` |
| **Save Scan** `[UBAH v3.1]` | POST | `/api/scans` | YES | `{"plantId":"uuid","imageUrl":"https://cdn.tandur.id/scan/abc.webp","modelVersion":"1.3.0","inferenceMs":840,"predictions":[{"label":"VIRUS_KUNING_KERITING","confidence":0.72},{"label":"BERCAK_DAUN","confidence":0.18},{"label":"SEHAT","confidence":0.07}],"capturedAt":"2026-08-11T06:12:00Z"}` | `{"msg":"Hasil tersimpan","data":{"scanId":"uuid","status":"DONE","plantId":"uuid","daysAfterPlanting":42,"primary":{"label":"VIRUS_KUNING_KERITING","displayName":"Virus Kuning Keriting","alias":"bule","confidence":0.72,"summary":"Daun menguning belang mengikuti tulang daun dan menggulung ke atas."},"alternatives":[{"label":"BERCAK_DAUN","displayName":"Bercak Daun","confidence":0.18}],"canDiscuss":true,"suggestedPrompts":["Ini bahaya nggak?","Bisa menular ke tanaman lain?","Berapa lama sampai pulih?"],"disclaimer":"Ini dugaan awal dari foto, bukan pemeriksaan langsung."}}` | `{"msg":{"predictions":["Minimal satu prediksi wajib dikirim."]}}` |
| Save Low Confidence Scan `[UBAH v3.1]` | POST | `/api/scans` | YES | `{"plantId":"uuid","imageUrl":"...","modelVersion":"1.3.0","predictions":[{"label":"VIRUS_KUNING_KERITING","confidence":0.41}]}` | `{"msg":"Keyakinan rendah","data":{"scanId":"uuid","status":"LOW_CONFIDENCE","primary":null,"guidance":{"title":"Fotonya belum cukup jelas","tips":["Satu helai daun saja","Latar polos, misalnya kertas","Cahaya dari samping, jangan melawan matahari"]},"canDiscuss":true}}` | `{"msg":"Tanaman tidak ditemukan."}` |
| Classify Fallback | POST | `/api/vision/classify` | YES | `{"commodity":"CABAI","imageUrl":"https://cdn.tandur.id/scan/abc.webp"}` | **202** `{"msg":"Sedang diproses","data":{"jobId":"uuid","estimatedSeconds":4}}` | `{"msg":"Kuota harian habis (15/15). Coba lagi besok."}` |
| Get Scan `[UBAH v3.1]` | GET | `/api/scans/:id` | YES | `id` | `{"msg":"Hasil pindai","data":{"scanId":"uuid","plantId":"uuid","plantNickname":"Cabai Depan Rumah","imageUrl":"https://cdn.tandur.id/scan/abc.webp","daysAfterPlanting":42,"status":"DONE","primary":{"label":"VIRUS_KUNING_KERITING","confidence":0.72},"alternatives":[],"hasDiscussion":true,"discussionId":"uuid","createdAt":"2026-08-11T06:12:00Z"}}` | `{"msg":"Pindai tidak ditemukan."}` |
| Get Scan Timeline `[UBAH v3.1]` | GET | `/api/plants/:id/scans` | YES | `?limit=20&cursor=` | `{"msg":"Linimasa","data":{"plantId":"uuid","items":[{"scanId":"uuid","imageUrl":"https://cdn.tandur.id/scan/abc.webp","daysAfterPlanting":42,"label":"VIRUS_KUNING_KERITING","displayName":"Virus Kuning Keriting","confidence":0.72,"flag":"REPEATED","createdAt":"2026-08-11T06:12:00Z"},{"scanId":"uuid","daysAfterPlanting":35,"label":"SEHAT","confidence":0.88,"flag":null,"createdAt":"2026-08-04T06:30:00Z"}],"nextCursor":null}}` | `{"msg":"Tanaman tidak ditemukan."}` |
| Flag Wrong Result `[UBAH v3.1]` | POST | `/api/scans/:id/flag` | YES | `{"reason":"WRONG_LABEL","userGuess":"BERCAK_DAUN","note":"Menurut saya ini bercak daun, bukan virus"}` | `{"msg":"Terima kasih. Laporan ini membantu kami memperbaiki model.","data":{"flagId":"uuid"}}` | `{"msg":"Kamu sudah menandai pindai ini."}` |
| Delete Scan | DELETE | `/api/scans/:id` | YES | - | `{"msg":"Pindai dihapus."}` | `{"msg":"Pindai tidak ditemukan."}` |

### 4.3 Diskusi dengan Asisten

Jawaban dialirkan lewat Server-Sent Events. Klien membuka `EventSource` ke endpoint kirim pesan dan menerima potongan teks berurutan.

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Start Discussion `[UBAH v3.1]` | POST | `/api/discussions` | YES | `{"scanId":"uuid"}` | `{"msg":"Diskusi dibuat","data":{"discussionId":"uuid","scanId":"uuid","context":{"commodity":"CABAI","daysAfterPlanting":42,"diagnosis":"VIRUS_KUNING_KERITING","confidence":0.72},"suggestedPrompts":["Ini bahaya nggak?","Bisa menular ke tanaman lain?","Berapa lama sampai pulih?"]}}` | `{"msg":"Pindai ini sudah punya diskusi.","data":{"discussionId":"uuid"}}` |
| Send Message | POST | `/api/discussions/:id/messages` | YES | `{"content":"Ini bahaya nggak?"}` | **Aliran SSE**, lihat contoh di bawah tabel | `{"msg":"Kuota diskusi harian habis (15/15). Coba lagi besok."}` |
| Get Discussion | GET | `/api/discussions/:id` | YES | `id` | `{"msg":"Diskusi","data":{"discussionId":"uuid","scanId":"uuid","messages":[{"messageId":"uuid","role":"USER","content":"Ini bahaya nggak?","createdAt":"2026-08-11T06:15:00Z"},{"messageId":"uuid","role":"ASSISTANT","content":"Virus kuning keriting memang merugikan kalau dibiarkan...","citations":[{"title":"Petunjuk Teknis Budidaya Cabai","publisher":"Balitsa","year":2023,"page":34,"url":"https://balitsa.litbang.pertanian.go.id/..."}],"helpful":null,"createdAt":"2026-08-11T06:15:04Z"}]}}` | `{"msg":"Diskusi tidak ditemukan."}` |
| Rate Message | POST | `/api/discussions/messages/:id/rate` | YES | `{"helpful":true}` | `{"msg":"Terima kasih atas penilaiannya."}` | `{"msg":"Pesan tidak ditemukan."}` |
| Get My Quota | GET | `/api/discussions/quota` | YES | - | `{"msg":"Kuota","data":{"dailyLimit":15,"usedToday":4,"remaining":11,"resetAt":"2026-08-12T00:00:00Z"}}` | `{"msg":"Token tidak valid."}` |

**Contoh aliran SSE dari `POST /api/discussions/:id/messages`:**

```
event: start
data: {"messageId":"uuid","model":"flash-lite"}

event: chunk
data: {"text":"Virus kuning keriting memang merugikan "}

event: chunk
data: {"text":"kalau dibiarkan, tapi di HST 42 "}

event: chunk
data: {"text":"kamu masih punya waktu."}

event: citations
data: {"citations":[{"title":"Petunjuk Teknis Budidaya Cabai","publisher":"Balitsa","year":2023,"page":34,"url":"https://..."}]}

event: suggestions
data: {"prompts":["Bisa menular ke tanaman lain?","Berapa lama sampai pulih?"]}

event: done
data: {"messageId":"uuid","totalTokens":312,"latencyMs":2840}
```

Kalau seluruh penyedia gagal:

```
event: error
data: {"code":"ALL_PROVIDERS_FAILED","msg":"Asisten sedang tidak bisa dihubungi. Pertanyaanmu tersimpan dan akan dijawab begitu layanan pulih."}
```

---

## 5. F3 — Warung Tani

### 5.1 Pertanyaan

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| List Questions | GET | `/api/community/questions` | YES | `?commodity=CABAI&sort=NEWEST&district=Grobogan&tag=hama&limit=20&cursor=` | `{"msg":"Pertanyaan","data":{"items":[{"questionId":"uuid","title":"Daun cabai keriting tapi tidak ada kutunya, kenapa?","commodity":"CABAI","tags":["hama"],"district":"Grobogan","author":{"userId":"uuid","fullName":"Reza P","reputation":42,"isVerified":false},"score":24,"myVote":0,"replyCount":14,"hasBestAnswer":true,"isAnswered":true,"createdAt":"2026-08-11T00:12:00Z"}],"nextCursor":"2026-08-10T22:00:00Z"}}` | `{"msg":"Komoditas tidak dikenal."}` |
| Search Questions | GET | `/api/community/search` | YES | `?q=daun+keriting&commodity=CABAI&limit=20` | `{"msg":"Hasil pencarian","data":{"items":[{"questionId":"uuid","title":"Daun cabai keriting tapi tidak ada kutunya, kenapa?","snippet":"...daun mudanya keriting ke atas...","score":24,"replyCount":14,"hasBestAnswer":true}],"nextCursor":null}}` | `{"msg":"Kata kunci minimal 3 karakter."}` |
| Find Similar | POST | `/api/community/questions/similar` | YES | `{"title":"daun cabai keriting","commodity":"CABAI"}` | `{"msg":"Pertanyaan serupa","data":[{"questionId":"uuid","title":"Daun cabai keriting tapi tidak ada kutunya, kenapa?","replyCount":14,"hasBestAnswer":true,"similarity":0.87}]}` | `{"msg":"Judul minimal 10 karakter."}` |
| Create Question | POST | `/api/community/questions` | YES | `{"title":"Daun cabai keriting tapi tidak ada kutunya, kenapa?","body":"Cabai saya HST 30, daun mudanya keriting ke atas. Sudah saya cek bawah daun, tidak ada kutu.","commodity":"CABAI","tags":["hama","daun"],"photos":["https://cdn.tandur.id/cm/a.webp"],"fromScanId":"uuid"}` | `{"msg":"Pertanyaan terkirim","data":{"questionId":"uuid","title":"Daun cabai keriting tapi tidak ada kutunya, kenapa?","xpEarned":5}}` | `{"msg":{"title":["Judul minimal 10 karakter."],"tags":["Maksimal 3 label."],"photos":["Maksimal 4 foto."]}}` |
| Get Question | GET | `/api/community/questions/:id` | YES | `id` | `{"msg":"Pertanyaan","data":{"questionId":"uuid","title":"Daun cabai keriting tapi tidak ada kutunya, kenapa?","body":"Cabai saya HST 30...","commodity":"CABAI","tags":["hama","daun"],"district":"Grobogan","photos":["https://cdn.tandur.id/cm/a.webp"],"attachedScan":{"scanId":"uuid","imageUrl":"https://cdn.tandur.id/scan/abc.webp","label":null,"status":"LOW_CONFIDENCE","daysAfterPlanting":30},"author":{"userId":"uuid","fullName":"Reza P","reputation":42},"score":24,"myVote":1,"replyCount":14,"createdAt":"2026-08-11T00:12:00Z","canEdit":false}}` | `{"msg":"Pertanyaan tidak ditemukan."}` |
| Update Question | PATCH | `/api/community/questions/:id` | YES | `{"title":"...","body":"...","tags":["hama"]}` | `{"msg":"Pertanyaan diperbarui","data":{"questionId":"uuid","editedAt":"2026-08-11T01:00:00Z"}}` | `{"msg":"Pertanyaan hanya bisa diubah dalam 30 menit pertama."}` |
| Delete Question | DELETE | `/api/community/questions/:id` | YES | - | `{"msg":"Pertanyaan dihapus."}` | `{"msg":"Tidak bisa menghapus pertanyaan yang sudah punya balasan."}` |

### 5.2 Balasan

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| List Replies | GET | `/api/community/questions/:id/replies` | YES | `?sort=TOP` | `{"msg":"Balasan","data":{"bestAnswer":{"replyId":"uuid","body":"Kalau keritingnya ke atas dan daun mudanya yang kena, itu ciri trips, bukan kutu daun.","author":{"userId":"uuid","fullName":"Dimas W","reputation":1240,"isVerified":true},"score":31,"myVote":0,"depth":0,"createdAt":"2026-08-11T01:00:00Z"},"items":[{"replyId":"uuid","parentId":null,"body":"Punya saya juga begitu, ternyata benar trips.","author":{"userId":"uuid","fullName":"Bagas","reputation":88},"score":5,"myVote":0,"depth":0,"childCount":2,"children":[{"replyId":"uuid","parentId":"uuid","body":"Pakai apa nanganinya?","author":{"userId":"uuid","fullName":"Sari"},"score":2,"depth":1,"childCount":3,"hasMoreChildren":true}],"createdAt":"2026-08-11T02:00:00Z"}]}}` | `{"msg":"Pertanyaan tidak ditemukan."}` |
| Load More Children | GET | `/api/community/replies/:id/children` | YES | `?limit=10&cursor=` | `{"msg":"Balasan lanjutan","data":{"items":[{"replyId":"uuid","parentId":"uuid","body":"Pestisida nabati dari daun mimba bisa dicoba.","author":{"userId":"uuid","fullName":"Nuraini"},"score":4,"depth":2}],"nextCursor":null}}` | `{"msg":"Balasan tidak ditemukan."}` |
| Create Reply | POST | `/api/community/questions/:id/replies` | YES | `{"body":"Coba cek pucuknya pakai kaca pembesar, trips ukurannya sangat kecil.","parentId":null}` | `{"msg":"Balasan terkirim","data":{"replyId":"uuid","depth":0,"xpEarned":10}}` | `{"msg":{"body":["Balasan minimal 10 karakter."],"parentId":["Balasan sudah mencapai kedalaman maksimal."]}}` |
| Mark Best Answer | POST | `/api/community/replies/:id/best` | YES | - | `{"msg":"Ditandai sebagai jawaban terbaik","data":{"replyId":"uuid","questionResolved":true,"authorXpEarned":25,"authorReputationEarned":15}}` | `{"msg":"Hanya penanya yang bisa menandai jawaban terbaik."}` |
| Unmark Best Answer | DELETE | `/api/community/replies/:id/best` | YES | - | `{"msg":"Tanda jawaban terbaik dilepas."}` | `{"msg":"Balasan ini bukan jawaban terbaik."}` |
| Delete Reply | DELETE | `/api/community/replies/:id` | YES | - | `{"msg":"Balasan dihapus."}` | `{"msg":"Tidak bisa menghapus balasan yang punya balasan lanjutan."}` |

### 5.3 Suara, Laporan, Reputasi

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Vote Question | POST | `/api/community/questions/:id/vote` | YES | `{"value":1}` | `{"msg":"Suara tersimpan","data":{"questionId":"uuid","score":25,"myVote":1}}` | `{"msg":"Tidak bisa memberi suara pada pertanyaan sendiri."}` |
| Vote Reply | POST | `/api/community/replies/:id/vote` | YES | `{"value":-1}` | `{"msg":"Suara tersimpan","data":{"replyId":"uuid","score":30,"myVote":-1}}` | `{"msg":"Tidak bisa memberi suara pada balasan sendiri."}` |
| Report Content | POST | `/api/community/reports` | YES | `{"targetType":"REPLY","targetId":"uuid","reason":"MISINFORMATION","note":"Anjuran dosisnya berbahaya"}` | `{"msg":"Laporan terkirim. Tim kami akan meninjau.","data":{"reportId":"uuid"}}` | `{"msg":"Kamu sudah melaporkan konten ini."}` |
| Get User Profile | GET | `/api/community/users/:id` | YES | `id` | `{"msg":"Profil publik","data":{"userId":"uuid","fullName":"Dimas W","avatarUrl":"https://cdn.tandur.id/av/d.webp","reputation":1240,"isVerified":true,"verifiedNote":"Mahasiswa Agroteknologi UNS","bestAnswerCount":18,"questionCount":4,"replyCount":92,"topCommodities":["CABAI","TERONG"],"joinedAt":"2026-05-02T00:00:00Z"}}` | `{"msg":"Pengguna tidak ditemukan."}` |
| Get Tags | GET | `/api/community/tags` | YES | `?commodity=CABAI` | `{"msg":"Label","data":[{"tag":"hama","count":142},{"tag":"pupuk","count":98},{"tag":"benih","count":54},{"tag":"panen","count":31}]}` | `{"msg":"Komoditas tidak dikenal."}` |

---

## 6. Notification

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| List Notifications | GET | `/api/notifications` | YES | `?unreadOnly=true&limit=20&cursor=` | `{"msg":"Notifikasi","data":{"unreadCount":3,"items":[{"notificationId":"uuid","type":"REPLY_RECEIVED","title":"Dimas W menjawab pertanyaanmu","body":"Kalau keritingnya ke atas dan daun mudanya yang kena...","payload":{"questionId":"uuid","replyId":"uuid"},"readAt":null,"createdAt":"2026-08-11T01:00:00Z"}],"nextCursor":null}}` | `{"msg":"Token tidak valid."}` |
| Mark as Read | POST | `/api/notifications/:id/read` | YES | - | `{"msg":"Ditandai dibaca","data":{"unreadCount":2}}` | `{"msg":"Notifikasi tidak ditemukan."}` |
| Mark All Read | POST | `/api/notifications/read-all` | YES | - | `{"msg":"Semua notifikasi ditandai dibaca","data":{"unreadCount":0}}` | `{"msg":"Token tidak valid."}` |
| Update Preferences | PUT | `/api/notifications/preferences` | YES | `{"scanReminder":true,"scanReminderDays":7,"replyReceived":true,"bestAnswerMarked":true,"streakWarning":true,"streakWarningHour":19}` | `{"msg":"Preferensi notifikasi diperbarui"}` | `{"msg":{"streakWarningHour":["Jam harus antara 0 dan 23."]}}` |

**Jenis notifikasi:** `REPLY_RECEIVED`, `BEST_ANSWER_MARKED`, `MENTION`, `SCAN_REMINDER`, `STREAK_WARNING`, `LEVEL_UNLOCKED`, `BADGE_EARNED`, `MODEL_UPDATED`.

---

## 7. Admin

| Name | Method | URL | Auth | Request Param | Success Response | Failed Response |
|---|---|---|---|---|---|---|
| Content Queue | GET | `/api/admin/content` | ADMIN | `?status=DRAFT&type=LESSON` | `{"msg":"Antrean konten","data":[{"contentId":"uuid","type":"LESSON","title":"Kenapa daun cabai menguning dari bawah","levelCode":"C2","author":"Tim Konten","reviewedBy":null,"status":"DRAFT","createdAt":"2026-08-03T00:00:00Z"}]}` | `{"msg":"Akses ditolak."}` |
| Publish Content | POST | `/api/admin/content/:id/publish` | ADMIN | `{"reviewedBy":"Ir. Sukirno, PPL Grobogan","reviewNote":"Dosis dan waktu sesuai anjuran Balitsa"}` | `{"msg":"Konten diterbitkan","data":{"contentId":"uuid","status":"PUBLISHED","publishedAt":"2026-08-11T10:00:00Z"}}` | `{"msg":"Konten wajib ditinjau ahli agronomi sebelum diterbitkan."}` |
| Moderation Queue | GET | `/api/admin/reports` | ADMIN | `?status=OPEN` | `{"msg":"Antrean laporan","data":[{"reportId":"uuid","targetType":"REPLY","targetId":"uuid","excerpt":"Semprot pakai dosis dua kali lipat biar cepat mati","reason":"MISINFORMATION","reporterCount":3,"status":"OPEN","createdAt":"2026-08-11T02:00:00Z"}]}` | `{"msg":"Akses ditolak."}` |
| Resolve Report | POST | `/api/admin/reports/:id/resolve` | ADMIN | `{"action":"REMOVE_CONTENT","note":"Anjuran dosis berbahaya"}` | `{"msg":"Laporan diselesaikan","data":{"reportId":"uuid","action":"REMOVE_CONTENT","status":"RESOLVED"}}` | `{"msg":"Laporan sudah diselesaikan."}` |
| Scan Flag Queue `[UBAH v3.1]` | GET | `/api/admin/scan-flags` | ADMIN | `?status=OPEN&commodity=CABAI` | `{"msg":"Antrean penandaan","data":[{"flagId":"uuid","scanId":"uuid","imageUrl":"https://cdn.tandur.id/scan/abc.webp","modelLabel":"VIRUS_KUNING_KERITING","modelConfidence":0.72,"userGuess":"BERCAK_DAUN","note":"Menurut saya ini bercak daun, bukan virus","modelVersion":"1.3.0","createdAt":"2026-08-11T07:00:00Z"}]}` | `{"msg":"Akses ditolak."}` |
| Resolve Scan Flag `[UBAH v3.1]` | POST | `/api/admin/scan-flags/:id/resolve` | ADMIN | `{"verdict":"MODEL_WRONG","correctLabel":"BERCAK_DAUN","addToTrainingSet":true}` | `{"msg":"Penandaan diselesaikan","data":{"flagId":"uuid","addedToTrainingSet":true}}` | `{"msg":"Penandaan sudah diselesaikan."}` |
| Model Metrics `[UBAH v3.1]` | GET | `/api/admin/vision/metrics` | ADMIN | `?commodity=CABAI&from=2026-08-01&to=2026-08-11` | `{"msg":"Metrik model","data":{"commodity":"CABAI","modelVersion":"1.3.0","totalScans":1420,"lowConfidenceRate":0.18,"flagRate":0.06,"flaggedWrongCount":84,"labelDistribution":[{"label":"SEHAT","count":612},{"label":"VIRUS_KUNING_KERITING","count":304}],"avgInferenceMs":870}}` | `{"msg":"Akses ditolak."}` |
| **Publish Model Version** `[UBAH v3.1]` | POST | `/api/admin/vision/model` | ADMIN | `{"commodity":"CABAI","version":"1.1.0","fileUrl":"https://cdn.tandur.id/ml/cabai_v110_fp16.tflite","sha256":"7a1b...","quantization":"FLOAT16","inputDtype":"float32","labels":["BERCAK_DAUN","SEHAT","VIRUS_KUNING_KERITING"],"confidenceThreshold":0.70,"healthyConfidenceThreshold":0.85,"fieldTestAccuracy":0.83,"note":"Dilatih ulang dengan 300 foto lapangan"}` | `{"msg":"Versi model diterbitkan","data":{"version":"1.4.0","rolloutPercent":10}}` | `{"msg":"Checksum tidak cocok dengan berkas."}` |
| RAG Documents | GET | `/api/admin/rag/documents` | ADMIN | `?commodity=CABAI` | `{"msg":"Dokumen basis pengetahuan","data":[{"documentId":"uuid","title":"Petunjuk Teknis Budidaya Cabai","publisher":"Balitsa","year":2023,"sourceUrl":"https://...","commodity":"CABAI","chunkCount":42,"indexedAt":"2026-08-05T00:00:00Z"}]}` | `{"msg":"Akses ditolak."}` |
| Add RAG Document | POST | `/api/admin/rag/documents` | ADMIN | `{"title":"Pengendalian Antraknosa pada Cabai","publisher":"BSIP Jawa Tengah","year":2024,"sourceUrl":"https://...","commodity":"CABAI","fileUrl":"https://cdn.tandur.id/kb/antraknosa.pdf"}` | **202** `{"msg":"Dokumen diterima, sedang dipecah dan diindeks","data":{"documentId":"uuid","jobId":"uuid"}}` | `{"msg":"Format berkas harus PDF atau teks."}` |
| Delete RAG Document | DELETE | `/api/admin/rag/documents/:id` | ADMIN | - | `{"msg":"Dokumen dan seluruh potongannya dihapus."}` | `{"msg":"Dokumen tidak ditemukan."}` |
| LLM Usage | GET | `/api/admin/llm/usage` | ADMIN | `?from=&to=&groupBy=PROVIDER` | `{"msg":"Pemakaian LLM","data":{"totalCalls":3820,"totalCostIdr":184000,"byProvider":[{"provider":"flash-lite","calls":3100,"successRate":0.96,"avgLatencyMs":1740,"quotaUsedPercent":62,"costIdr":0}],"avgCitationsPerAnswer":1.8,"helpfulRate":0.79}}` | `{"msg":"Akses ditolak."}` |
| Update LLM Provider | PATCH | `/api/admin/llm/providers/:id` | ADMIN | `{"priorityOrder":2,"dailyQuota":1000,"isActive":true}` | `{"msg":"Konfigurasi diperbarui","data":{"providerId":"uuid","provider":"groq-scout","priorityOrder":2,"isActive":true}}` | `{"msg":"Provider tidak ditemukan."}` |
| Platform Metrics | GET | `/api/admin/metrics` | ADMIN | `?from=2026-08-01&to=2026-08-11` | `{"msg":"Metrik platform","data":{"users":{"total":1420,"newThisPeriod":180,"dau":312,"mau":1050},"learning":{"lessonsCompleted":8420,"levelsCompleted":142,"avgStreakDays":7.4,"levelCompletionRate":0.41},"scan":{"totalScans":1420,"activePlants":268,"scansPerActiveUser":4.2,"discussionRate":0.62},"community":{"questions":214,"replies":1108,"answeredWithin24h":0.71,"bestAnswerRate":0.58}}}` | `{"msg":"Akses ditolak."}` |

---

## Lampiran A — Endpoint yang Bisa Langsung ke Supabase

Endpoint berikut hanya membaca dan tidak mengandung aturan bisnis. Klien boleh menembak Supabase langsung dengan proteksi keamanan tingkat baris, tanpa melewati backend. Ini memangkas sekitar sepertiga beban endpoint.

```
GET /api/learning/levels/:id           metadata petak
GET /api/learning/units/:id/lessons    daftar lesson, tanpa isi terkunci
GET /api/community/questions           daftar pertanyaan
GET /api/community/questions/:id       detail pertanyaan
GET /api/community/tags                daftar label
GET /api/notifications                 notifikasi
```

Sisanya wajib lewat backend karena mengandung komputasi, agregasi lintas modul, pemanggilan layanan AI, atau penulisan.

---

## Lampiran B — Batas Laju

| Kelompok | Batas |
|---|---|
| Autentikasi | 10 permintaan per menit per alamat IP |
| Unggah berkas | 30 per jam per pengguna |
| Simpan pindai | 30 per hari per pengguna |
| Pesan diskusi | 15 per hari per pengguna |
| Buat pertanyaan | 5 per jam per pengguna |
| Buat balasan | 20 per jam per pengguna |
| Suara | 100 per jam per pengguna |
| Umum | 120 permintaan per menit per pengguna |

Respons saat melewati batas:

```json
{ "msg": "Terlalu banyak permintaan. Coba lagi dalam 42 detik.", "data": { "retryAfterSeconds": 42 } }
```

Disertai header `Retry-After`.

---

## Lampiran C — Kode Galat

| Kode | Arti | Penanganan di klien |
|---|---|---|
| `AUTH_TOKEN_EXPIRED` | Token akses kedaluwarsa | Segarkan token lalu ulangi permintaan sekali |
| `AUTH_REFRESH_INVALID` | Token penyegar tidak valid | Bawa pengguna ke layar masuk |
| `IDEMPOTENCY_IN_PROGRESS` | Permintaan dengan kunci sama sedang diproses | Tunggu, jangan kirim ulang |
| `QUOTA_EXCEEDED` | Kuota harian habis | Tampilkan sisa waktu sampai penyetelan ulang |
| `MODEL_NOT_AVAILABLE` | Model komoditas belum ada | Sembunyikan tombol periksa untuk komoditas itu |
| `MODEL_CHECKSUM_MISMATCH` | Berkas model rusak saat diunduh | Hapus berkas lokal, unduh ulang |
| `ALL_PROVIDERS_FAILED` | Seluruh penyedia LLM gagal | Simpan pesan di antrean, beri tahu pengguna |
| `CONTENT_LOCKED` | Lesson atau petak masih terkunci | Tampilkan syarat yang kurang |
| `NO_LIVES_LEFT` | Nyawa habis | Tampilkan waktu pemulihan berikutnya |
| `DEPTH_LIMIT_REACHED` | Balasan sudah tiga tingkat | Balas ke induknya, bukan ke balasan ini |
| `SELF_VOTE_FORBIDDEN` | Memberi suara pada konten sendiri | Nonaktifkan kendali suara pada konten sendiri |
| `OFFLINE_QUEUED` | Dihasilkan klien, bukan server | Tampilkan penanda menunggu sinkron |
