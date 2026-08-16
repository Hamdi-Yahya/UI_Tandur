# DESAIN — TANDUR

| | |
|---|---|
| **Versi** | 1.0 |
| **Tanggal** | 11 Agustus 2026 |
| **Platform** | Flutter, Android prioritas |
| **Viewport acuan** | 360 x 800 dp, kerapatan 2x |
| **Dokumen terkait** | `PRD.md`, `API_DOCS.md` |

---

## 1. Arah Desain

### 1.1 Masalah desainnya

Tiga fitur dengan watak yang bertolak belakang harus tinggal dalam satu aplikasi:

| Fitur | Watak | Kalau salah |
|---|---|---|
| Kelas Tandur | Hangat, bermain, memberi hadiah | Terasa kekanakan, orang yang sudah bertani merasa diremehkan |
| Periksa Tanaman | Tenang, klinis, dapat dipercaya | Terlalu meriah, orang tidak percaya diagnosisnya |
| Warung Tani | Padat, cepat dipindai mata | Terlalu longgar, sedikit informasi per layar, orang malas menggulir |

Menyeragamkan ketiganya menghasilkan produk yang salah di ketiga tempat. Jadi ketiganya **sengaja dibedakan**, disatukan oleh skala tipografi, skala jarak, dan empat warna inti yang sama.

### 1.2 Sumber bentuk

Bentuknya diambil dari benda nyata di dunia subjeknya, bukan dari tren antarmuka.

**Petak sawah terasering.** Sawah di lereng Jawa berbentuk bidang segi empat tak beraturan yang bertumpuk mengikuti garis kontur. Bentuk itu jadi struktur peta pembelajaran: setiap level adalah satu petak, dan petak-petak itu naik mengikuti kontur, bukan berbaris di jalur berkelok.

Ini penting karena jalur berkelok dengan lingkaran bernomor adalah bentuk baku aplikasi belajar bahasa, dan memakainya berarti produk ini terlihat seperti tiruan. Terasering adalah bentuk yang sama fungsinya tetapi berasal dari dunia pertanian itu sendiri.

**Warna dari komoditasnya.** Merah cabai, ungu terong, kuning padi. Tiga komoditas yang diajarkan sekaligus menjadi tiga aksen sistem. Ungu terong jarang dipakai aplikasi pertanian, dan justru itu yang membuat produk ini punya wajah sendiri.

### 1.3 Satu risiko yang diambil

**Animasi pengairan petak.** Saat sebuah Petak selesai, bidangnya terisi air dari sudut kiri atas ke kanan bawah, permukaannya memantulkan langit, lalu tunas padi muncul satu per satu. Sekitar 1.400 milidetik.

Alasannya: mengairi sawah adalah tindakan nyata yang menandai satu tahap selesai di pertanian. Perayaan ini berasal dari pekerjaan yang sedang dipelajari, bukan dari kotak konfeti yang bisa dipasang di aplikasi apa pun.

Ini satu-satunya tempat animasi dibiarkan mewah. Seluruh gerak lain di aplikasi ditahan pada 200 milidetik dan hanya untuk memberi umpan balik, tidak untuk hiburan.

---

## 2. Token Desain

### 2.1 Warna

```dart
// lib/core/theme/tokens.dart

class Warna {
  // Tinta dan permukaan
  static const tanah      = Color(0xFF241F1A); // teks utama, hampir hitam kecokelatan
  static const tanahLemah = Color(0xFF5C544A); // teks sekunder
  static const tanahSamar = Color(0xFF8C8377); // teks tersier, placeholder
  static const embun      = Color(0xFFF4F6F1); // latar aplikasi, putih kehijauan dingin
  static const kertas     = Color(0xFFFFFFFF); // permukaan kartu
  static const garis      = Color(0xFFDFE3D9); // batas dan pemisah

  // Aksen komoditas, sekaligus aksen sistem
  static const daun       = Color(0xFF167A4B); // hijau utama, aksi dan navigasi
  static const daunMuda   = Color(0xFF3FB07A); // berhasil, progres
  static const daunSamar  = Color(0xFFE3F0E7); // latar tenang untuk keadaan hijau
  static const cabai      = Color(0xFFDC3A2B); // temuan penyakit, peringatan, nyawa
  static const cabaiSamar = Color(0xFFFCEBE8); // latar tenang untuk keadaan merah
  static const terong     = Color(0xFF6B4A9E); // aksen kedua, tanda Warung Tani
  static const terongSamar= Color(0xFFF0EBF8);
  static const padi       = Color(0xFFE0A62C); // XP, runtutan, lencana
  static const padiSamar  = Color(0xFFFDF3E0);

  // Air, hanya dipakai pada animasi pengairan dan peta
  static const air        = Color(0xFF7FB5C7);
  static const airDalam   = Color(0xFF4A88A0);
}
```

Latar aplikasi sengaja digeser ke hijau dingin `#F4F6F1`, bukan krem hangat. Krem hangat berpasangan aksen tanah liat adalah kombinasi yang muncul di terlalu banyak aplikasi, dan tidak mengatakan apa pun tentang produk ini.

**Pemakaian warna per fitur:**

| Fitur | Warna dominan | Aksen |
|---|---|---|
| Kelas Tandur | `daun` dan `daunSamar` | `padi` untuk XP dan runtutan |
| Periksa Tanaman | `kertas` dan `garis`, hampir netral | `cabai` hanya untuk temuan |
| Warung Tani | `embun` dan `tanah` | `terong` untuk label dan jawaban terbaik |

Periksa Tanaman sengaja dibiarkan hampir tanpa warna. Layar diagnosis yang meriah membuat orang tidak percaya pada isinya.

