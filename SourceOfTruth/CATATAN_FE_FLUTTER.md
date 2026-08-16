# Catatan Integrasi FE Flutter ↔ Backend TANDUR

Ditulis dari kode backend yang sedang berjalan (bukan dari dokumen), per commit `94af77d`.
Tujuannya satu: begitu repo Flutter dibuat, lapisan jaringannya bisa langsung benar tanpa
menebak-nebak.

Urutan bacanya: bagian 1–3 wajib dibaca sebelum menulis baris kode jaringan pertama.
Sisanya buka saat mengerjakan fitur terkait.

| Dokumen | Perannya |
|---|---|
| `API_DOCS_NEW.md` | Kontrak resmi: skema request/response per endpoint |
| `PRD_NEW.md` | Kenapa fiturnya ada, stack Flutter yang dipilih (§7.1) |
| **Catatan ini** | Cara menyambung keduanya: konvensi, jebakan, kode kerangka |

Kalau catatan ini bentrok dengan kode backend, **kode yang menang** — dan tolong kabari BE.

---

## 1. Alamat dan lingkungan

Prefix global `/api` dipasang di `src/main.ts:29`, bisa diubah lewat env `API_PREFIX`.
Port default 3000.

| Dari mana | Base URL |
|---|---|
| Emulator Android | `http://10.0.2.2:3000/api` |
| Simulator iOS / Flutter web | `http://localhost:3000/api` |
| HP fisik satu WiFi | `http://<IP-LAN-laptop>:3000/api` |
| Swagger UI | `http://localhost:3000/api/docs` |

Tiga hal yang bikin orang kehabisan waktu di hari pertama:

- **`10.0.2.2` bukan `localhost`.** Di emulator Android, `localhost` menunjuk ke emulatornya
  sendiri, bukan ke laptop. Gejalanya `SocketException: Connection refused`.
- **Android 9+ memblokir HTTP polos.** Karena dev pakai `http://`, tambahkan
  `android:usesCleartextTraffic="true"` di `AndroidManifest.xml` (khusus varian debug).
  Gejalanya `ClientException: Connection closed before full header was received`.
- **Swagger adalah alat debug terbaik yang sudah ada.** Sebelum menuduh Flutter, buka
  `/api/docs`, tekan Authorize, tempel access token, dan jalankan endpointnya di sana.
  Kalau di Swagger jalan tapi di Flutter tidak, masalahnya di klien.

Backend memanggil `app.enableCors()` tanpa argumen, jadi semua origin diizinkan. Aman untuk
mobile; untuk Flutter web di dev juga tidak perlu konfigurasi tambahan.

---

## 2. Delapan aturan wajib klien

Ini konvensi yang dipaksakan oleh interceptor/guard global. Melanggarnya bukan menghasilkan
data yang salah, tapi request yang ditolak.

### 2.1 Semua response dibungkus `{ msg, data }`

`ResponseEnvelopeInterceptor` membungkus setiap nilai balik controller. Tidak ada endpoint
yang mengembalikan objek telanjang.

```json
{ "msg": "Hasil tersimpan", "data": { "scanId": "...", "status": "DONE" } }
```

Konsekuensinya: **jangan pernah** `Model.fromJson(response.data)`. Selalu
`Model.fromJson(response.data['data'])`. Paling rapi, kupas `data` sekali di interceptor
(lihat 3.4) supaya seluruh repository tidak perlu tahu soal amplop ini.

Satu-satunya pengecualian: `POST /api/discussions/:id/messages` yang memakai `@RawResponse()`
dan menulis SSE langsung ke stream (lihat bagian 6).

### 2.2 `msg` bisa String **atau** Map — ini jebakan crash nomor satu

Pada sukses dan pada hampir semua error, `msg` adalah `String`. Tapi pada **400 gagal
validasi**, `ValidationExceptionFilter` mengubahnya menjadi peta field → daftar pesan:

```json
{ "msg": { "email": ["Format email tidak valid."], "password": ["Minimal 8 karakter."] } }
```

Kalau modelnya diketik `String msg`, Dart melempar
`type '_Map<String, dynamic>' is not a subtype of type 'String'` — dan celakanya ini terjadi
**di dalam error handler**, jadi error asli hilang dan yang muncul di layar cuma crash parsing.

Tangani dengan `dynamic` lalu cabang berdasarkan tipe. Kode lengkapnya di 3.1.

### 2.3 `Idempotency-Key` wajib di POST/PATCH/PUT/DELETE

`IdempotencyInterceptor` menolak setiap request mutasi tanpa header ini, atau yang isinya
bukan UUID **v4** (regex-nya ketat: digit versi harus `4`, digit varian harus `8/9/a/b`).

```json
{ "msg": { "idempotencyKey": ["Header Idempotency-Key wajib berupa UUID v4."] } }
```

Pakai paket `uuid` dan `const Uuid().v4()` — jangan bikin UUID sendiri dari `Random`.

Aturan pakainya, dan ini yang sering salah:

