# PRD — TANDUR

| | |
|---|---|
| **Produk** | TANDUR (Tani Terukur) |
| **Versi** | 3.1 |
| **Tanggal** | 14 Agustus 2026 |
| **Perubahan 3.1** | Hasil terukur model Cabai v1.0.0 dimasukkan (7.3.1). Kuantisasi INT8 diganti float 16 berdasarkan pengujian. Aturan "tiga dugaan teratas" diganti "di atas 10 persen, maksimal tiga". Ambang keyakinan Q2 terjawab. Konteks cuaca dicoret. Antraknosa dinyatakan belum didukung. Tabel dataset diganti hasil survei nyata beserta lisensinya |
| **Platform** | Flutter (Android prioritas), Next.js untuk panel admin |
| **Komoditas** | Cabai Rawit, Padi, Terong |
| **Jangka MVP** | 12 minggu |
| **Dokumen terkait** | `DESAIN.md`, `API_DOCS.md`, `CLAUDE.md` |

---

## 1. Ringkasan

TANDUR adalah aplikasi mobile yang mengajarkan cara bertani kepada generasi muda Indonesia, lalu mendampingi mereka saat benar-benar menanam.

Tiga fitur, tidak lebih:

| # | Fitur | Bentuk | Frekuensi pakai |
|---|---|---|---|
| **F1** | **Kelas Tandur** | Kurikulum berjenjang per komoditas, dipetakan sebagai petak sawah bertingkat, dengan XP, level, dan karakter | Harian saat belajar |
| **F2** | **Periksa Tanaman** | Klasifikasi penyakit dari foto dengan model computer vision, dilanjutkan diskusi dengan asisten AI yang menjawab dari basis pengetahuan agronomi | Mingguan saat menanam |
| **F3** | **Warung Tani** | Forum tanya jawab bergaya komunitas terurut, per komoditas dan per wilayah | Saat ada masalah |

Ditambah **Perkenalan Awal**: alur pembuka yang menjelaskan tiga fitur itu dan mengarahkan pengguna ke komoditas yang cocok.

**Tiga komoditas dipilih karena satu alasan yang sama:** bisa dimulai di pekarangan tanpa lahan luas, modalnya kecil, dan gejala penyakitnya terlihat jelas di daun sehingga fitur pindai benar-benar terpakai.

| Komoditas | Siklus | Lahan minimum | Modal awal |
|---|---|---|---|
| Cabai Rawit | 90 hari | 30 polybag | Di bawah Rp 300.000 |
| Terong | 100 hari | 20 polybag | Di bawah Rp 250.000 |
| Padi | 110 hari | Sawah, minimum 0,1 ha | Bergantung lahan |

Cabai dan Terong adalah pintu masuk untuk yang belum punya lahan. Padi adalah komoditas yang memberi bobot nasional pada narasi produk.

**Yang membedakan TANDUR dari aplikasi pertanian lain:** hasil pindai tidak berhenti di label penyakit. Label itu jadi pembuka percakapan dengan asisten yang menjawab berdasarkan sumber agronomi yang bisa dilacak, dan mengaitkan jawabannya dengan umur tanaman serta riwayat pindai sebelumnya.

---

## 2. Masalah dan Data Pendukung

| Fakta | Angka | Sumber |
|---|---|---|
| Petani berumur 19 sampai 39 tahun | 6.183.009 orang, 21,93 persen dari total | BPS, Sensus Pertanian 2023 |
| Petani generasi X, 43 sampai 58 tahun | 42,39 persen | BPS, ST2023 |
| Petani baby boomer, 59 sampai 77 tahun | 27,61 persen | BPS, ST2023 |
| Kebutuhan penyuluh nasional | 83.000 | Kementan, 2024 |
| Penyuluh tersedia | Sekitar 38.000 | Kementan, 2024 |
| Rasio pelayanan penyuluh | 1 penyuluh untuk 5 desa | Kementan, 2024 |
| Pemuda bekerja di sektor pertanian | 21 persen, dibanding jasa 55 persen | BPS via UGM, 2020 |

**Tiga masalah yang diserang, dan hanya tiga:**

| Masalah | Bukti | Fitur penjawab |
|---|---|---|
| Tidak ada jalur belajar bertani yang terstruktur di luar keluarga petani | Sumber yang tersedia berupa video lepas yang saling bertentangan soal dosis dan waktu | F1 Kelas Tandur |
| Pemula tidak bisa mengenali penyakit tanaman, dan salah diagnosis berarti rugi satu musim | Rasio penyuluh 1 banding 5 desa membuat pendampingan langsung tidak mungkin | F2 Periksa Tanaman |
| Petani muda terisolasi, tidak punya tempat bertanya yang jawabannya tersimpan | Grup pesan instan tidak terarsip, pertanyaan yang sama ditanya berulang | F3 Warung Tani |

**Yang tidak diklaim TANDUR bisa selesaikan.** Ditulis eksplisit supaya tidak berlebihan saat presentasi: harga komoditas, akses kepemilikan lahan, kelangkaan pupuk subsidi, perubahan iklim, kebijakan impor pangan. TANDUR menyentuh keterampilan dan akses informasi.

---

## 3. Persona

**P1 — Reza, 22 tahun, belum pernah menanam.** Tinggal di Grobogan, kerja serabutan. Punya pekarangan 4 x 6 meter. Pernah kepikiran nanam cabai karena harganya sering naik, tapi tidak tahu mulai dari mana dan takut mati semua.
*Butuh:* jalur mulai yang tidak menuntut lahan, modal, maupun pengetahuan awal.
*Momen sukses:* cabai pertamanya berbuah.

**P2 — Nuraini, 27 tahun, sudah bertani.** Menggarap sawah 0,4 hektare warisan orang tua. Memupuk mengikuti kebiasaan ayahnya. Sering menemukan daun bercak tapi tidak tahu itu penyakit apa dan harus diapakan.
*Butuh:* jawaban cepat saat ada gejala, tanpa dipaksa menonton materi dasar yang sudah dia kuasai.
*Momen sukses:* memotret daun bercak, tahu itu apa, dan menanganinya sebelum menyebar.

**P3 — Dimas, 19 tahun, mahasiswa Pertanian.** Sedang praktikum, aktif di media sosial, senang menjawab pertanyaan orang.
*Butuh:* tempat berbagi pengetahuan yang jawabannya tidak hilang tertimbun seperti di grup pesan.
*Momen sukses:* jawabannya ditandai sebagai solusi dan dibaca ratusan orang.