### 2.2 Tipografi

Tiga peran, tiga keluarga huruf, dipilih dengan alasan masing-masing.

| Peran | Keluarga | Alasan |
|---|---|---|
| Tampilan | **Bricolage Grotesque** | Grotesk variabel dengan sumbu lebar dan optis, punya watak tanpa jatuh ke serif klasik. Dipakai terbatas: judul layar, angka besar, nama Petak |
| Isi | **Plus Jakarta Sans** | Dirancang Tokotype untuk penjenamaan kota Jakarta. Huruf buatan Indonesia untuk produk Indonesia, dan bentuknya memang bersih dan mudah dibaca pada ukuran kecil |
| Data | **JetBrains Mono** | Angka lebar sama, penting untuk Hari Setelah Tanam, tingkat keyakinan, dosis, dan hitungan suara yang berubah-ubah tanpa membuat tata letak bergeser |

Semuanya tersedia di Google Fonts dengan lisensi Open Font License.

```dart
class Teks {
  // Bricolage Grotesque
  static const tampilanBesar  = TextStyle(fontSize: 34, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.8);
  static const tampilanSedang = TextStyle(fontSize: 26, height: 1.20, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static const tampilanKecil  = TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w600, letterSpacing: -0.3);

  // Plus Jakarta Sans
  static const judul          = TextStyle(fontSize: 18, height: 1.35, fontWeight: FontWeight.w700);
  static const isiBesar       = TextStyle(fontSize: 16, height: 1.55, fontWeight: FontWeight.w400);
  static const isi            = TextStyle(fontSize: 15, height: 1.55, fontWeight: FontWeight.w400);
  static const isiTebal       = TextStyle(fontSize: 15, height: 1.50, fontWeight: FontWeight.w600);
  static const kecil          = TextStyle(fontSize: 13, height: 1.45, fontWeight: FontWeight.w400);
  static const label          = TextStyle(fontSize: 11, height: 1.30, fontWeight: FontWeight.w700, letterSpacing: 0.6);

  // JetBrains Mono
  static const angkaBesar     = TextStyle(fontSize: 28, height: 1.10, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]);
  static const angka          = TextStyle(fontSize: 14, height: 1.30, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()]);
}
```

Ukuran isi 15 sampai 16 dengan tinggi baris 1,55 dipilih untuk dibaca di luar ruangan sambil berdiri. Lebih kecil dari itu tidak terbaca di bawah matahari.

### 2.3 Jarak, sudut, dan bayangan

```dart
class Jarak {
  static const xs = 4.0;
  static const s  = 8.0;
  static const m  = 12.0;
  static const l  = 16.0;   // padding tepi layar
  static const xl = 24.0;   // jarak antar bagian
  static const xxl= 32.0;
}

class Sudut {
  static const kecil  = 8.0;
  static const sedang = 12.0;   // kartu
  static const besar  = 20.0;   // lembar bawah
  static const penuh  = 999.0;  // pil dan lencana
}
```

**Bayangan hampir tidak dipakai.** Pemisahan permukaan dilakukan dengan batas `garis` setebal 1 dp. Bayangan hanya pada elemen yang benar-benar melayang: bilah navigasi bawah, lembar bawah, dan tombol tindakan mengambang.

```dart
const bayanganMelayang = BoxShadow(
  color: Color(0x14241F1A), blurRadius: 16, offset: Offset(0, 4),
);
```

Alasannya bukan selera. Bayangan yang bertumpuk di seluruh kartu memaksa lapisan penggambaran tambahan dan menurunkan laju bingkai pada perangkat kelas bawah, yang justru perangkat sasaran produk ini.

### 2.4 Gerak

| Jenis | Durasi | Kurva |
|---|---|---|
| Umpan balik ketukan | 120 ms | `Curves.easeOut` |
| Perpindahan layar | 240 ms | `Curves.easeInOutCubic` |
| Lembar bawah | 280 ms | `Curves.easeOutCubic` |
| Progres bertambah | 400 ms | `Curves.easeOutQuart` |
| **Pengairan petak** | **1.400 ms** | Berlapis, lihat 4.3 |

Preferensi kurangi gerak sistem dihormati. Saat aktif, seluruh animasi diganti transisi lesap 100 milidetik, termasuk pengairan petak yang jadi tampilan sebelum dan sesudah tanpa gerak.

---

## 3. Arsitektur Navigasi

```
Bilah bawah, empat isian

  [ Kelas ]   [ Periksa ]   [ Warung ]   [ Saya ]
    daun         cabai        terong       tanah
```

Ikon berlabel teks, selalu. Ikon tanpa keterangan adalah sumber kebingungan terbesar pada pengguna yang tidak terbiasa dengan konvensi antarmuka.

Isian tengah, Periksa, dibuat sedikit lebih menonjol dengan lingkaran terisi karena itu tindakan yang paling sering dibutuhkan mendadak, saat pengguna sedang berdiri di depan tanamannya.

```
Peta rute

/onboarding                     perkenalan, sekali
/onboarding/komoditas           pilih komoditas
/onboarding/pengalaman          sudah pernah menanam atau belum

/kelas                          peta terasering
/kelas/petak/:id                daftar unit
/kelas/unit/:id                 daftar lesson
/kelas/lesson/:id               kartu atau video
/kelas/latihan/:id              latihan
/kelas/ujian/:id                ujian petak

/periksa                        kamera
/periksa/hasil/:scanId          hasil klasifikasi
/periksa/diskusi/:scanId        percakapan asisten
/periksa/tanaman                daftar tanaman saya
/periksa/tanaman/:id            linimasa satu tanaman

/warung                         daftar pertanyaan
/warung/t/:komoditas            saring per komoditas
/warung/tanya                   buat pertanyaan
/warung/p/:id                   detail pertanyaan

/saya                           profil, lencana, pengaturan
```