- **Kunci disimpan 24 jam dan di-*replay*.** Request kedua dengan kunci sama tidak
  menjalankan handler; backend mengembalikan body dan status yang tersimpan apa adanya.
- **Pencarian hanya berdasarkan kunci, tidak mengecek method/path.** Jadi kalau satu kunci
  dipakai untuk dua endpoint berbeda, endpoint kedua mengembalikan response endpoint
  pertama. Bug seperti ini sangat membingungkan — hindari dengan tidak pernah berbagi kunci.
- **Satu aksi pengguna = satu kunci, dipertahankan lintas retry.** Ini gunanya: kalau
  "Simpan Pindai" gagal karena sinyal putus lalu diulang, kunci yang sama mencegah dua baris
  scan. Kalau Flutter membuat UUID baru tiap retry, fiturnya mati total.
- **Untuk POST yang sebenarnya "membaca", buat kunci baru setiap kali.** Ada beberapa:
  `POST /api/community/questions/similar`, `POST /api/uploads/signed-url`,
  `POST /api/vision/classify`. Kalau kuncinya dipertahankan, jawaban basi selama 24 jam.
- **Request yang gagal menghapus kuncinya**, jadi boleh langsung diulang dengan kunci sama.
- **Dua request bersamaan dengan kunci sama** → 409 `IDEMPOTENCY_IN_PROGRESS`. Perlakukan
  sebagai "tunggu sebentar lalu ulangi", bukan sebagai kegagalan permanen.

Modelnya: simpan kunci bersama pekerjaan di antrean keluar Drift, bukan di-generate saat
mengirim.

### 2.4 Auth pakai Bearer, dengan satu keanehan pada refresh

`JwtAuthGuard` global. Semua rute butuh `Authorization: Bearer <accessToken>` kecuali:
`POST /api/auth/{signup,signin,google,refresh,forgot-password,reset-password}`,
`GET /api/health`, `GET /api/onboarding`. Perhatikan `POST /api/auth/logout` **butuh** auth.

| | Umur | Bentuk | Disimpan di |
|---|---|---|---|
| accessToken | 1 jam (`expiresIn: 3600`) | JWT, payload `{ userId, roles }` | `flutter_secure_storage` |
| refreshToken | 30 hari | string opaque (bukan JWT, jangan coba di-decode) | `flutter_secure_storage` |

**Keanehannya:** `POST /api/auth/refresh` hanya mengembalikan
`{ accessToken, expiresIn }` — **tidak ada refreshToken baru**. Tidak ada rotasi. Jadi
refreshToken awal dari signin/signup dipakai terus sampai 30 hari habis atau di-revoke lewat
logout. Jangan tulis kode yang menimpa refreshToken dengan `data['refreshToken']` dari
response refresh; nilainya `null` dan sesi pengguna akan mati diam-diam.

Bedakan dua error 401 lewat field `code`:

- `AUTH_TOKEN_EXPIRED` → access token kedaluwarsa, panggil refresh lalu ulangi request.
- `AUTH_REFRESH_INVALID` → refresh token mati, hapus kredensial dan lempar ke layar login.
- 401 tanpa `code` → token cacat/tidak ada. Perlakukan seperti `AUTH_REFRESH_INVALID`.

### 2.5 Error punya `code` yang stabil — jangan parsing teks Indonesia

Selain `msg`, error sering membawa `code` dari enum tetap. Cabangkan logika ke sini, karena
teks `msg` ditujukan untuk ditampilkan ke petani dan bisa berubah kapan saja.

```
AUTH_TOKEN_EXPIRED        AUTH_REFRESH_INVALID     IDEMPOTENCY_IN_PROGRESS
QUOTA_EXCEEDED            MODEL_NOT_AVAILABLE      MODEL_CHECKSUM_MISMATCH
ALL_PROVIDERS_FAILED      CONTENT_LOCKED           NO_LIVES_LEFT
DEPTH_LIMIT_REACHED       SELF_VOTE_FORBIDDEN
```

Sumber: `src/common/constants/error-codes.ts`. Salin persis ke enum Dart.

### 2.6 Paginasi memakai cursor, bukan nomor halaman

Daftar panjang mengembalikan `{ items, nextCursor }` di dalam `data`. Cursor adalah **stempel
waktu ISO** dari item terakhir, bukan offset.

```
GET /api/community/questions?limit=20&cursor=2026-08-11T03:00:00Z
```

- `limit` default 20, dipaksa maksimal 100 (`clampLimit`). Kirim 500, dapat 100.
- `nextCursor: null` berarti halaman terakhir. Ini penanda "berhenti" yang benar — jangan
  pakai `items.length < limit`, karena backend sengaja membedakan keduanya.
- Untuk pull-to-refresh, buang cursor dan mulai dari awal.

### 2.7 Semua waktu UTC ISO 8601