**P4 — Admin operasi.** Mengurasi konten kurikulum, memoderasi forum, memantau akurasi model.

---

## 4. Tujuan dan Metrik

### 4.1 Tujuan produk

| # | Tujuan | Metrik | Target 6 bulan |
|---|---|---|---|
| G1 | Pemula bisa menyelesaikan satu Level penuh | Tingkat penyelesaian Level | 40 persen dari yang memulai |
| G2 | Pembelajaran berlanjut ke tanaman nyata | Pengguna punya minimal satu Tanaman aktif | 35 persen pengguna aktif |
| G3 | Pindai benar-benar dipakai berulang, bukan sekali coba | Rata-rata pindai per pengguna aktif per bulan | 4 kali |
| G4 | Diagnosis dapat dipercaya | Tingkat "hasil ini membantu" dari pengguna | 75 persen |
| G5 | Forum hidup dan menjawab | Pertanyaan mendapat balasan dalam 24 jam | 70 persen |

### 4.2 Metrik kesehatan

| Metrik | Target |
|---|---|
| Retensi D7 | 55 persen |
| Retensi D30 | 30 persen |
| Waktu tampil layar pertama pada 3G | Di bawah 2 detik |
| Waktu inferensi pindai di perangkat | Di bawah 1,5 detik |
| Waktu balas pertama asisten AI | Di bawah 3 detik |
| Akurasi model pada foto lapangan asli | Di atas 80 persen top-1 |
| Biaya LLM per pengguna aktif per bulan | Di bawah Rp 500 |
| Crash-free session rate | Di atas 99,5 persen |

### 4.3 Metrik yang sengaja tidak dikejar

- **Waktu di aplikasi.** Produk ini sukses kalau pengguna banyak di pekarangan, bukan di layar
- **Jumlah pindai per pengguna per hari.** Menaikkan ini hanya menaikkan biaya
- **Jumlah komoditas.** Tiga yang lengkap lebih berharga daripada delapan yang setengah jadi

---

## 5. Kebutuhan Fungsional

Format: user story lalu kriteria penerimaan yang bisa diuji. Kriteria di bawah langsung dipakai sebagai isi issue dan sebagai prompt untuk agent.

### 5.0 Perkenalan Awal

**US-00** — Sebagai pengguna yang baru membuka aplikasi, saya ingin tahu apa yang bisa dilakukan aplikasi ini dalam waktu singkat.

- [ ] Empat layar perkenalan: masalah yang diselesaikan, Kelas Tandur, Periksa Tanaman, Warung Tani
- [ ] Setiap layar punya satu ilustrasi, satu judul, dan maksimal dua baris teks
- [ ] Ada tombol "Lewati" yang selalu terlihat di pojok kanan atas
- [ ] Setelah perkenalan, pengguna memilih komoditas yang diminati, boleh lebih dari satu
- [ ] Setelah memilih komoditas, pengguna ditanya apakah sudah pernah menanam
- [ ] Jawaban "belum pernah" mengarahkan ke Level 1 komoditas pilihan
- [ ] Jawaban "sudah pernah" mengarahkan ke layar Tanaman Saya untuk langsung mendaftarkan tanaman
- [ ] Seluruh alur perkenalan bisa diselesaikan dalam bawah 45 detik
- [ ] Perkenalan hanya tampil sekali, tapi bisa dibuka lagi dari menu Profil
- [ ] Pendaftaran akun ditunda sampai pengguna menyelesaikan lesson pertama atau pindai pertama

Butir terakhir disengaja. Meminta pendaftaran sebelum pengguna melihat nilai aplikasi adalah penyebab utama pengguna berhenti di layar pertama.

### 5.1 F1 — Kelas Tandur

**US-01** — Sebagai pemula, saya ingin materi tersusun berjenjang supaya tahu urutan yang benar.

- [ ] Hierarki: Kebun (komoditas) berisi Petak (level), Petak berisi Unit, Unit berisi Lesson
- [ ] Lesson dalam satu Unit berurutan, tidak bisa dilompati
- [ ] Ujian Petak terbuka setelah semua Unit selesai
- [ ] Petak berikutnya terbuka setelah Ujian Petak lulus, ambang 80 persen
- [ ] Petak terkunci menampilkan syarat yang kurang, bukan sekadar gembok
- [ ] Progres belajar tidak mengunci fitur Periksa Tanaman maupun Warung Tani

**US-02** — Sebagai pembelajar, saya ingin melihat kemajuan saya di peta.

- [ ] Peta menampilkan lanskap terasering, tiap Petak adalah satu bidang sawah
- [ ] Petak punya lima status visual berbeda: terkunci, tersedia, sedang dikerjakan, selesai, sempurna
- [ ] Karakter pengguna berdiri di Petak yang sedang dikerjakan
- [ ] Peta bisa digeser dan dizum, posisi tersimpan saat keluar
- [ ] Petak yang baru terbuka mendapat animasi, sekali saja, hormati preferensi kurangi gerak
- [ ] Ganti komoditas lewat tab di atas peta, bukan lewat menu tersembunyi

**US-03** — Sebagai pembelajar, saya ingin materi yang ringan dan cepat dibaca.

- [ ] Format utama kartu bergambar: teks 300 sampai 500 kata dan 2 sampai 4 foto beranotasi
- [ ] Video 60 sampai 180 detik untuk hal yang butuh melihat gerakan
- [ ] Setiap kartu mencantumkan sumber rujukan di bagian bawah
- [ ] Setiap lesson video menampilkan atribusi sumber di bawah pemutar
- [ ] Satu lesson dapat diselesaikan dalam 2 sampai 4 menit

**US-04** — Sebagai pembelajar, saya ingin mengunduh materi supaya bisa belajar tanpa sinyal.

- [ ] Tombol unduh tersedia per Unit
- [ ] Kartu, foto, dan video milik sendiri bisa diunduh
- [ ] Lesson video sematan ditandai jelas sebagai tidak tersedia luring
- [ ] Satu Petak di bawah 60 MB
- [ ] Progres lesson dan jawaban latihan tersimpan luring lalu tersinkron
- [ ] Aplikasi memperingatkan kalau ruang penyimpanan tersisa di bawah 1 GB

**US-05** — Sebagai pembelajar, saya ingin dihargai atas kemajuan saya.