---

## 4. Layar Kunci

### 4.1 Perkenalan

Empat layar, satu ilustrasi, satu kalimat pembuka, dua baris penjelas. Tidak ada tur bergelembung yang menempel di antarmuka.

```
┌──────────────────────────────────────┐
│                            Lewati    │
│                                      │
│                                      │
│         ┌─────────────────┐          │
│         │                 │          │
│         │   ILUSTRASI     │          │
│         │   pekarangan    │          │
│         │   dan polybag   │          │
│         │                 │          │
│         └─────────────────┘          │
│                                      │
│                                      │
│   Mulai dari                         │
│   pekarangan sendiri.                │  ← Bricolage 26
│                                      │
│   Tiga puluh polybag cabai cukup     │  ← Jakarta 16
│   untuk mulai. Tidak perlu sawah.    │
│                                      │
│                                      │
│   ●  ○  ○  ○                         │
│                                      │
│   ┌────────────────────────────┐     │
│   │        Lanjut              │     │  ← daun, tinggi 52
│   └────────────────────────────┘     │
└──────────────────────────────────────┘
```

Urutan empat layar:

| # | Judul | Isi |
|---|---|---|
| 1 | Mulai dari pekarangan sendiri | Menetapkan bahwa ini bisa dilakukan tanpa lahan |
| 2 | Belajar sambil menanam | Kelas Tandur, peta terasering terlihat di ilustrasi |
| 3 | Daunnya kenapa? Foto saja | Periksa Tanaman, ilustrasi ponsel mengarah ke daun bercak |
| 4 | Ada yang lebih dulu mengalami | Warung Tani, ilustrasi percakapan |

Lalu pemilihan komoditas:

```
┌──────────────────────────────────────┐
│  ←                                   │
│                                      │
│   Mau mulai dari mana?               │
│   Bisa pilih lebih dari satu.        │
│                                      │
│   ┌──────────────┐ ┌──────────────┐  │
│   │      🌶       │ │      🍆       │  │
│   │              │ │              │  │
│   │ Cabai Rawit  │ │   Terong     │  │
│   │              │ │              │  │
│   │ 90 hari      │ │ 100 hari     │  │
│   │ 30 polybag   │ │ 20 polybag   │  │
│   └──────────────┘ └──────────────┘  │
│                                      │
│   ┌──────────────┐                   │
│   │      🌾       │                   │
│   │              │                   │
│   │    Padi      │                   │
│   │              │                   │
│   │ 110 hari     │                   │
│   │ Perlu sawah  │                   │
│   └──────────────┘                   │
│                                      │
│   ┌────────────────────────────┐     │
│   │        Lanjut              │     │
│   └────────────────────────────┘     │
└──────────────────────────────────────┘
```

Kartu terpilih mendapat batas `daun` setebal 2 dp dan latar `daunSamar`. Ikon komoditas berupa gambar vektor sendiri, bukan emoji, tetapi emoji dipakai di sketsa ini untuk keringkasan.

Lalu satu pertanyaan terakhir: sudah pernah menanam atau belum. Jawabannya menentukan layar pertama setelah masuk, bukan mengunci apa pun.

**Pendaftaran akun ditunda.** Pengguna baru diminta mendaftar setelah menyelesaikan lesson pertama atau pindai pertama, saat dia sudah melihat nilai aplikasinya.

### 4.2 Peta Kelas Tandur

Ini layar utama dan tempat sebagian besar identitas visual produk berada.

```
┌──────────────────────────────────────┐
│  🔥 12   ⚡ 1.240   ❤❤❤❤❤            │  ← runtutan, XP, nyawa
├──────────────────────────────────────┤
│  ● Cabai    ○ Terong    ○ Padi       │  ← tab komoditas
├──────────────────────────────────────┤
│                                      │
│                     ╱▔▔▔▔▔╲          │
│                   ╱  C4     ╲        │  ← petak terkunci, abu
│                  ╱   🔒      ╲       │
│                 ╲____________╱       │
│                                      │
│              ╱▔▔▔▔▔▔╲                │
│            ╱   C3      ╲             │  ← tersedia, berdenyut
│           ╱  Panen &    ╲            │
│          ╲   Pascapanen ╱            │
│           ╲____________╱             │
│                                      │
│        ╱▔▔▔▔▔▔▔╲     🧍              │  ← karakter berdiri
│      ╱    C2      ╲                  │     di petak berjalan
│     ╱  Hama &      ╲                 │
│    ╲   Penyakit    ╱  ▓▓▓▓▓░░ 60%    │
│     ╲_____________╱                  │
│                                      │
│   ╱▔▔▔▔▔▔▔▔╲                         │
│ ╱     C1       ╲                     │  ← selesai, tergenang air
│╱  Semai &       ╲   ✓                │     dengan tunas padi
│╲   Tanam        ╱                    │
│ ╲______________╱                     │
│                                      │
├──────────────────────────────────────┤
│  Kelas   Periksa   Warung   Saya     │
└──────────────────────────────────────┘
```

**Aturan bentuk petak.** Setiap petak adalah segi empat tak beraturan dengan sisi atas dan bawah sedikit melengkung mengikuti kontur. Lebar antara 180 dan 240 dp, tinggi 92 dp. Kemiringan sisi kiri dan kanan berbeda antar petak supaya tidak terlihat sebagai bentuk yang diulang. Petak digambar dengan `CustomPainter` dari data jalur, bukan gambar raster, sehingga tetap tajam di semua kerapatan layar dan ukuran berkasnya kecil.