Backend mengirim dan menerima ISO 8601 dengan zona UTC (`Z`). Di Dart:
`DateTime.parse(s).toLocal()` untuk menampilkan, `dt.toUtc().toIso8601String()` untuk
mengirim. `capturedAt` pada simpan pindai divalidasi `@IsDateString()`, jadi format lokal
akan ditolak 400.

### 2.8 Batas laju mengembalikan 429

Default global 120 request/menit. Ada beberapa yang lebih ketat (tabel di bagian 9).
Perlakukan 429 sebagai keadaan sementara: backoff eksponensial, jangan tampilkan galat merah,
jangan retry ketat dalam loop.

---

## 3. Kerangka klien Dio

Stack yang dipilih di PRD §7.1: **Dio + Retrofit**, state **Riverpod 2**, penyimpanan token
**flutter_secure_storage**, antrean luring **Drift**. Kode di bawah menempel pada pilihan itu.

Urutan interceptor penting dan tidak intuitif — Dio menjalankan `onRequest` sesuai urutan
daftar, tapi `onResponse`/`onError` **terbalik**. Susunan yang benar:

```dart
dio.interceptors.addAll([
  AuthInterceptor(storage, dio),   // pasang token, tangani refresh saat 401
  IdempotencyInterceptor(),        // pasang Idempotency-Key
  EnvelopeInterceptor(),           // kupas `data`, ubah error jadi ApiException
  if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
]);
```

### 3.1 Amplop dan exception

```dart
/// Galat API yang sudah dinormalkan. `fieldErrors` hanya terisi pada 400 validasi.
class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.fieldErrors,
  });

  final int statusCode;
  /// Selalu bisa ditampilkan ke pengguna. Untuk 400 validasi, ini gabungan pesan.
  final String message;
  /// Nilai dari enum ErrorCode backend. Cabangkan logika di sini, bukan di `message`.
  final String? code;
  /// field -> daftar pesan, untuk ditempel di bawah TextFormField.
  final Map<String, List<String>>? fieldErrors;

  bool get isValidation => fieldErrors != null;
  bool get isAccessTokenExpired => code == 'AUTH_TOKEN_EXPIRED';
  bool get isQuotaExceeded => code == 'QUOTA_EXCEEDED';

  /// Membangun dari body backend, menangani `msg` yang bisa String atau Map.
  factory ApiException.fromBody(int status, dynamic body) {
    if (body is! Map) {
      return ApiException(statusCode: status, message: 'Terjadi galat. Coba lagi.');
    }
    final msg = body['msg'];
    final code = body['code'] as String?;

    if (msg is Map) {
      final fields = msg.map<String, List<String>>(
        (k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()),
      );
      return ApiException(
        statusCode: status,
        message: fields.values.expand((e) => e).join('\n'),
        code: code,
        fieldErrors: fields,
      );
    }
    return ApiException(
      statusCode: status,
      message: msg?.toString() ?? 'Terjadi galat. Coba lagi.',
      code: code,
    );
  }

  @override
  String toString() => 'ApiException($statusCode${code == null ? '' : ', $code'}): $message';
}
```

### 3.2 Interceptor idempotensi

```dart
/// Memasang Idempotency-Key di setiap mutasi. Kunci boleh ditentukan pemanggil lewat
/// `Options(extra: {'idempotencyKey': key})` -- wajib untuk aksi yang diantre luring,
/// supaya retry memakai kunci yang sama persis.
class IdempotencyInterceptor extends Interceptor {
  static const _mutating = {'POST', 'PATCH', 'PUT', 'DELETE'};
  static const _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_mutating.contains(options.method.toUpperCase())) {
      options.headers['Idempotency-Key'] =
          options.extra['idempotencyKey'] as String? ?? _uuid.v4();
    }
    handler.next(options);
  }
}
```

### 3.3 Interceptor auth dengan refresh antre

Bagian tersulit: kalau lima request jalan bersamaan dan token kedaluwarsa, kelimanya dapat
401 dan kelimanya memanggil refresh. Yang pertama berhasil, empat sisanya bisa gagal.
Kunci perbaikannya satu `Future` yang dibagi.

```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);

  final SecureTokenStore _storage;
  final Dio _dio;
  Future<String>? _refreshing; // dibagi oleh semua request yang menunggu

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['public'] != true) {
      final token = await _storage.accessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final code = (err.response?.data is Map) ? err.response!.data['code'] : null;

    // Hanya token akses kedaluwarsa yang layak diulang. AUTH_REFRESH_INVALID berarti
    // sesi benar-benar habis, dan mengulang endpoint refresh akan jadi loop tak berujung.
    final retryable = status == 401 &&
        code != 'AUTH_REFRESH_INVALID' &&
        err.requestOptions.extra['retried'] != true &&
        !err.requestOptions.path.contains('/auth/refresh');

    if (!retryable) return handler.next(err);

    try {
      final fresh = await (_refreshing ??= _refreshAccessToken());
      final opts = err.requestOptions..extra['retried'] = true;
      opts.headers['Authorization'] = 'Bearer $fresh';
      handler.resolve(await _dio.fetch(opts));
    } catch (_) {
      await _storage.clear();       // paksa ke layar login lewat listener Riverpod
      handler.next(err);
    } finally {
      _refreshing = null;
    }
  }

  Future<String> _refreshAccessToken() async {
    final refresh = await _storage.refreshToken();
    if (refresh == null) throw StateError('tidak ada refresh token');

    // Dio terpisah: tanpa interceptor ini, supaya tidak rekursif.
    final res = await Dio(_dio.options).post(
      '/auth/refresh',
      data: {'refreshToken': refresh},
      options: Options(headers: {'Idempotency-Key': const Uuid().v4()}),
    );

    // Response refresh HANYA berisi accessToken -- lihat 2.4. Jangan sentuh refreshToken.
    final access = res.data['data']['accessToken'] as String;
    await _storage.saveAccessToken(access);
    return access;
  }
}
```