- [ ] XP diberikan per lesson, latihan, ujian, pindai pertama harian, dan jawaban forum yang ditandai membantu
- [ ] Runtutan hari bertambah kalau ada minimal satu aktivitas berXP dalam sehari waktu Indonesia Barat
- [ ] Pelindung Runtutan bisa ditukar 200 XP, maksimal simpan 2, terpakai otomatis
- [ ] Nyawa berkurang hanya saat jawaban salah di Ujian Unit dan Ujian Petak, tidak di latihan biasa
- [ ] Nyawa pulih 1 tiap 4 jam
- [ ] Saat nyawa habis, pengguna tetap bisa membaca materi, hanya tidak bisa mengambil ujian
- [ ] Lencana diberikan untuk pencapaian, bukan untuk sekadar membuka aplikasi

### 5.2 F2 — Periksa Tanaman

**US-06** — Sebagai penanam, saya ingin mendaftarkan tanaman supaya riwayatnya tercatat.

- [ ] Pendaftaran butuh komoditas, nama panggilan, jumlah polybag atau luas, dan tanggal tanam
- [ ] Tanggal tanam boleh diperkirakan, ada opsi "kira-kira sebulan lalu"
- [ ] Umur tanaman dihitung otomatis dan ditampilkan sebagai Hari Setelah Tanam
- [ ] Satu pengguna boleh punya beberapa tanaman
- [ ] Pendaftaran tanaman bisa diakses sejak hari pertama, tanpa syarat menyelesaikan lesson apa pun

**US-07** — Sebagai penanam, saya ingin memotret daun dan tahu tanaman saya kenapa.

- [ ] Kamera menampilkan bingkai panduan dan tips singkat: satu daun, latar polos, cahaya cukup
- [ ] Metadata EXIF termasuk GPS dihapus di perangkat sebelum apa pun dikirim
- [ ] Gambar dikompres ke sisi terpanjang 1024 piksel di perangkat
- [ ] Klasifikasi dijalankan di perangkat, hasil muncul di bawah 1,5 detik
- [ ] Klasifikasi tetap berfungsi tanpa koneksi internet
- [ ] Hasil menampilkan setiap dugaan dengan keyakinan di atas 10 persen, maksimal tiga, tidak pernah satu label tunggal
- [ ] Keyakinan di bawah 70 persen ditampilkan sebagai "belum yakin" dengan saran memotret ulang
- [ ] Vonis `SEHAT` memakai ambang lebih ketat, 85 persen, karena salah menyatakan sehat jauh lebih merugikan daripada salah menyatakan sakit
- [ ] Penyakit yang belum didukung model disebutkan apa adanya, bukan dipaksakan ke label terdekat
- [ ] Foto yang jelas bukan daun ditolak dengan pesan yang menjelaskan cara memperbaikinya

**US-08** — Sebagai penanam, saya ingin bertanya lanjut soal hasil pindai.

- [ ] Setelah hasil klasifikasi muncul, tersedia ruang percakapan dengan asisten
- [ ] Asisten menerima konteks: komoditas, umur, hasil klasifikasi, 10 pindai terakhir, dan enam pesan terakhir dalam percakapan yang sama
- [ ] Jawaban asisten mencantumkan sumber rujukan yang bisa dibuka
- [ ] Tersedia tiga pertanyaan lanjutan yang disarankan, bisa diketuk
- [ ] Asisten tidak pernah menyebut merek dagang pestisida maupun dosis kimia spesifik
- [ ] Asisten mengarahkan ke Warung Tani atau penyuluh untuk kasus berat
- [ ] Jawaban muncul mengalir kata demi kata, balasan pertama di bawah 3 detik
- [ ] Percakapan tersimpan dan bisa dibuka lagi dari riwayat pindai

**US-09** — Sebagai penanam, saya ingin melihat perkembangan tanaman saya dari waktu ke waktu.

- [ ] Linimasa menampilkan seluruh pindai tanaman tersebut, terbaru di atas
- [ ] Tiap butir linimasa berisi foto kecil, umur saat itu, hasil dugaan, dan tingkat keyakinan
- [ ] Ada penanda visual kalau diagnosis berulang, misalnya penyakit yang sama muncul dua kali
- [ ] Linimasa bisa disaring per tanaman
- [ ] Foto pindai bisa dihapus pengguna kapan saja

**US-10** — Sebagai pengguna, saya ingin tahu batas kemampuan sistem ini.

- [ ] Setiap hasil pindai menyertakan penafian bahwa ini dugaan awal
- [ ] Ada tautan "kenapa hasilnya bisa salah" yang menjelaskan keterbatasan model
- [ ] Kuota 15 percakapan asisten per pengguna per hari, dengan pesan yang jelas saat habis
- [ ] Pengguna bisa menandai hasil sebagai salah, dan penandaan itu masuk antrean peninjauan

### 5.3 F3 — Warung Tani

**US-11** — Sebagai pengguna, saya ingin bertanya ke sesama petani.

- [ ] Forum dibagi per komoditas, ditambah satu ruang umum
- [ ] Membuat pertanyaan butuh judul, isi, dan komoditas, foto opsional maksimal 4
- [ ] Bisa menambahkan hingga tiga label, misalnya hama, pupuk, benih, panen
- [ ] Pertanyaan bisa dibuat langsung dari hasil pindai, dengan foto dan konteks terbawa otomatis
- [ ] Pengguna bisa menandai satu balasan sebagai jawaban terbaik
- [ ] Pertanyaan yang sudah punya jawaban terbaik ditandai jelas di daftar

**US-12** — Sebagai pengguna, saya ingin menemukan jawaban tanpa harus bertanya.

- [ ] Daftar bisa diurutkan: terbaru, teratas, sedang ramai, belum terjawab
- [ ] Pencarian mencakup judul, isi, dan label
- [ ] Saat mengetik judul pertanyaan baru, sistem menampilkan pertanyaan serupa
- [ ] Bisa disaring per komoditas dan per kabupaten

**US-13** — Sebagai pengguna, saya ingin percakapan yang mudah diikuti.

- [ ] Balasan berjenjang maksimal tiga tingkat, lebih dari itu dilipat
- [ ] Suara naik dan turun tersedia untuk pertanyaan maupun balasan
- [ ] Jawaban terbaik selalu tampil di urutan pertama, terlepas dari jumlah suara
- [ ] Balasan dari akun terverifikasi diberi tanda
- [ ] Ada tombol laporkan di setiap pertanyaan dan balasan