**Lima keadaan petak:**

| Keadaan | Isi | Batas | Isyarat tambahan |
|---|---|---|---|
| Terkunci | `#E8EAE4` | `garis` | Gembok, teks syarat saat diketuk |
| Tersedia | `daunSamar` | `daun` 2 dp | Denyut halus 2 detik sekali |
| Berjalan | `daunSamar` | `daun` 2 dp | Bilah progres di bawah, karakter berdiri |
| Selesai | `air` dengan gradien | `airDalam` | Tunas padi kecil tersebar, centang |
| Sempurna | `air` dengan gradien | `padi` 2 dp | Tunas padi ditambah bulir keemasan |

**Kinerja.** Seluruh peta digambar dalam satu `CustomPaint`, bukan sebagai puluhan widget bertumpuk. Karakter dan lencana diletakkan sebagai `Positioned` di atasnya, masing-masing dibungkus `RepaintBoundary`. `InteractiveViewer` menangani geser dan zum dengan batas skala 0,8 sampai 1,6. Posisi terakhir disimpan di penyimpanan lokal.

**Bilah atas** tetap terlihat saat peta digeser dan tidak ikut bergerak. Nyawa memakai bentuk cabai kecil, bukan hati, karena bentuk itu berasal dari dunia produknya sendiri.

### 4.3 Animasi pengairan petak

Dijalankan sekali saat sebuah Petak berpindah dari berjalan ke selesai.

| Tahap | Waktu | Kejadian |
|---|---|---|
| 1 | 0 sampai 200 ms | Peta meredup ke 40 persen kecuali petak yang bersangkutan |
| 2 | 200 sampai 900 ms | Air mengisi bidang petak dari sudut kiri atas, `easeInOutCubic`, digambar dengan pemotong jalur yang bergerak |
| 3 | 700 sampai 1.100 ms | Riak permukaan, dua gelombang sinus lembut dengan amplitudo 2 dp |
| 4 | 900 sampai 1.400 ms | Enam tunas padi muncul berurutan berjarak 60 ms, tiap tunas menskala dari 0 ke 1 dengan `easeOutBack` |
| 5 | 1.200 sampai 1.400 ms | Kartu hadiah XP naik dari bawah |

Seluruhnya digerakkan satu `AnimationController` dengan `Interval` bertingkat. Tidak memakai Lottie karena bentuk petaknya berbeda-beda dan harus digambar mengikuti jalur petak yang bersangkutan.

Saat preferensi kurangi gerak aktif, tahap 1 sampai 4 diganti transisi lesap 100 milidetik.

### 4.4 Lesson berbentuk kartu