### 3.4 Interceptor amplop

```dart
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response res, ResponseInterceptorHandler handler) {
    // SSE dan unduhan biner tidak berbentuk amplop.
    if (res.data is Map && (res.data as Map).containsKey('msg')) {
      res.extra['msg'] = res.data['msg'];        // simpan untuk snackbar sukses
      res.data = (res.data as Map)['data'];      // repository terima payload murni
    }
    handler.next(res);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    if (res != null) {
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: res,
        type: err.type,
        error: ApiException.fromBody(res.statusCode ?? 0, res.data),
      ));
      return;
    }
    // Tidak ada response: timeout, DNS, sinyal putus. Ini yang layak masuk antrean luring.
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      type: err.type,
      error: ApiException(
        statusCode: 0,
        message: 'Tidak ada koneksi. Perubahanmu akan dikirim saat online.',
      ),
    ));
  }
}
```

Setelah ini, repository cukup menulis `Model.fromJson(res.data)` dan menangkap
`ApiException`.

---

## 4. Autentikasi

Alur normalnya lurus; yang perlu dicatat cuma bentuk responsnya.

```
POST /api/auth/signup   -> 201 { userId, accessToken, refreshToken, expiresIn }
POST /api/auth/signin   -> 200 { userId, isNewUser, accessToken, refreshToken, expiresIn }
POST /api/auth/google   -> 200 { userId, isNewUser, accessToken, refreshToken, expiresIn }
POST /api/auth/refresh  -> 200 { accessToken, expiresIn }        <- tanpa refreshToken
POST /api/auth/logout   -> 200 (butuh Bearer, body { refreshToken })
```

- `isNewUser` menentukan apakah alur onboarding ditampilkan. Sediakan di state auth.
- `forgot-password` **selalu** membalas 200 dengan pesan generik, terdaftar atau tidak, untuk
  mencegah penghitungan email. Jangan tampilkan "email tidak ditemukan" — backend memang
  tidak memberi tahu.
- Endpoint auth dibatasi **10 request per menit per IP**. Saat menguji berulang di emulator,
  429 yang muncul itu wajar, bukan bug.
- `roles` ada di dalam payload JWT. Untuk menampilkan menu admin, decode JWT lokal
  (paket `jwt_decoder`) daripada memanggil endpoint tambahan.

---

## 5. Alur pindai — bagian paling rumit di aplikasi

Empat langkah, tiga di antaranya bisa gagal sendiri-sendiri. Rancang sebagai mesin status,
bukan satu fungsi `async` panjang.

### Langkah 1 — Ambil manifest model

```
GET /api/vision/model?commodity=CABAI
-> { commodity, version, fileUrl, sha256, bytes, inputSize, inputDtype,
     quantization, labels, confidenceThreshold, healthyConfidenceThreshold, releasedAt }
```

Unduh `fileUrl`, **verifikasi sha256** sebelum memuat ke `tflite_flutter`, cache di disk
dengan kunci `version`. Kalau checksum tidak cocok, buang dan pakai `MODEL_CHECKSUM_MISMATCH`.

Komoditas selain CABAI membalas **404 dengan `code: MODEL_NOT_AVAILABLE`** — itu keadaan
normal hari ini, bukan galat. Tampilkan "model belum tersedia", jangan tampilkan galat merah.

Tiga field ini menentukan benar/salahnya inferensi:

- **`inputDtype: "float32"` dan piksel mentah 0–255.** Normalisasi ada **di dalam** model.
  Kalau Flutter ikut membagi 255, hasilnya ngawur **tanpa galat apa pun** — inilah yang
  ditandai `API_DOCS_NEW.md` poin F sebagai "satu baris berbeda tapi fatal kalau terlewat".
- **`inputSize: 224`.** Resize ke 224×224.
- **`quantization: "FLOAT16"`**, bukan INT8. INT8 sudah diuji dan ditolak karena akurasi
  jatuh 90,2% → 59,0% (PRD §7.3.1).

### Langkah 2 — Unggah foto