**US-14** — Sebagai pengguna, saya ingin reputasi saya terlihat.

- [ ] Poin reputasi bertambah dari suara naik dan dari jawaban terbaik
- [ ] Profil menampilkan reputasi, jumlah jawaban terbaik, dan komoditas yang dikuasai
- [ ] Menjawab pertanyaan orang lain memberi XP yang masuk ke Kelas Tandur

### 5.4 Panel Admin

**US-15** — Sebagai admin, saya ingin mengelola konten dan memantau sistem.

- [ ] Antrean terpisah: kurasi konten, moderasi laporan, penandaan hasil pindai salah
- [ ] Konten tidak bisa diterbitkan tanpa penanda sudah ditinjau ahli agronomi
- [ ] Dasbor menampilkan akurasi model dari penandaan pengguna
- [ ] Dasbor menampilkan pemakaian dan biaya LLM per penyedia
- [ ] Bisa mengubah urutan dan status penyedia LLM tanpa penerapan ulang
- [ ] Bisa menambah dan memperbarui dokumen basis pengetahuan asisten

---

## 6. Kebutuhan Non-Fungsional

### 6.1 Performa

| Metrik | Anggaran |
|---|---|
| Waktu buka aplikasi sampai layar pertama, perangkat kelas bawah | Di bawah 2 detik |
| Waktu tampil peta Kelas Tandur | Di bawah 800 milidetik |
| Waktu inferensi model di perangkat | Di bawah 1,5 detik |
| Waktu balas pertama asisten | Di bawah 3 detik |
| Respons API persentil ke-95 | Di bawah 500 milidetik |
| Ukuran APK setelah pemisahan per ABI | Di bawah 40 MB |
| Ukuran model TFLite setelah kuantisasi | Di bawah 8 MB. Tercapai pada Cabai v1.0.0: 6,00 MB |
| Penggunaan memori puncak | Di bawah 250 MB |
| Frame per detik saat menggeser peta | 60, tanpa jank di atas 16 milidetik |

**Cara mencapainya, bukan sekadar target:**

- Aset peta berupa SVG dan atlas gambar, bukan puluhan berkas PNG terpisah
- Daftar panjang memakai `ListView.builder` dengan `itemExtent` tetap, bukan `Column` di dalam `SingleChildScrollView`
- Gambar jarak jauh lewat `cached_network_image` dengan `memCacheWidth` yang ditetapkan
- Model TFLite dimuat sekali di isolate terpisah, tidak dimuat ulang tiap pindai
- Kompresi gambar dijalankan di isolate, tidak di thread UI
- `const` konstruktor di mana pun memungkinkan, widget dipecah supaya rebuild sempit
- `RepaintBoundary` di sekitar animasi karakter dan node peta

### 6.2 Ketersediaan luring

| Fitur | Perilaku tanpa koneksi |
|---|---|
| Kelas Tandur, materi terunduh | Berfungsi penuh |
| Kelas Tandur, materi belum diunduh | Menampilkan pesan dan tombol unduh |
| Klasifikasi pindai | Berfungsi penuh, model ada di perangkat |
| Percakapan asisten | Tidak berfungsi, hasil klasifikasi tetap tersimpan |
| Linimasa tanaman | Berfungsi, data lokal |
| Warung Tani | Menampilkan cache terakhir, pengiriman diantre |

Perubahan yang dibuat saat luring masuk antrean keluar lokal, dikirim ulang saat koneksi kembali, dan setiap permintaan tulis membawa kunci idempotensi supaya tidak dobel.

### 6.3 Keamanan dan privasi

- Autentikasi email dan kata sandi ditambah masuk dengan Google
- Token akses berlaku 1 jam, token penyegar 30 hari
- Keamanan tingkat baris aktif di seluruh tabel, diuji dengan berkas uji khusus di integrasi berkelanjutan
- Metadata EXIF termasuk GPS dihapus di perangkat sebelum unggah
- Ketentuan Layanan menyebutkan bahwa foto diproses layanan AI pihak ketiga
- Pengguna bisa menghapus akun beserta seluruh datanya
- Batas laju per alamat IP dan per pengguna pada seluruh endpoint tulis

### 6.4 Aksesibilitas

- Target sentuh minimal 48 dp
- Rasio kontras minimal AA, diuji di bawah sinar matahari langsung
- Ikon selalu berlabel teks, tidak ada ikon tanpa keterangan
- Skala teks mengikuti pengaturan sistem sampai 200 persen tanpa tata letak rusak
- Semantik untuk pembaca layar pada seluruh kontrol
- Preferensi kurangi gerak dihormati, animasi peta dan karakter dimatikan

### 6.5 Kompatibilitas

- Android 8.0 ke atas, sekitar 98 persen perangkat aktif
- Diuji pada perangkat dengan RAM 2 GB, bukan perangkat unggulan
- iOS masuk fase berikutnya, kode disiapkan tapi tidak diuji di MVP

---

## 7. Tumpukan Teknologi

### 7.1 Aplikasi mobile

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Kerangka kerja | Flutter 3.24 | Satu basis kode, kinerja animasi peta mendekati native, dukungan kamera matang |
| Manajemen state | Riverpod 2 dengan generator kode | Aman tipe, mudah diuji, cocok untuk state asinkron campuran lokal dan jarak jauh |
| Navigasi | go_router | Rute deklaratif, tautan dalam untuk membuka pertanyaan forum dari notifikasi |
| Basis data lokal | Drift di atas SQLite | Kueri aman tipe, wajib untuk mode luring dan antrean keluar |
| Klien HTTP | Dio dan Retrofit | Pemotong permintaan untuk token dan idempotensi, klien digenerate dari OpenAPI |
| Inferensi model | tflite_flutter | Menjalankan model di perangkat, tanpa biaya dan tanpa koneksi |
| Kamera dan galeri | image_picker, flutter_image_compress | Kompresi di isolate sebelum unggah |
| Pemutar video | video_player, chewie, youtube_player_flutter | Video milik sendiri dan video sematan dari kanal resmi |
| Grafik vektor | flutter_svg | Peta terasering dan ikon, satu berkas untuk semua kerapatan layar |
| Animasi | Lottie untuk pencapaian, AnimationController untuk sisanya | Lottie hanya di momen perayaan, selebihnya animasi bawaan lebih ringan |
| Notifikasi | firebase_messaging, flutter_local_notifications | Pengingat periksa tanaman dan balasan forum |
| Penyimpanan aman | flutter_secure_storage | Token, bukan SharedPreferences |
| Lokasi | geolocator | Opsional, untuk saran forum sekabupaten |