```
┌──────────────────────────────────────┐
│  ←   Unit 2 · Lesson 3        3/5    │
│  ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░                │
├──────────────────────────────────────┤
│                                      │
│  Kenapa daun cabai                   │  ← Bricolage 26
│  menguning dari bawah                │
│                                      │
│  ┌────────────────────────────────┐  │
│  │                                │  │
│  │   FOTO DAUN BERANOTASI         │  │
│  │   dengan panah dan keterangan  │  │
│  │                                │  │
│  └────────────────────────────────┘  │
│  Daun tua menguning merata,          │  ← kecil, tanahLemah
│  tulang daun ikut pucat              │
│                                      │
│  Kalau daun paling bawah yang        │  ← isiBesar 16, tinggi 1.55
│  duluan menguning dan warnanya       │
│  merata sampai ke tulang daun,       │
│  itu tanda nitrogen kurang...        │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ ⚠  Sering keliru                │  │  ← kotak padiSamar
│  │                                │  │
│  │ Kalau yang menguning justru    │  │
│  │ daun muda di pucuk, itu bukan  │  │
│  │ nitrogen. Kemungkinan besar    │  │
│  │ besi atau belerang.            │  │
│  └────────────────────────────────┘  │
│                                      │
│  ─────────────────────────────────   │
│  Sumber: Balitsa, Petunjuk Teknis    │  ← label 11, tanahSamar
│  Budidaya Cabai, 2023                │
│                                      │
│  ┌────────────────────────────────┐  │
│  │          Lanjut                │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

Kotak "Sering keliru" adalah pola yang berulang di seluruh kurikulum. Kesalahan yang sering terjadi lebih berharga daripada definisi, dan memberinya wadah visual sendiri membuatnya tidak tenggelam dalam teks.

Baris sumber selalu ada. Ini bukan hiasan akademis: pengguna yang tahu materinya berasal dari lembaga resmi lebih percaya pada isinya.

### 4.5 Periksa Tanaman, kamera

Layar paling sunyi di aplikasi. Hampir tidak ada warna.

```
┌──────────────────────────────────────┐
│  ✕                        Tanaman ▾  │  ← pilih tanaman
│                                      │
│                                      │
│      ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐         │
│                                      │
│      │   PRATINJAU KAMERA   │        │
│                                      │
│      │                      │        │
│                                      │
│      └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘         │
│                                      │
│   Satu daun, latar polos,            │  ← isi 15, putih 80%
│   jangan melawan cahaya              │
│                                      │
│                                      │
│                                      │
│    🖼               ◉             💡  │
│  galeri          ambil          senter│
│                                      │
└──────────────────────────────────────┘
```

Bingkai panduan berupa garis putus-putus, bukan bingkai penuh, supaya pengguna tetap melihat sekitar daun dan bisa menilai apakah latarnya cukup polos.

Teks panduan berganti tiap 4 detik di antara tiga tips, bukan menampilkan ketiganya sekaligus.

### 4.6 Hasil pindai

```
┌──────────────────────────────────────┐
│  ←   Hasil Periksa                   │
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │                                │  │
│  │     FOTO YANG DIAMBIL          │  │
│  │                                │  │
│  └────────────────────────────────┘  │
│                                      │
│  Cabai Rawit · HST 42                │  ← angka mono 14
│                                      │
│  ┌────────────────────────────────┐  │
│  │ DUGAAN UTAMA                   │  │  ← label 11, cabai
│  │                                │  │
│  │ Antraknosa                     │  │  ← Bricolage 26
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░  72%       │  │  ← bilah cabai
│  │                                │  │
│  │ Bercak cekung kecokelatan di   │  │
│  │ buah, tepinya lebih gelap.     │  │
│  └────────────────────────────────┘  │
│                                      │
│  KEMUNGKINAN LAIN                    │
│  Bercak Daun Cercospora    ▓▓▓ 18%   │
│  Sehat                     ▓  7%     │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  💬 Tanya soal hasil ini        │  │  ← tombol utama, daun
│  └────────────────────────────────┘  │
│                                      │
│  ┌────────────────────────────────┐  │
│  │  Tanyakan ke Warung Tani       │  │  ← tombol kedua, garis
│  └────────────────────────────────┘  │
│                                      │
│  ─────────────────────────────────   │
│  Ini dugaan awal dari foto, bukan    │
│  pemeriksaan langsung.               │
│  Kenapa hasilnya bisa salah? →       │
│                                      │
│  Hasilnya keliru?  Tandai            │
└──────────────────────────────────────┘
```

**Keadaan belum yakin**, saat keyakinan tertinggi di bawah 60 persen, mengganti seluruh kartu dugaan utama:

```
│  ┌────────────────────────────────┐  │
│  │ BELUM YAKIN                    │  │  ← label, tanahLemah
│  │                                │  │
│  │ Fotonya belum cukup jelas      │  │
│  │ untuk dipastikan.              │  │
│  │                                │  │
│  │ Coba foto ulang dengan:        │  │
│  │ · satu helai daun saja         │  │
│  │ · latar polos, misalnya kertas │  │
│  │ · cahaya dari samping          │  │
│  │                                │  │
│  │ ┌──────────────────────────┐   │  │
│  │ │      Foto ulang          │   │  │
│  │ └──────────────────────────┘   │  │
│  └────────────────────────────────┘  │
```

Tautan "Kenapa hasilnya bisa salah" membuka lembar yang menjelaskan keterbatasan model dengan jujur: dilatih dari citra yang sebagian difoto di kondisi terkendali, gejala awal beberapa penyakit mirip satu sama lain, dan satu foto tidak menangkap kondisi akar maupun tanah. Mengakui batas menaikkan kepercayaan, bukan menurunkannya.

### 4.7 Diskusi dengan asisten

```
┌──────────────────────────────────────┐
│  ←   Diskusi                    ⋮    │
├──────────────────────────────────────┤
│  ┌──────────────────────────────┐    │
│  │ 🖼 Antraknosa · 72% · HST 42  │    │  ← kartu konteks, disemat
│  └──────────────────────────────┘    │
│                                      │
│                    ┌───────────────┐ │
│                    │ Ini bahaya    │ │  ← gelembung pengguna
│                    │ nggak?        │ │     daun, teks putih
│                    └───────────────┘ │
│                                      │
│  ┌─────────────────────────────────┐ │
│  │ Antraknosa memang merugikan     │ │  ← gelembung asisten
│  │ kalau dibiarkan, tapi di HST 42 │ │     kertas, batas garis
│  │ kamu masih punya waktu.         │ │
│  │                                 │ │
│  │ Yang paling menentukan sekarang │ │
│  │ dua hal: buang buah yang sudah  │ │
│  │ bercak supaya sporanya tidak    │ │
│  │ menyebar, dan kurangi kelembapan│ │
│  │ di sekitar tanaman.             │ │
│  │                                 │ │
│  │ ┌─────────────────────────────┐ │ │
│  │ │ 📄 Balitsa · Juknis Cabai   │ │ │  ← kartu rujukan
│  │ │    2023, hlm. 34         →  │ │ │     bisa diketuk
│  │ └─────────────────────────────┘ │ │
│  │                                 │ │
│  │ 👍 👎                            │ │
│  └─────────────────────────────────┘ │
│                                      │
│  Tanya lanjut:                       │
│  ┌──────────────┐ ┌────────────────┐ │  ← saran, bisa diketuk
│  │ Bisa menular │ │ Berapa lama    │ │
│  │ ke tanaman   │ │ sampai pulih?  │ │
│  │ lain?        │ │                │ │
│  └──────────────┘ └────────────────┘ │
├──────────────────────────────────────┤
│  ┌──────────────────────────┐  ┌──┐  │
│  │ Tulis pertanyaan...      │  │→ │  │
│  └──────────────────────────┘  └──┘  │
└──────────────────────────────────────┘
```

**Jawaban mengalir kata demi kata.** Kursor berkedip di ujung teks selama pengaliran. Kartu rujukan baru muncul setelah aliran selesai.

**Kartu rujukan wajib ada** pada setiap jawaban yang bersifat anjuran. Diketuk membuka lembar berisi kutipan sumber dan tautan ke dokumen aslinya. Ini yang membedakan asisten yang menjawab dari sumber dan asisten yang mengarang.

Tombol jempol naik dan turun mengumpulkan data mutu jawaban yang masuk ke dasbor admin.

### 4.8 Linimasa tanaman

```
┌──────────────────────────────────────┐
│  ←   Cabai Depan Rumah          ⋮    │
├──────────────────────────────────────┤
│  HST 42 · ditanam 30 Jun 2026        │
│  30 polybag                          │
├──────────────────────────────────────┤
│                                      │
│  ┌────┐                              │
│  │ 🖼 │  HST 42 · 11 Agu             │
│  └────┘  Antraknosa · 72%            │
│    │                                 │
│    │     ⚠ Kedua kali dalam 2 minggu │  ← penanda pola
│    │                                 │
│  ┌────┐                              │
│  │ 🖼 │  HST 35 · 4 Agu              │
│  └────┘  Sehat · 88%                 │
│    │                                 │
│  ┌────┐                              │
│  │ 🖼 │  HST 28 · 28 Jul             │
│  └────┘  Antraknosa · 65%            │
│    │                                 │
│  ┌────┐                              │
│  │ 🖼 │  HST 14 · 14 Jul             │
│  └────┘  Sehat · 91%                 │
│                                      │
│  ┌────────────────────────────────┐  │
│  │        + Periksa lagi          │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