```
POST /api/uploads/signed-url   { purpose: "SCAN", contentType: "image/webp", sizeBytes: 186420 }
-> { uploadUrl, fileUrl, expiresIn: 3600 }
```

`uploadUrl` adalah URL bertanda tangan Supabase Storage. Unggah **langsung ke sana**
(`PUT`, body = byte file) — jangan lewat backend TANDUR, dan **jangan sertakan header
Authorization TANDUR** ke URL itu. Simpan `fileUrl` untuk langkah 3.

Batas 5 MB divalidasi di `sizeBytes`, jadi kompres dulu (`flutter_image_compress`, di isolate)
sebelum meminta URL. `purpose` hanya menerima `SCAN`, `AVATAR`, atau `COMMUNITY`.
Endpoint ini dibatasi 30 request/jam per pengguna.

### Langkah 3 — Jalankan model di perangkat, lalu simpan

```
POST /api/scans
{
  "plantId": "uuid",
  "imageUrl": "<fileUrl dari langkah 2>",
  "modelVersion": "1.0.0",
  "inferenceMs": 840,
  "predictions": [ { "label": "VIRUS_KUNING_KERITING", "confidence": 0.72 } ],
  "capturedAt": "2026-08-11T06:12:00Z"
}
```

Kirim **semua** prediksi; backend yang mengurutkan, menyaring, dan memutuskan. Minimal satu.

Backend membalas salah satu dari dua bentuk, dibedakan lewat `status`:

- `status: "LOW_CONFIDENCE"` → `primary: null` plus objek `guidance { title, tips[] }`.
  Tampilkan tips memotret ulang. `canDiscuss: true`, jadi tombol tanya asisten tetap hidup.
- `status: "DONE"` → hasil normal dengan `primary` dan alternatif.

Ambangnya asimetris dan itu disengaja: 0,70 untuk umum, **0,85 khusus vonis `SEHAT`** —
salah bilang sehat padahal sakit menghabiskan satu musim petani, sebaliknya cuma minta foto
ulang. Backend sudah menerapkannya; FE tidak perlu menghitung sendiri, cukup jangan
menampilkan label mentah kalau `status` bukan `DONE`.

Label CABAI hanya tiga: `BERCAK_DAUN`, `SEHAT`, `VIRUS_KUNING_KERITING`. `ANTRAKNOSA`
sengaja **tidak ada** sebagai keluaran model (tidak ada dataset yang mencakupnya) walaupun
tetap muncul di Kelas Tandur dan RAG. Jangan hardcode daftar label di Flutter — baca dari
`labels` di manifest.

Batas simpan pindai: **30 per hari per pengguna**.

### Langkah 4 (opsional) — Fallback server

```
POST /api/vision/classify   { commodity, imageUrl }   -> 202 { jobId, estimatedSeconds: 4 }
```

Untuk perangkat yang gagal memuat TFLite. **Peringatan: belum berfungsi penuh.** Job
tersimpan tapi worker BullMQ belum dipasang (`REDIS_URL` belum diisi), jadi tidak akan pernah
selesai dan belum ada endpoint untuk menanyakan statusnya. Jangan bangun UI polling di
atasnya sekarang. Kuota 15 per hari.

---

## 6. Diskusi asisten — SSE, bukan JSON

`POST /api/discussions/:id/messages` adalah satu-satunya endpoint yang **tidak** berbentuk
amplop. Ia menulis `text/event-stream` langsung ke socket.

```dart
final res = await dio.post<ResponseBody>(
  '/discussions/$id/messages',
  data: {'content': pertanyaan},
  options: Options(
    responseType: ResponseType.stream,   // wajib, kalau tidak Dio menunggu sampai selesai
    headers: {'Idempotency-Key': const Uuid().v4()},
  ),
);

var buffer = '';
await for (final chunk in res.data!.stream) {
  buffer += utf8.decode(chunk);
  // Blok SSE dipisah baris kosong ganda. Chunk TCP tidak selalu jatuh di batas blok,
  // jadi sisakan potongan terakhir yang belum lengkap di buffer.
  var idx = buffer.indexOf('\n\n');
  while (idx != -1) {
    tanganiBlok(buffer.substring(0, idx));   // parse baris `event:` dan `data:`
    buffer = buffer.substring(idx + 2);
    idx = buffer.indexOf('\n\n');
  }
}
```

Nama event yang dikirim, dari `pipeSseAndAccumulate` di `discussions.service.ts`:

| event | isi `data` | yang dilakukan FE |
|---|---|---|
| `start` | `{ model }` | tampilkan indikator mengetik |
| `chunk` | `{ text }` | sambung ke gelembung jawaban |
| `citations` | `{ citations: [...] }` | render kartu sumber di bawah jawaban |
| `suggestions` | `{ prompts: [...] }` | render chip pertanyaan lanjutan |
| `done` | `{ totalTokens, latencyMs }` | tutup stream, aktifkan tombol rating |
| `error` | `{ code, msg }` | tampilkan `msg`; `code` biasanya `ALL_PROVIDERS_FAILED` |