### 7.2 Backend

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Kerangka kerja | NestJS 10, TypeScript | Struktur modul jelas untuk tim beberapa orang, dukungan OpenAPI bawaan |
| ORM | Prisma 5 | Migrasi berbasis skema, aman tipe dari basis data sampai pengendali |
| Basis data | PostgreSQL lewat Supabase | Relasional sesuai kebutuhan berjenjang, ekstensi pgvector untuk RAG |
| Pencarian vektor | pgvector | Tidak perlu basis data vektor terpisah, satu instans untuk semua |
| Autentikasi | Supabase Auth | Email, kata sandi, dan Google dalam satu paket |
| Penyimpanan berkas | Supabase Storage untuk foto, Cloudflare R2 untuk video | R2 tanpa biaya keluar data, penting untuk video |
| Antrean | BullMQ dengan Redis Upstash | Pekerjaan asinkron: pembuatan sematan, notifikasi, evaluasi model |
| Realtime | Supabase Realtime | Balasan forum masuk tanpa muat ulang |
| Layanan AI | Python FastAPI terpisah | Bahasa berbeda, profil memori berbeda, penskalaan berbeda |
| Pemantauan | Sentry dan log terstruktur | Pelacakan galat dan corong penyelesaian Petak |

### 7.3 Computer vision

| Komponen | Pilihan | Alasan |
|---|---|---|
| Arsitektur | MobileNetV3-Large, pemindahan pembelajaran | Rasio akurasi terhadap ukuran terbaik untuk perangkat kelas bawah |
| Pembanding | EfficientNet-Lite0 | Dilatih paralel, yang menang di validasi lapangan yang dipakai |
| Kerangka latih | TensorFlow 2 dan Keras | Jalur ekspor ke TFLite paling matang |
| Kuantisasi | **Float 16 bit** | Bilangan bulat penuh 8 bit sudah diuji dan **ditolak**: akurasi jatuh dari 90,2 ke 59,0 persen. Penyebabnya `hard_swish` dan blok squeeze-excite pada MobileNetV3 yang rusak saat dipaksa bilangan bulat. Float 16 memberi 6,00 MB tanpa kehilangan akurasi sama sekali. Rinciannya di 7.3.1 |
| Penyajian | Di perangkat lewat TFLite | Tanpa biaya inferensi, tanpa koneksi, tanpa latensi jaringan |
| Cadangan | Endpoint server dengan model yang sama | Untuk perangkat yang gagal memuat model |

**Dataset dan penanganannya:**

Hasil survei lengkap per 14 Agustus 2026. Kolom "citra asli" sengaja dipisahkan dari jumlah berkas, karena banyak penerbit sudah mencampur hasil augmentasi ke dalam dataset dan jumlah berkas menjadi menyesatkan.

| Komoditas | Dataset | Citra asli | Lisensi | Status |
|---|---|---|---|---|
| **Cabai** | `abdulrosyidkun/chili-leaf-disease-ponorogo-east-java` | 394, 4 folder | **MIT** | **Dipakai.** Bersih, hampir seimbang, satu daun per foto, tanpa augmentasi bawaan |
| Cabai | `shuvokumarbasak2030/chili-pepper-multi-source-dataset-bd` | 894 unik dari 17.340 berkas | tidak jelas | Ditolak. Kelasnya varietas cabai bukan penyakit, dan 894 citra diekspor ulang dalam 5 format sehingga tampak berlipat |
| Cabai | `prudhvi143413s/anthracnose-disease-in-chilli-mobile-captured` | 507 | CC0-1.0 | Ditolak. Difoto satu rumpun dari jarak 1 sampai 2 meter, gejalanya tidak terlihat pada resolusi itu |
| Cabai | `prudhvi143413s/anthracnose-disease-in-chili-palnadu-ap` | 870 | tidak jelas | Ditolak. Banyak berkas berupa kolase beberapa foto dalam satu bingkai, kelas sehat semuanya buah merah sementara kelas sakit semuanya buah hijau sehingga model belajar warna bukan penyakit, dan ditemukan berkas berwatermark Alamy |
| **Terong** | `sujaykapadnis/eggplant-disease-recognition-dataset` | 1.400, 7 kelas seimbang | — | Rencana berikutnya. **Hanya folder `Original Images (Version 02)` yang boleh dipakai**, folder `Augmented` dilarang karena melanggar aturan 1 di bawah |
| Padi | `tedisetiady/leaf-rice-disease-indonesia` | 240, 3 kelas | — | Belum cukup. Perlu ditambah |
| Padi | Zenodo `10.5281/zenodo.15817084` | 465 MB | **CC-BY-4.0** | Kandidat penambal, punya DOI sehingga bisa disitasi resmi di proposal |
| Terong | Zenodo `10.5281/zenodo.15527092` | resolusi tinggi | **CC-BY-4.0** | Kandidat cadangan, punya DOI |

**Temuan yang mengubah asumsi:** seluruh dataset yang layak pakai berisi foto daun tunggal berlatar polos, bukan foto kebun. Ini terdengar buruk, tetapi `5.2 US-07` justru menyuruh pengguna memotret dengan cara yang sama — satu daun, latar polos, cahaya cukup — sehingga celah domainnya jauh lebih sempit daripada kasus terburuk. Yang tetap wajib: mengukur pada foto lapangan asli dari demplot, sesuai aturan 2 di bawah.

**Tiga aturan pelatihan yang tidak boleh dilanggar:**

1. **Pisahkan latih, validasi, dan uji sebelum augmentasi, bukan sesudah.** Kalau dibalik, citra hasil augmentasi dari foto yang sama bisa muncul di latih dan uji sekaligus, dan akurasi validasi jadi indah tapi bohong. Ini kesalahan paling umum pada dataset pertanian yang sudah diaugmentasi penerbitnya.
2. **Ukur pada himpunan uji lapangan yang terpisah.** Foto berlatar putih tidak mewakili pekarangan. Kumpulkan minimal 300 foto lapangan asli dari demplot tim dan dari peserta uji coba, dan jadikan itu ukuran sebenarnya.
3. **Jangan pernah menampilkan satu label tunggal.** Tampilkan setiap dugaan yang keyakinannya di atas 0,10, maksimal tiga. Aturan lama "selalu tiga teratas" tidak lagi berlaku: dengan model Cabai yang hanya punya 3 kelas, "tiga teratas" berarti menampilkan seluruh isi model dan tidak menyampaikan informasi apa pun. Ambang "belum yakin" ada di 7.3.1.

