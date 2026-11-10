# Academic Task & Deadline Manager - Proyek Responsi Pemrograman Mobile

Aplikasi mobile berbasis Flutter yang dirancang untuk membantu mahasiswa mengelola tugas kuliah, memantau tenggat waktu (*deadline*), dan membaca artikel tips belajar efektif. Proyek ini mengintegrasikan materi Praktikum Pemrograman Mobile (ST407) Universitas Amikom Yogyakarta: **Form Handling & Validasi**, **State Management & Local Storage**, **Keamanan Data & REST API**, serta **Prinsip RPL & Clean Code**.

---

## 📌 Ringkasan Implementasi Modul Praktikum

| Modul Praktikum | Konsep & Fitur yang Diterapkan | Lokasi Kode |
| :--- | :--- | :--- |
| **Pertemuan 3** *(StatefulWidget & Form Handling)* | • Reusable Input Field (`CustomTextField`)<br>• Validasi form real-time (Email kampus, NIM, Password min 8 char + huruf kapital + angka)<br>• Toggle obscure password (`setState` least privilege)<br>• Indikator kekuatan password (*Latihan 5*)<br>• Checkbox Tata Tertib Akademik & Pengingat (*Latihan 4*)<br>• Dropdown Mata Kuliah & Prioritas (*Latihan 3*)<br>• DatePicker Deadline Tugas (*Latihan 2*) | [`lib/widgets/custom_text_field.dart`](lib/widgets/custom_text_field.dart)<br>[`lib/screens/login_screen.dart`](lib/screens/login_screen.dart)<br>[`lib/screens/add_task_screen.dart`](lib/screens/add_task_screen.dart)<br>[`lib/screens/profile_screen.dart`](lib/screens/profile_screen.dart)<br>[`lib/utils/validators.dart`](lib/utils/validators.dart) |
| **Pertemuan 4** *(State Management & SharedPreferences)* | • Arsitektur `InheritedWidget` + `StatefulWidget Wrapper` untuk mengatasi *prop drilling*<br>• Persistensi profil mahasiswa & daftar tugas kuliah (`academic_tasks` JSON)<br>• Fitur Tema Gelap / Terang (*Latihan 1*)<br>• Counter jumlah buka aplikasi / kunjungan (*Latihan 2*)<br>• Fitur simpan artikel tips belajar favorit (*Latihan 3*) | [`lib/providers/task_provider.dart`](lib/providers/task_provider.dart)<br>[`lib/models/academic_task.dart`](lib/models/academic_task.dart)<br>[`lib/models/student_profile.dart`](lib/models/student_profile.dart)<br>[`lib/main.dart`](lib/main.dart) |
| **Pertemuan 5** *(Keamanan Data & HTTP Dasar)* | • Penyimpanan token autentikasi mahasiswa terenkripsi AES-256 via `flutter_secure_storage`<br>• *Safe Logging* (tidak mencetak token/kredensial ke console)<br>• HTTP GET request dengan error handling lengkap (`TimeoutException`, `SocketException`, `FormatException`)<br>• Antarmuka 3-State (Loading, Error + tombol coba lagi, Success)<br>• Modal Bottom Sheet detail tips saat kartu diklik | [`lib/services/secure_storage_service.dart`](lib/services/secure_storage_service.dart)<br>[`lib/services/api_service.dart`](lib/services/api_service.dart)<br>[`lib/widgets/study_tip_card.dart`](lib/widgets/study_tip_card.dart)<br>[`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) |
| **Pertemuan 6** *(Prinsip RPL & Keamanan Kode)* | • Penerapan prinsip **SOLID (SRP & DIP)**<br>• **Repository Pattern** untuk memisahkan logika UI dari sumber data<br>• Menghindari hardcoded credentials menggunakan file `.env` (`flutter_dotenv`)<br>• Sanitasi input teks (`Validators.sanitize`) untuk mencegah XSS<br>• Dokumentasi kode standar Dartdoc (`///`)<br>• Unit Testing untuk validator (*Latihan 5*) | [`lib/config/app_config.dart`](lib/config/app_config.dart)<br>[`lib/repositories/article_repository.dart`](lib/repositories/article_repository.dart)<br>[`lib/repositories/article_repository_impl.dart`](lib/repositories/article_repository_impl.dart)<br>[`test/utils/validators_test.dart`](test/utils/validators_test.dart) |

---

## 🏗️ Struktur Direktori Proyek

```text
lib/
├── config/
│   └── app_config.dart               # Konfigurasi terpusat dari file .env
├── models/
│   ├── academic_task.dart            # Model entitas tugas kuliah
│   ├── student_profile.dart          # Model profil akademik mahasiswa
│   └── study_tip.dart                # Model artikel tips belajar (REST API)
├── providers/
│   └── task_provider.dart            # InheritedWidget State Management
├── repositories/
│   ├── article_repository.dart       # Interface / Abstraksi Repository (DIP)
│   └── article_repository_impl.dart  # Implementasi konkret Repository
├── services/
│   ├── api_service.dart              # Service komunikasi HTTP & Header keamanan
│   └── secure_storage_service.dart   # Service penyimpanan token terenkripsi AES
├── utils/
│   └── validators.dart               # Validasi form, kalkulasi password & sanitasi XSS
├── widgets/
│   ├── custom_text_field.dart        # Reusable input field widget
│   ├── task_card.dart                # Reusable card tugas kuliah dengan checklist
│   └── study_tip_card.dart           # Reusable card tips belajar dari REST API
├── screens/
│   ├── login_screen.dart             # Layar login mahasiswa dengan validasi
│   ├── home_screen.dart              # Dashboard utama (Progres, Daftar Tugas, Tips API)
│   ├── add_task_screen.dart          # Form tambah tugas (DatePicker & Dropdown)
│   └── profile_screen.dart           # Form profil mahasiswa (NIM, Prodi, Semester)
└── main.dart                         # Entry point & tema dinamis
test/
└── utils/
    └── validators_test.dart          # Unit test untuk validasi dan sanitasi
```

---

## 🚀 Cara Menjalankan Aplikasi

1. **Pasang dependensi proyek:**
   ```bash
   flutter pub get
   ```

2. **Pastikan file `.env` telah tersedia di root proyek:**
   ```env
   BASE_URL=https://dummyjson.com
   API_KEY=academic_secure_key_amikom_2026
   ```

3. **Jalankan Unit Test otomatis:**
   ```bash
   flutter test test/utils/validators_test.dart
   ```

4. **Jalankan aplikasi di Emulator / Device:**
   ```bash
   flutter run
   ```