Catatan penting:

- **`error` datang dengan status HTTP 200.** Stream sudah dibuka sebelum kegagalan hulu
  diketahui, jadi header tidak bisa diubah lagi. Jangan andalkan `statusCode` — cek nama
  event.
- **Konteks percakapan sudah ditangani backend.** Enam pesan terakhir otomatis dikirim ke
  ai-service. FE hanya perlu mengirim pertanyaan baru, tidak perlu menyusun riwayat sendiri.
- **Kuota 15 diskusi per hari.** Cek lewat `GET /api/discussions/quota` sebelum membuka
  layar, dan tangani `QUOTA_EXCEEDED` (403) saat mengirim.
- Chip saran dari `suggestions` memang dirancang untuk pertanyaan lanjutan seperti "Berapa
  lama sampai pulih?" — dan itu bekerja karena riwayat dikirim. Aktifkan sejak awal.

---

## 7. Daftar endpoint

Prefix `/api`. Auth = butuh Bearer. **Idem** = butuh header `Idempotency-Key`.
Skema request/response lengkap: `API_DOCS_NEW.md` atau Swagger.

| Method | Path | Auth | Idem | Keterangan |
|---|---|:--:|:--:|---|
| GET | `/health` | — | — | cek hidup |
| GET | `/onboarding` | — | — | slide onboarding |
| POST | `/onboarding/complete` | ✓ | ✓ | |
| POST | `/auth/signup` | — | ✓ | 201 |
| POST | `/auth/signin` | — | ✓ | |
| POST | `/auth/google` | — | ✓ | |
| POST | `/auth/refresh` | — | ✓ | balas accessToken saja |
| POST | `/auth/forgot-password` | — | ✓ | selalu 200 |
| POST | `/auth/reset-password` | — | ✓ | |
| POST | `/auth/logout` | ✓ | ✓ | body `{ refreshToken }` |
| GET | `/users/me` | ✓ | — | |
| PATCH | `/users/me` | ✓ | ✓ | |
| POST | `/users/me/avatar` | ✓ | ✓ | multipart, field `file` |
| POST | `/users/me/devices` | ✓ | ✓ | token FCM |
| DELETE | `/users/me` | ✓ | ✓ | **punya body** `{ password }` |
| GET | `/gamification/stats` | ✓ | — | |
| GET | `/gamification/xp-history` | ✓ | — | |
| GET | `/gamification/badges` | ✓ | — | |
| POST | `/gamification/streak-freeze` | ✓ | ✓ | |
| GET | `/learning/map?commodity=` | ✓ | — | |
| GET | `/learning/levels/:id` | ✓ | — | |
| GET | `/learning/units/:id/lessons` | ✓ | — | |
| GET | `/learning/units/:id/bundle` | ✓ | — | paket unduh luring |
| GET | `/learning/lessons/:id` | ✓ | — | |
| POST | `/learning/lessons/:id/position` | ✓ | ✓ | |
| POST | `/learning/lessons/:id/complete` | ✓ | ✓ | |
| GET | `/learning/exercises/:lessonId` | ✓ | — | |
| POST | `/learning/exercises/:lessonId/submit` | ✓ | ✓ | |
| GET | `/learning/quizzes/:id` | ✓ | — | |
| POST | `/learning/quizzes/:id/submit` | ✓ | ✓ | |
| POST | `/learning/final-tests/:id/start` | ✓ | ✓ | kunci baru tiap kali |
| POST | `/learning/final-tests/:id/submit` | ✓ | ✓ | |
| POST | `/plants` | ✓ | ✓ | |
| GET | `/plants?status=` | ✓ | — | |
| GET | `/plants/:id` | ✓ | — | |
| PATCH | `/plants/:id` | ✓ | ✓ | |
| POST | `/plants/:id/end` | ✓ | ✓ | |
| DELETE | `/plants/:id` | ✓ | ✓ | |
| GET | `/vision/model?commodity=` | ✓ | — | 404 = MODEL_NOT_AVAILABLE |
| POST | `/uploads/signed-url` | ✓ | ✓ | 30/jam, kunci baru tiap kali |
| POST | `/vision/classify` | ✓ | ✓ | 202, **worker belum ada** |
| POST | `/scans` | ✓ | ✓ | 30/hari |
| GET | `/scans/:id` | ✓ | — | |
| POST | `/scans/:id/flag` | ✓ | ✓ | lapor salah label |
| DELETE | `/scans/:id` | ✓ | ✓ | |
| GET | `/plants/:id/scans` | ✓ | — | cursor |
| POST | `/discussions` | ✓ | ✓ | dari sebuah scan |
| GET | `/discussions/quota` | ✓ | — | cek sebelum buka layar |
| GET | `/discussions/:id` | ✓ | — | |
| POST | `/discussions/:id/messages` | ✓ | ✓ | **SSE**, bukan JSON |
| POST | `/discussions/messages/:id/rate` | ✓ | ✓ | `{ helpful }` |
| GET | `/community/questions?commodity=&sort=&limit=&cursor=` | ✓ | — | sort: NEWEST/TOP/ACTIVE/UNANSWERED |
| GET | `/community/search` | ✓ | — | |
| POST | `/community/questions/similar` | ✓ | ✓ | cari duplikat, kunci baru tiap kali |
| POST | `/community/questions` | ✓ | ✓ | 5/jam |
| GET | `/community/tags` | ✓ | — | |
| GET | `/community/users/:id` | ✓ | — | profil publik |
| GET | `/community/questions/:id` | ✓ | — | |
| PATCH | `/community/questions/:id` | ✓ | ✓ | |
| DELETE | `/community/questions/:id` | ✓ | ✓ | |
| POST | `/community/questions/:id/vote` | ✓ | ✓ | 100/jam |
| GET | `/community/questions/:id/replies?sort=` | ✓ | — | sort: TOP/NEWEST |
| POST | `/community/questions/:id/replies` | ✓ | ✓ | 20/jam |
| GET | `/community/replies/:id/children` | ✓ | — | balasan bersarang |
| POST | `/community/replies/:id/vote` | ✓ | ✓ | 100/jam |
| POST | `/community/replies/:id/best` | ✓ | ✓ | tandai jawaban terbaik |
| DELETE | `/community/replies/:id/best` | ✓ | ✓ | batalkan |
| DELETE | `/community/replies/:id` | ✓ | ✓ | |
| POST | `/community/reports` | ✓ | ✓ | |
| GET | `/notifications` | ✓ | — | cursor |
| POST | `/notifications/:id/read` | ✓ | ✓ | |
| POST | `/notifications/read-all` | ✓ | ✓ | |
| PUT | `/notifications/preferences` | ✓ | ✓ | |
| * | `/admin/*` | ADMIN | ✓ | 15 rute, untuk panel Next.js — bukan Flutter |