#### 7.3.1 Hasil terukur, Cabai v1.0.0

Dilatih 14 Agustus 2026. Angka di bawah diukur pada himpunan uji yang dipisahkan sebelum augmentasi dan tidak pernah disentuh selama pelatihan maupun kuantisasi.

| | |
|---|---|
| Kelas | `BERCAK_DAUN`, `SEHAT`, `VIRUS_KUNING_KERITING` — **urut abjad, urutan ini adalah kontrak dengan klien** karena TFLite mengembalikan indeks bukan nama |
| Pembagian data | 273 latih, 58 validasi, 61 uji |
| Akurasi uji | **90,16 persen**, 55 dari 61 |
| Ukuran berkas | **6,00 MB**, float 16 |
| Masukan | 224 x 224, `float32`, nilai piksel mentah 0 sampai 255. Normalisasi sudah berada di dalam model, klien tidak perlu melakukannya |

**Dua kelas digabung.** Folder `curly` dan `yellow_light` pada dataset sumber digabung menjadi satu label `VIRUS_KUNING_KERITING`. Keduanya gejala infeksi virus yang sama dan penanganannya identik, sehingga memisahkannya hanya memaksa model membedakan hal yang tidak perlu dibedakan oleh pengguna.

**Profil kesalahan, lebih penting daripada angka akurasi:**

| Sebenarnya | Ditebak `BERCAK_DAUN` | Ditebak `SEHAT` | Ditebak `VIRUS_KUNING_KERITING` |
|---|---|---|---|
| `BERCAK_DAUN` | 15 | **1** | 0 |
| `SEHAT` | 0 | 14 | 0 |
| `VIRUS_KUNING_KERITING` | 2 | **3** | 26 |

Presisi kelas `SEHAT` hanya 0,778. Artinya ketika model menyatakan tanaman sehat, satu dari lima vonis itu keliru, dan 4 dari 47 daun sakit dinyatakan sehat. Ini arah kesalahan yang paling merugikan: pengguna tidak berbuat apa-apa dan penyakit menyebar.

**Ambang keyakinan, menjawab Q2 di Bagian 12:**

| Ambang | Hasil yang ditampilkan | Akurasi hasil yang ditampilkan |
|---|---|---|
| 0,60 | 98,4 persen | 91,7 persen |
| **0,70** | 90,2 persen | 92,7 persen |
| 0,80 | 86,9 persen | 94,3 persen |
| 0,90 | 73,8 persen | 97,8 persen |

Keputusan: **ambang umum 0,70**, dan **ambang khusus 0,85 untuk vonis `SEHAT`**. Ambang dibuat tidak simetris dengan sengaja, karena akibat dua jenis kesalahan tidak setara. Salah menyatakan sakit padahal sehat hanya membuat pengguna memotret ulang. Salah menyatakan sehat padahal sakit membuat pengguna kehilangan satu musim.

**Batas yang diakui terbuka:**

- **Antraknosa, yang petani sebut patek, belum didukung.** Gejalanya berada di buah sedangkan seluruh dataset yang layak adalah penyakit daun. Dua dataset antraknosa sudah diuji dan ditolak dengan alasan yang tercatat di tabel dataset. Jalan masuknya adalah demplot tim, bukan menambal dengan data bermutu rendah. Model yang mengaku tidak tahu lebih aman daripada model yang menebak dari warna buah.
- **Angka 90,16 persen berasal dari 61 foto.** Satu foto salah menggeser akurasi sekitar 1,6 poin, jadi ketidakpastiannya besar dan harus disebutkan apa adanya saat presentasi.
- **Belum pernah diuji pada foto lapangan asli.** Sampai aturan 2 dipenuhi, angka ini adalah akurasi pada kondisi laboratorium.

### 7.4 Asisten AI dengan basis pengetahuan

Alur lengkapnya:

```
Hasil klasifikasi + pertanyaan pengguna
  → Rakit konteks: komoditas, umur, 10 pindai terakhir, 6 pesan terakhir
  → Ubah pertanyaan jadi vektor sematan
  → Cari kemiripan di pgvector, ambil 6 potongan teratas
  → Saring ulang, sisakan 3 potongan paling relevan
  → Rakit perintah: konteks + potongan + pertanyaan
  → Panggil model bahasa, alirkan jawaban
  → Sertakan rujukan dari potongan yang dipakai
```

| Komponen | Pilihan | Alasan |
|---|---|---|
| Model sematan | multilingual-e5-base | Mendukung bahasa Indonesia dengan baik, bisa dijalankan sendiri, tanpa biaya per panggilan |
| Penyimpanan vektor | pgvector di Supabase | Satu instans basis data, indeks HNSW |
| Ukuran potongan | 500 sampai 800 token, tumpang tindih 100 | Cukup panjang untuk konteks utuh, cukup pendek untuk presisi |
| Model bahasa | Rantai penyedia dengan cadangan berlapis | Kuota gratis berubah sewaktu-waktu |
| Alur pengaliran | Server-Sent Events | Jawaban muncul kata demi kata, terasa jauh lebih cepat |

**Rantai penyedia, dicoba berurutan, dikonfigurasi di basis data supaya bisa diganti tanpa penerapan ulang:**

```
1. Model kelas ringan   (kuota gratis)  → pertanyaan umum
2. Model kelas menengah (kuota gratis)  → kalau yang pertama gagal
3. Penyedia kedua       (kuota gratis)  → kalau kuota penyedia pertama habis
4. Model berbayar                        → kalau seluruh kuota gratis habis
5. Antrean tunda dan notifikasi          → kalau semuanya gagal
```

**Sumber basis pengetahuan.** Seluruhnya dokumen terbuka dari lembaga resmi dan jurnal akses terbuka. Setiap potongan menyimpan judul, penerbit, tahun, dan tautan sumber, sehingga jawaban selalu bisa dilacak.