Penanda pola berulang adalah bagian paling bernilai dari linimasa. Satu diagnosis adalah tebakan, dua diagnosis yang sama dalam dua minggu adalah masalah yang belum tertangani, dan sistem yang menunjukkan itu memberi wawasan yang tidak dimiliki pengguna sendiri.

### 4.9 Warung Tani

Padat, teks lebih dulu, tanpa kartu besar. Satu layar harus memuat setidaknya enam pertanyaan.

```
┌──────────────────────────────────────┐
│  Warung Tani                   🔍    │
├──────────────────────────────────────┤
│  Semua  Cabai  Terong  Padi          │  ← saring komoditas
│  Terbaru ▾   Grobogan ▾              │  ← urutan dan wilayah
├──────────────────────────────────────┤
│  ▲                                   │
│ 24  Daun cabai keriting tapi tidak   │  ← judul, isiTebal 15
│  ▼  ada kutunya, kenapa?             │
│     🌶 Cabai · hama · 14 balasan     │  ← kecil 13, tanahSamar
│     ✓ Terjawab · 3 jam lalu          │  ← centang terong
├──────────────────────────────────────┤
│  ▲                                   │
│  8  Terong berbunga tapi rontok      │
│  ▼  semua sebelum jadi buah          │
│     🍆 Terong · budidaya · 5 balasan │
│     2 jam lalu                       │
├──────────────────────────────────────┤
│  ▲                                   │
│  3  Pupuk kandang ayam boleh         │
│  ▼  langsung dipakai?                │
│     💬 Umum · pupuk · 0 balasan      │
│     Belum terjawab · 20 menit lalu   │
├──────────────────────────────────────┤
│                                      │
│                          ┌─────────┐ │
│                          │ + Tanya │ │  ← tombol mengambang
│                          └─────────┘ │     terong
├──────────────────────────────────────┤
│  Kelas   Periksa   Warung   Saya     │
└──────────────────────────────────────┘
```

**Kendali suara di kiri**, tersusun tegak, dengan angka di antaranya memakai huruf lebar sama supaya baris tidak bergeser saat angkanya berubah. Target sentuh 48 dp sekalipun ikonnya tampak kecil.

**Baris "Belum terjawab" diberi warna berbeda** supaya pengguna yang ingin membantu bisa langsung menemukannya. Ini keputusan produk, bukan sekadar visual: forum mati ketika pertanyaan baru tenggelam.

### 4.10 Detail pertanyaan

```
┌──────────────────────────────────────┐
│  ←   Pertanyaan                 ⋮    │
├──────────────────────────────────────┤
│  Daun cabai keriting tapi tidak      │  ← Bricolage 20
│  ada kutunya, kenapa?                │
│                                      │
│  🌶 Cabai · hama · Grobogan          │
│  Reza P · 3 jam lalu                 │
│                                      │
│  Cabai saya HST 30, daun mudanya     │  ← isi 15
│  keriting ke atas. Sudah saya cek    │
│  bawah daun, tidak ada kutu...       │
│                                      │
│  ┌────┐ ┌────┐                       │  ← lampiran foto
│  │ 🖼 │ │ 🖼 │                        │
│  └────┘ └────┘                       │
│                                      │
│  ▲ 24 ▼      💬 14      ↗ Bagikan    │
├──────────────────────────────────────┤
│  ┌──────────────────────────────────┐│
│  │ ✓ JAWABAN TERBAIK                ││  ← latar terongSamar
│  │                                  ││
│  │ Kalau keritingnya ke atas dan    ││
│  │ daun mudanya yang kena, itu ciri ││
│  │ trips, bukan kutu daun. Trips    ││
│  │ ukurannya sangat kecil...        ││
│  │                                  ││
│  │ Dimas W · Terverifikasi          ││  ← tanda terong
│  │ ▲ 31 ▼    Balas                  ││
│  └──────────────────────────────────┘│
├──────────────────────────────────────┤
│  Punya saya juga begitu, ternyata    │
│  benar trips...                      │
│  Bagas · ▲ 5 ▼   Balas               │
│                                      │
│    └─ Pakai apa nanganinya?          │  ← jenjang 2
│       Sari · ▲ 2 ▼   Balas           │
│                                      │
│         └─ 3 balasan lagi ▾          │  ← jenjang 3 dilipat
├──────────────────────────────────────┤
│  ┌──────────────────────────┐  ┌──┐  │
│  │ Tulis balasan...         │  │→ │  │
│  └──────────────────────────┘  └──┘  │
└──────────────────────────────────────┘
```