Dua hal yang menggigit di Dart:

- **`DELETE /api/users/me` membawa body.** Paket `http` bawaan tidak mendukung body pada
  DELETE. Dio mendukung (`dio.delete(path, data: {...})`) — satu alasan lagi memakai Dio.
- **`POST /api/community/replies/:id/best` dan `DELETE`-nya** adalah pasangan
  tandai/batalkan pada path yang sama. Mudah tertukar saat membuat repository.

---

## 8. Enum untuk disalin ke Dart

Dari `prisma/schema.prisma`. Backend menerima dan mengirim string persis seperti ini
(HURUF_BESAR_GARIS_BAWAH). Generate dengan `@JsonEnum` dan **selalu sediakan nilai
`unknown`** sebagai fallback — backend bisa menambah anggota enum sebelum aplikasi diperbarui,
dan tanpa fallback aplikasi lama akan crash saat parsing.

```
Commodity        CABAI TERONG PADI
Role             USER MODERATOR ADMIN
Platform         ANDROID IOS
PlantStatus      ACTIVE HARVESTED ENDED
UnitType         POLYBAG METER_PERSEGI HEKTAR
ScanStatus       PROCESSING DONE LOW_CONFIDENCE REJECTED
ScanFlagReason   WRONG_LABEL NOT_A_LEAF OTHER
MessageRole      USER ASSISTANT
LessonType       CARD VIDEO EXERCISE_MCQ EXERCISE_MATCH EXERCISE_ORDER EXERCISE_IMAGE
VideoKind        SELF_HOSTED EMBED
NodeStatus       LOCKED AVAILABLE IN_PROGRESS COMPLETED PERFECT
ReportTargetType QUESTION REPLY
ReportReason     SPAM HARASSMENT MISINFORMATION OFF_TOPIC OTHER
VoteTargetType   QUESTION REPLY
NotificationType REPLY_RECEIVED BEST_ANSWER_MARKED MENTION SCAN_REMINDER
                 STREAK_WARNING LEVEL_UNLOCKED BADGE_EARNED MODEL_UPDATED
XpReason         LESSON_COMPLETED EXERCISE_COMPLETED QUIZ_PASSED FINAL_TEST_PASSED
                 FIRST_DAILY_SCAN BEST_ANSWER_RECEIVED REPLY_POSTED PLANT_HARVESTED
```

Enum khusus panel admin (`ContentStatus`, `ContentType`, `ScanFlagStatus`,
`ScanFlagVerdict`, `ReportStatus`, `ReportAction`) tidak dibutuhkan aplikasi Flutter.

---

## 9. Batas laju dan kuota

Dua mekanisme berbeda, dan bedanya penting untuk UI.

**Batas laju** (429, jendela geser, `src/common/constants/rate-limits.ts`):