- Petunjuk teknis budidaya dari Balai Penelitian Tanaman Sayuran untuk cabai dan terong
- Petunjuk teknis dari Balai Besar Penelitian Tanaman Padi
- Materi penyuluhan dari Cybex Kementerian Pertanian
- Repositori PUSTAKA Kementerian Pertanian
- Lembar fakta hama dan penyakit dari CABI dan FAO
- Jurnal akses terbuka bidang perlindungan tanaman

**Aturan keras pada asisten:**

- Tidak menyebut merek dagang pestisida
- Tidak memberi dosis kimia spesifik, diarahkan ke penyuluh
- Wajib mencantumkan rujukan pada setiap jawaban yang bersifat anjuran
- Kalau potongan yang ditemukan tidak relevan, menjawab tidak tahu dan mengarahkan ke Warung Tani

Aturan kedua bukan sikap berhati-hati berlebihan. Anjuran dosis yang salah merugikan pengguna secara nyata dan menimbulkan tanggung jawab hukum yang tidak bisa ditanggung produk tahap awal.

### 7.5 Panel admin dan infrastruktur

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Panel admin | Next.js 14 dengan Refine di atas Supabase | Delapan alur admin sebagian besar CRUD dan antrean, Refine menyelesaikannya dalam hitungan hari |
| Penerapan backend | Railway atau VPS | Penerapan sederhana, biaya terprediksi |
| Penerapan panel | Vercel | Tanpa biaya pada tingkat awal |
| Integrasi berkelanjutan | GitHub Actions | Lint, uji, pembuatan APK, uji kebijakan keamanan baris |
| Pelatihan model | Google Colab atau Kaggle Notebook | GPU gratis, cukup untuk pemindahan pembelajaran |
| Pelacakan eksperimen | Berkas CSV di repositori | Skala proyek belum membutuhkan perkakas eksperimen |

### 7.6 Estimasi biaya bulanan tahap uji coba

| Komponen | Biaya |
|---|---|
| Supabase Pro | Rp 400.000 |
| Railway, dua kontainer | Rp 250.000 |
| Upstash Redis | Rp 0, tingkat gratis mencukupi |
| Cloudflare R2 | Rp 100.000 |
| Model bahasa | Rp 0 sampai 300.000, tingkat gratis pada skala uji coba |
| Vercel | Rp 0 |
| Domain dan lain-lain | Rp 100.000 |
| **Total** | **Rp 850.000 sampai 1.150.000** |

Biaya inferensi computer vision nol karena model berjalan di perangkat. Ini alasan utama memilih pendekatan di perangkat, bukan sekadar soal kecepatan.

---

## 8. Rencana Rilis

| Fase | Minggu | Keluaran | Kriteria selesai |
|---|---|---|---|
| F0 Fondasi | 1-2 | Skema Prisma, penyemaian data, rintisan OpenAPI, kebijakan keamanan baris, autentikasi | Swagger hidup di lingkungan uji hari ke-5, mobile bisa membangun layar dari rintisan |
| F1 Kelas Tandur | 3-5 | Peta, lesson, latihan, ujian, XP, runtutan, unduh luring | Satu pengguna bisa menyelesaikan Petak Cabai 1 dari nol |
| F2 Periksa Tanaman | 6-8 | Model TFLite tertanam, kamera, linimasa, RAG, asisten | Satu pengguna bisa mendaftarkan tanaman, memindai, dan berdiskusi |
| F3 Warung Tani | 9-10 | Forum, suara, balasan berjenjang, jawaban terbaik, reputasi | Satu pertanyaan bisa dibuat dari hasil pindai dan dijawab |
| F4 Uji lapangan | 10-11 | Uji dengan 20 sampai 30 peserta | Data nyata masuk, foto lapangan terkumpul, model dilatih ulang |
| F5 Pemantapan | 12 | Pengerasan, uji beban, audit keamanan baris, uji perangkat kelas bawah | Seluruh alur lulus uji, crash-free di atas 99,5 persen |

**Jalur paralel sepanjang proyek:**

| Jalur | Minggu | Keluaran |
|---|---|---|
| Kurikulum | 1-10 | Cabai Petak 1, Terong Petak 1, Padi Petak 1. Total 15 Unit, 60 lesson |
| Model CV | 2-11 | Model dasar minggu 4, dilatih ulang dengan foto lapangan minggu 11 |
| Basis pengetahuan RAG | 3-9 | 200 sampai 300 potongan dari sumber resmi, tertinjau |
| Demplot tim | 1-12 | 30 polybag cabai, 20 polybag terong, sumber foto lapangan asli |
| Aset visual | 1-6 | Peta terasering, karakter, ikon, ilustrasi perkenalan |

**Demplot ditanam minggu 1** supaya menghasilkan foto gejala asli mulai minggu 5 dan panen sekitar minggu 12, tepat saat presentasi.

---

## 9. Risiko