Jawaban terbaik selalu di urutan pertama dan diberi latar `terongSamar`, terlepas dari jumlah suara. Balasan berjenjang maksimal tiga tingkat, sisanya dilipat di balik satu ketukan.

---

## 5. Komponen

Daftar komponen yang dibangun sekali dan dipakai berulang. Ditulis supaya tidak ada dua orang membuat versi berbeda dari hal yang sama.

| Komponen | Dipakai di | Catatan |
|---|---|---|
| `TombolUtama` | Semua | Tinggi 52, sudut 12, keadaan memuat menggantikan teks dengan indikator |
| `TombolKedua` | Semua | Batas `garis`, latar transparan |
| `KartuPetak` | Peta | `CustomPainter`, lima keadaan |
| `BilahProgres` | Lesson, petak | Animasi 400 ms, tinggi 6 |
| `LencanaKeyakinan` | Hasil pindai | Bilah plus persentase mono |
| `KartuRujukan` | Diskusi, lesson | Dapat diketuk, membuka lembar sumber |
| `GelembungPesan` | Diskusi | Dua varian, dukungan pengaliran |
| `KendaliSuara` | Warung | Tegak, angka lebar sama, target 48 dp |
| `LabelKomoditas` | Warung, tanaman | Pil dengan ikon dan warna komoditas |
| `KeadaanKosong` | Semua daftar | Ilustrasi, satu kalimat, satu tindakan |
| `KeadaanGalat` | Semua | Menjelaskan apa yang terjadi dan langkah berikutnya |
| `KerangkaMuat` | Semua daftar | Berkedip lembut, bukan indikator berputar |

**Keadaan kosong tidak boleh sekadar mengatakan tidak ada data.** Setiap keadaan kosong menawarkan satu tindakan:

| Layar | Teks | Tindakan |
|---|---|---|
| Tanaman Saya | Belum ada tanaman yang dipantau | Daftarkan tanaman |
| Linimasa | Belum ada pemeriksaan untuk tanaman ini | Periksa sekarang |
| Warung, hasil saring | Belum ada pertanyaan tentang ini | Jadi yang pertama bertanya |
| Unduhan | Belum ada materi yang diunduh | Lihat materi yang tersedia |

---

## 6. Nada Tulisan

Antarmuka berbicara dalam bahasa Indonesia sehari-hari yang jelas, bukan bahasa penyuluhan resmi dan bukan bahasa gaul yang dipaksakan.

| Prinsip | Jangan | Lakukan |
|---|---|---|
| Sebut yang dikenal pengguna | Klasifikasi citra selesai | Hasil pemeriksaan sudah keluar |
| Kata kerja aktif | Data berhasil disimpan | Tersimpan |
| Nama tindakan tetap sama | Tombol "Kirim" lalu pesan "Berhasil ditambahkan" | Tombol "Tanya" lalu pesan "Pertanyaan terkirim" |
| Galat menjelaskan langkah | Terjadi kesalahan | Fotonya kebesaran. Coba foto ulang, atau pilih dari galeri |
| Tanpa permintaan maaf | Maaf, kami tidak bisa memproses | Fotonya belum terbaca. Coba dengan cahaya lebih terang |
| Angka disebut apa adanya | Tingkat keyakinan model sebesar 72 persen | Yakin 72 persen |

Istilah teknis pertanian dipakai, tetapi selalu diikuti penjelasan pada kemunculan pertama di tiap lesson. Contoh: *antraknosa, yang biasa disebut patek*.

---

## 7. Aset yang Dibutuhkan

### 7.1 Daftar aset

| # | Aset | Jumlah | Format | Cara memperoleh |
|---|---|---|---|---|
| A1 | Petak terasering | 5 keadaan x 4 varian bentuk | Data jalur SVG | Gambar sendiri di Figma |
| A2 | Latar lanskap peta | 3, satu per komoditas | SVG | Gambar sendiri |
| A3 | Karakter pengguna | 1 karakter, 4 pose | SVG atau PNG | Gambar sendiri atau adaptasi aset bebas |
| A4 | Ikon komoditas | 3 | SVG | Gambar sendiri |
| A5 | Ikon antarmuka | Sekitar 40 | Ikon vektor | Lucide |
| A6 | Ilustrasi perkenalan | 4 | SVG | unDraw atau Storyset, disesuaikan warna |
| A7 | Ilustrasi keadaan kosong | 6 | SVG | Sumber sama dengan A6 |
| A8 | Foto gejala penyakit | Sekitar 60 | WebP | Demplot tim dan koleksi sendiri |
| A9 | Foto langkah budidaya | Sekitar 80 | WebP | Demplot tim |
| A10 | Video demonstrasi | 5 sampai 8 | MP4 | Rekam sendiri |
| A11 | Video sematan | 6 sampai 8 | Tautan | Kanal instansi resmi, dengan izin |
| A12 | Lencana | 12 | SVG | Gambar sendiri |
| A13 | Animasi perayaan | 2 | Lottie | LottieFiles, bagian gratis |
| A14 | Efek suara | 6 | OGG | Kenney Audio |
| A15 | Huruf | 3 keluarga | TTF variabel | Google Fonts |

### 7.2 Sumber aset bebas