| Cakupan | Batas |
|---|---|
| Umum | 120/menit/pengguna |
| Endpoint auth | 10/menit/**IP** |
| `POST /uploads/signed-url` | 30/jam/pengguna |
| `POST /community/questions` | 5/jam/pengguna |
| `POST /community/*/replies` | 20/jam/pengguna |
| vote (pertanyaan & balasan) | 100/jam/pengguna |

**Kuota harian** (403 + `code: QUOTA_EXCEEDED`, penghitung eksplisit di service):

| Aksi | Kuota |
|---|---|
| Simpan pindai | 30/hari |
| Pesan diskusi asisten | 15/hari |
| Klasifikasi fallback server | 15/hari |

Perlakukan berbeda: 429 = "pelan-pelan, coba lagi sebentar lagi" (backoff, diam-diam).
403 `QUOTA_EXCEEDED` = "habis sampai besok" (tampilkan jelas, matikan tombolnya, jangan
retry). Untuk diskusi, tampilkan sisa kuota dari `GET /api/discussions/quota` sebelum
pengguna mengetik panjang-panjang lalu ditolak.

---

## 10. Yang belum jalan di backend

Jangan menunggu, dan jangan bangun UI di atasnya dulu.

| Bagian | Status | Dampak ke FE |
|---|---|---|
| Worker BullMQ klasifikasi | belum dipasang, `REDIS_URL` kosong | `POST /vision/classify` balas 202 tapi job tidak pernah selesai; belum ada endpoint status |
| Pipeline ingest RAG | ai-service belum tersambung | jawaban asisten bergantung pada ai-service hidup; siapkan tampilan `ALL_PROVIDERS_FAILED` |
| Video Cloudflare R2 | kredensial belum diisi | `units/:id/bundle` untuk pelajaran video belum bisa diuji |
| Model TERONG & PADI | belum ada | `GET /vision/model` 404 `MODEL_NOT_AVAILABLE` — tangani sebagai keadaan normal |
| Supabase Realtime | belum dipakai backend | balasan forum masih perlu pull-to-refresh, belum ada push |

Yang **sudah** siap dan bisa dikerjakan penuh dari sekarang: auth, profil, tanaman, simpan
pindai, gamifikasi, forum, notifikasi, Kelas Tandur non-video, dan diskusi (selama ai-service
hidup).

---

## 11. Urutan pengerjaan yang disarankan

Alasan urutannya: setiap langkah menghasilkan sesuatu yang bisa dibuktikan jalan sebelum
lanjut, dan lapisan jaringan selesai lebih dulu supaya jebakan-jebakan di bagian 2 tidak
terulang di 13 tempat.

1. **Kerangka jaringan.** Dio + empat interceptor bagian 3, `SecureTokenStore`,
   `ApiException`. Buktikan dengan `GET /api/health`.
2. **Auth end-to-end.** signup → signin → panggil `GET /api/users/me` → biarkan token
   kedaluwarsa (atau rusak manual) → pastikan refresh otomatis jalan. Kalau ini kokoh,
   sisanya jauh lebih mudah.
3. **Enum dan model.** Generate dari bagian 8 dan skema di `API_DOCS_NEW.md`. Pertimbangkan
   generator OpenAPI dari `/api/docs-json` (Swagger sudah rapi sejak commit `0b01e70`).
4. **Tanaman.** CRUD paling sederhana yang memakai idempotensi dan paginasi cursor sekaligus
   — tempat terbaik memvalidasi keduanya.
5. **Pindai.** Empat langkah bagian 5. Kerjakan setelah tanaman, karena scan butuh `plantId`.
6. **Diskusi/SSE.** Setelah pindai, karena diskusi lahir dari sebuah scan.
7. **Forum, Kelas Tandur, gamifikasi, notifikasi.** Sudah tidak ada mekanisme baru di sini,
   hanya banyak layar.
8. **Antrean luring Drift.** Terakhir, tapi rancang tabelnya dari langkah 1: setiap baris
   antrean menyimpan method, path, body, **dan kunci idempotensinya**. Menambahkan kolom
   kunci belakangan berarti menulis ulang semua repository.

---

## 12. Ringkasan jebakan

Kalau cuma satu bagian yang sempat dibaca, baca ini.

1. `response.data['data']`, bukan `response.data`.
2. `msg` bisa Map pada 400. Jangan ketik `String`.
3. `Idempotency-Key` UUID v4 wajib di semua POST/PATCH/PUT/DELETE, termasuk `/auth/signin`.
4. Kunci sama = response lama diputar ulang selama 24 jam, tanpa mengecek path. Satu aksi
   satu kunci; kunci baru untuk POST yang sifatnya membaca.
5. `/auth/refresh` tidak mengembalikan refreshToken baru. Jangan menimpanya dengan `null`.
6. Refresh harus dibagi satu `Future`, kalau tidak request paralel saling mematikan.
7. Piksel 0–255 apa adanya ke TFLite. Jangan dinormalisasi.
8. Diskusi itu SSE — `ResponseType.stream`, dan event `error` datang dengan status 200.
9. `nextCursor: null` adalah penanda halaman terakhir, bukan `items.length < limit`.
10. `10.0.2.2` untuk emulator Android, plus `usesCleartextTraffic` di manifest debug.
