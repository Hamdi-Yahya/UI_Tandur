---
description: "Aturan utama pengembangan UI Tandur"
globs: "*"
---

# Tandur Project Rules

Aturan permanen untuk pengembangan UI Tandur berdasarkan PRD.md, DESAIN.md, dan API_DOCS.md.

## 1. Project Identity
* **Nama**: TANDUR (Tani Terukur)
* **Platform**: Flutter mobile
* **Prioritas**: Android
* **Target viewport**: 360 × 800 dp
* **Fokus saat ini**: UI/UX dan frontend mobile

## 2. Source of Truth
* **PRD.md** → product requirements, feature scope, user stories, acceptance criteria
* **DESAIN.md** → visual design, UI/UX, layout, typography, colors, spacing, motion, navigation
* **API_DOCS.md** → API contract, endpoint, request, response, authentication, error, pagination

**Jika terdapat konflik:**
* Jangan menebak
* Identifikasi konflik
* Gunakan dokumen yang paling relevan dengan jenis keputusan
* Tanyakan kepada pengguna jika konflik tersebut memengaruhi implementasi

## 3. Design Rules
Selalu patuhi `DESAIN.md`.

**JANGAN:**
* Membuat color palette baru tanpa alasan
* Mengganti font yang sudah ditentukan
* Membuat shadow berlebihan
* Menggunakan gradient sembarangan
* Mengubah struktur navigasi tanpa persetujuan
* Menggunakan emoji sebagai pengganti aset visual final jika desain menentukan icon/vector
* Membuat UI generik yang tidak sesuai karakter Tandur

**HARUS:**
* Gunakan design token yang sudah ditentukan.

## 4. UX Rules
Prioritaskan:
* Sederhana
* Mudah dibaca
* Touch target minimal 48 dp
* Accessibility
* Kontras minimal AA
* Dukungan text scaling
* Semantic labels
* Reduce-motion preference
* Empty state dengan CTA
* Error state yang memberikan tindakan jelas

## 5. Product Rules
* Jangan membuat fitur di luar scope PRD.
* Jangan menambahkan fitur hanya karena menurutmu "bagus".
* Jika fitur tidak ada di PRD/DESAIN:
  * Tandai sebagai belum ditentukan
  * Jangan langsung implementasikan

## 6. API Rules
**Jangan mengarang:**
* Endpoint
* HTTP method
* Request body
* Response structure
* Enum
* Authentication behavior

**HARUS:**
* Gunakan `API_DOCS.md` sebagai kontrak.
* Jangan mengubah API contract dari sisi frontend hanya untuk mempermudah implementasi UI.

## 7. Architecture Rules
Ikuti stack yang ditentukan PRD, dengan pengecualian versi Flutter:

**Flutter development environment:**
* Flutter 3.47.0

**PRD reference:**
PRD.md mencatat Flutter 3.24 sebagai versi yang ditulis pada dokumen, tetapi project development saat ini menggunakan Flutter 3.47.0.
Jangan downgrade atau menggunakan FVM hanya untuk mengikuti angka versi tersebut.

* Riverpod 2
* go_router
* Drift
* Dio
* Retrofit
* flutter_svg
* tflite_flutter bila dibutuhkan
* image_picker dan flutter_image_compress bila dibutuhkan
* flutter_secure_storage untuk token

*Jangan menambahkan framework atau library baru tanpa alasan yang jelas dan persetujuan saya.*

## 8. Offline Rules
Ingat bahwa beberapa fitur Tandur harus tetap bekerja secara offline.
Jangan membuat UI yang hanya mengasumsikan selalu ada internet.

UI harus siap menangani:
* Loading
* Offline
* Syncing
* Sync failed
* Retry
* Empty
* Error
* Success

## 9. Coding Rules
Saat nanti mulai coding:
* Gunakan reusable components
* Hindari duplicate UI
* Gunakan design tokens
* Gunakan const jika memungkinkan
* Pecah widget berdasarkan tanggung jawab
* Jangan membuat satu widget/file terlalu besar
* Prioritaskan maintainability
* Jangan mengubah file yang tidak berkaitan dengan task
* Jangan melakukan refactor besar tanpa alasan

## 10. Asset Rules
* `DESAIN.md` adalah acuan aset visual.
* Untuk aset eksternal: catat sumber, perhatikan lisensi, jangan mengambil aset berlisensi tidak jelas.
* Jika aset inti Tandur belum tersedia, jangan menganggap placeholder sebagai aset final.