| Sumber | Alamat | Isi | Lisensi |
|---|---|---|---|
| **Lucide** | lucide.dev | Sekitar 1.500 ikon garis, konsisten, dapat diatur ketebalannya | ISC |
| **Google Fonts** | fonts.google.com | Bricolage Grotesque, Plus Jakarta Sans, JetBrains Mono | Open Font License |
| **unDraw** | undraw.co | Ilustrasi datar, warna dapat diganti langsung di situsnya | Lisensi sendiri, bebas dipakai termasuk komersial, tanpa atribusi |
| **Storyset** | storyset.com | Ilustrasi dengan gaya lebih beragam, bisa dianimasikan | Gratis dengan atribusi |
| **Kenney** | kenney.nl | Paket antarmuka, karakter, ubin, dan efek suara | CC0 |
| **OpenGameArt** | opengameart.org | Aset permainan, termasuk ubin isometrik | Beragam per aset, periksa satu per satu |
| **LottieFiles** | lottiefiles.com | Animasi vektor siap pakai | Beragam, periksa tiap berkas |
| **Freesound** | freesound.org | Efek suara | Beragam, banyak CC0 dan CC-BY |
| **Pexels** | pexels.com | Foto | Lisensi Pexels, bebas komersial |
| **Unsplash** | unsplash.com | Foto | Lisensi Unsplash |
| **Humaaans** | humaaans.com | Ilustrasi manusia yang dapat disusun bagian per bagian | CC BY 4.0 |

**Peringatan lisensi.** Lisensi di tabel di atas adalah kondisi yang lazim, bukan jaminan. Situs yang mengumpulkan karya banyak pembuat, terutama OpenGameArt, itch.io, dan LottieFiles, memuat aset dengan lisensi yang berbeda-beda per berkas. Periksa halaman setiap aset sebelum dipakai, dan simpan catatannya.

Buat berkas `ASET.md` di repositori berisi: nama berkas, sumber, pembuat, lisensi, tautan, dan tanggal diunduh. Saat karya dinilai atau diperiksa, daftar ini yang membuktikan bahwa asetnya sah, dan menyusunnya belakangan jauh lebih sulit daripada mencatatnya sambil jalan.

### 7.3 Aset yang sebaiknya digambar sendiri

Empat aset ini menentukan wajah produk dan tidak akan ditemukan versi bebasnya yang cocok:

**Petak terasering.** Tidak ada paket aset bebas yang berisi bidang sawah terasering dengan bentuk yang bisa diisi progres. Menggambarnya di Figma sebagai jalur vektor lalu mengekspor data jalurnya ke Flutter memakan sekitar satu hari kerja dan menghasilkan elemen yang tidak dimiliki produk lain.

**Ikon komoditas.** Cabai rawit, terong, dan padi dengan gaya garis yang seragam dengan Lucide. Sekitar dua jam.

**Karakter.** Bisa disusun dari Humaaans yang bagian tubuhnya dapat dipasang-lepas, lalu diwarnai ulang mengikuti palet. Ini jalan tengah yang wajar antara menggambar dari nol dan memakai maskot generik.

**Lencana.** Dua belas bentuk sederhana berdasarkan benda pertanian: caping, cangkul, ember, bulir padi, dan seterusnya. Digambar dengan gaya yang sama dengan ikon komoditas.

### 7.4 Anggaran ukuran aset

| Kelompok | Anggaran |
|---|---|
| Huruf, tiga keluarga variabel, dibundel | 1,2 MB |
| Ikon Lucide, hanya yang dipakai | 60 KB |
| SVG peta dan petak | 180 KB |
| Ilustrasi perkenalan dan keadaan kosong | 400 KB |
| Lencana | 90 KB |
| Lottie, dua berkas | 120 KB |
| Efek suara | 200 KB |
| Model TFLite terkuantisasi | 6 MB |
| **Total aset dibundel** | **Sekitar 8,3 MB** |

Foto lesson dan video **tidak dibundel**, diunduh sesuai kebutuhan. Ini yang menjaga ukuran APK tetap di bawah 40 MB.

Ikon Lucide diimpor per berkas, bukan seluruh paket. Mengimpor seluruh paket menambah beberapa ratus kilobita untuk ikon yang tidak pernah tampil.

---

## 8. Daftar Periksa Sebelum Rilis

**Kinerja**
- [ ] Peta bergulir 60 bingkai per detik pada perangkat RAM 2 GB
- [ ] Tidak ada bingkai di atas 16 milidetik saat menggeser daftar Warung Tani
- [ ] Model TFLite dimuat sekali, bukan tiap pindai
- [ ] Kompresi gambar berjalan di isolate, antarmuka tidak membeku
- [ ] Semua daftar memakai pembangun malas, bukan kolom di dalam penggulir
- [ ] APK di bawah 40 MB setelah pemisahan per ABI

**Aksesibilitas**
- [ ] Semua target sentuh minimal 48 dp, diperiksa dengan kisi
- [ ] Kontras teks utama minimal 4,5 banding 1
- [ ] Skala teks sistem 200 persen tidak merusak tata letak mana pun
- [ ] Preferensi kurangi gerak menonaktifkan animasi peta dan pengairan
- [ ] Semua ikon punya semantik untuk pembaca layar
- [ ] Diuji di bawah sinar matahari langsung, bukan hanya di dalam ruangan

**Konsistensi**
- [ ] Tidak ada warna di luar berkas token
- [ ] Tidak ada ukuran huruf di luar skala tipografi
- [ ] Tidak ada jarak di luar skala jarak
- [ ] Semua keadaan kosong punya ilustrasi, kalimat, dan tindakan
- [ ] Semua keadaan galat menjelaskan langkah berikutnya

**Legalitas aset**
- [ ] Berkas `ASET.md` lengkap dan mutakhir
- [ ] Tidak ada aset dengan lisensi yang belum diperiksa
- [ ] Atribusi tampil di layar Tentang untuk aset yang mensyaratkannya
- [ ] Tidak ada video pihak lain yang diunduh dan dihosting ulang