| Risiko | Dampak | Kemungkinan | Mitigasi |
|---|---|---|---|
| **Dataset cabai terlalu kecil** | Model cabai jelek padahal cabai adalah komoditas utama | **Terjadi, sebagian** | Terkonfirmasi 14 Agustus 2026. Dari 6 dataset cabai yang disurvei, hanya 1 yang layak, berisi 394 foto dan 3 kelas. Model tetap mencapai 90,16 persen lewat pemindahan pembelajaran dengan tulang punggung dibekukan dan augmentasi berat saat pelatihan. Cabai diluncurkan dengan penanda beta dan ambang 0,70 sesuai rencana mitigasi |
| **Antraknosa tidak terdeteksi sama sekali** | Patek adalah momok nomor satu cabai di Indonesia. Aplikasi yang tidak mengenalinya kehilangan kepercayaan pengguna | **Terjadi** | Gejalanya di buah, seluruh dataset layak adalah penyakit daun. Dua dataset antraknosa diuji dan ditolak: yang satu difoto dari jarak 2 meter, yang satu berisi kolase dan bias warna buah merah lawan hijau. Ditangani lewat demplot, bukan dengan menambal data bermutu rendah. Sampai itu ada, aplikasi menyatakan penyakit ini belum didukung |
| Celah domain foto laboratorium ke foto lapangan | Akurasi jatuh dari 95 persen di validasi ke bawah 60 persen di lapangan | Tinggi | Diperkecil oleh desain: `5.2 US-07` menyuruh pengguna memotret satu daun berlatar polos, sama dengan cara dataset dibuat. Tetap wajib diukur pada himpunan uji lapangan terpisah dari demplot |
| Kebocoran data karena augmentasi sebelum pemisahan | Akurasi terlihat bagus tapi palsu | Sedang | Pisahkan berdasarkan citra asli, bukan berdasarkan berkas. Ditulis di daftar periksa pelatihan. Pada dataset terong, folder `Augmented` dilarang dipakai dan hanya `Original Images` yang boleh masuk pelatihan |
| **Kuantisasi merusak model tanpa gejala yang terlihat** | Semua metrik pelatihan tampak sehat, kerusakan baru muncul setelah model dipasang di perangkat | **Terjadi** | Terkonfirmasi: INT8 penuh menjatuhkan akurasi Cabai dari 90,2 ke 59,0 persen dan membuat model kebanyakan memvonis `SEHAT`. Mitigasi tetap: setiap berkas TFLite wajib diukur ulang pada himpunan uji setelah konversi, bukan dianggap sama dengan model asalnya |
| Kurikulum tidak selesai | Konten kosong, produk tidak berguna | Tinggi | Dibatasi tiga Petak. Format kartu bukan video. Peninjau ahli diamankan minggu 1 |
| Asisten memberi anjuran berbahaya | Pengguna rugi, tanggung jawab hukum | Sedang | Larangan dosis kimia dan merek dagang di perintah sistem, diuji dengan berkas uji adversarial |
| RAG mengambil potongan tidak relevan lalu model mengarang | Jawaban terdengar meyakinkan tapi salah | Sedang | Ambang skor kemiripan, penyaringan ulang, instruksi menjawab tidak tahu, rujukan wajib ditampilkan |
| Kuota gratis penyedia model dipangkas mendadak | Fitur asisten mati | Sedang | Rantai empat penyedia dikonfigurasi di basis data, ganti tanpa penerapan ulang |
| Forum sepi saat peluncuran | Fitur terlihat mati | Tinggi | Isi 30 pertanyaan dan jawaban nyata dari uji lapangan sebelum peluncuran. Tim menjawab aktif di bulan pertama |
| Ukuran APK membengkak karena model dan aset | Pengguna enggan mengunduh | Sedang | Pemisahan APK per ABI, model dikuantisasi, aset peta berupa SVG, video tidak dibundel |
| Enam orang menghasilkan enam gaya kode | Integrasi kacau di minggu akhir | Tinggi | Berkas kontrak agent di repositori, batas modul dipaksa linter, integrasi tiap Rabu |

---

## 10. Di Luar Cakupan

Ditulis eksplisit supaya tidak ada yang diam-diam mengerjakannya:

- Marketplace, pembayaran, escrow, pengiriman
- Bursa kerja lahan
- Program mentor berbayar dan sesi konsultasi
- Pembacaan nota atau dokumen apa pun
- Petak simulasi dan mesin pertumbuhan
- Papan info panen
- Sistem tugas berjadwal per Hari Setelah Tanam dengan verifikasi bukti
- Sertifikasi resmi
- Sensor lapangan dan citra satelit
- **Data cuaca sebagai konteks asisten.** Sebelumnya disebut di `5.2 US-08` dan `7.4`, dicoret 14 Agustus 2026 karena tidak pernah punya sumber data, tidak ada di skema basis data, tidak ada di kontrak layanan AI, dan tidak ada jatah waktunya dalam 12 minggu. Konteks asisten sekarang: komoditas, umur tanaman, hasil klasifikasi, 10 pindai terakhir, dan 6 pesan terakhir
- Deteksi penyakit pada buah, termasuk antraknosa. Alasannya di Bagian 9
- Komoditas selain Cabai Rawit, Padi, dan Terong
- Mengunduh dan menghosting ulang video pihak lain
- Aplikasi iOS, dukungan banyak bahasa
- Peternakan dan perikanan

Sistem tugas berjadwal dikeluarkan karena pengetahuan kapan memupuk dan apa yang diamati sekarang disampaikan lewat kurikulum di Kelas Tandur, bukan lewat mesin jadwal terpisah. Ini memangkas sekitar sepuluh tabel dan seluruh logika verifikasi.

---

## 11. Asumsi yang Harus Divalidasi

| # | Asumsi | Cara validasi | Kapan |
|---|---|---|---|
| A1 | Foto daun dari ponsel kelas bawah cukup jelas untuk diklasifikasi | Uji 50 foto dari demplot pada model dasar | **Minggu 5** |
| A2 | Model yang dilatih dari data Kaggle bertahan pada foto pekarangan Indonesia | Ukur pada himpunan uji lapangan 300 foto | **Minggu 8** |
| A3 | Pengguna mau memindai berulang, bukan sekali coba | Ukur pindai per pengguna per minggu selama uji lapangan | Minggu 10 |
| A4 | Jawaban asisten dinilai berguna oleh pengguna nyata | Tombol membantu atau tidak pada tiap jawaban | Minggu 10 |
| A5 | Forum bisa hidup tanpa insentif uang | Ukur rasio pertanyaan terjawab dalam 24 jam | Minggu 11 |
| A6 | Kartu bergambar cukup efektif menggantikan sebagian besar video | Bandingkan skor latihan antara lesson kartu dan lesson video | Minggu 10 |

A1 dan A2 adalah yang paling berbahaya. Kalau keduanya gagal, fitur inti kedua tidak berfungsi. Validasinya dijadwalkan sedini mungkin dan memakai demplot tim sebagai sumber foto, bukan menunggu uji lapangan.

---

## 12. Pertanyaan Terbuka

| # | Pertanyaan | Butuh diputuskan sebelum |
|---|---|---|
| Q1 | Apakah forum butuh moderasi otomatis sejak awal atau cukup laporan manual? | Minggu 9 |
| ~~Q2~~ | ~~Berapa ambang keyakinan yang tepat untuk menyatakan belum yakin?~~ **Terjawab 14 Agustus 2026: 0,70 umum, 0,85 khusus vonis `SEHAT`.** Dasar pengukurannya di 7.3.1. Ditinjau ulang setelah ada data uji lapangan | ~~Minggu 8~~ selesai |
| Q3 | Apakah reputasi forum perlu memberi hak istimewa, misalnya moderasi terbatas? | Minggu 10 |
| Q4 | Siapa menanggung risiko kalau anjuran asisten merugikan pengguna? | Sebelum Ketentuan Layanan terbit |

Q4 membutuhkan masukan hukum, bukan keputusan tim teknis.
