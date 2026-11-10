# Academic Task & Deadline Manager

Aplikasi mobile berbasis Flutter yang dirancang untuk membantu mahasiswa mengelola daftar tugas kuliah, memantau tenggat waktu (*deadline*), dan membaca artikel tips belajar efektif serta manajemen waktu. 

Aplikasi ini dibangun dengan menerapkan konsep rekayasa perangkat lunak yang baik, meliputi:
- **Form Handling & Validasi**: Input data tugas, tenggat waktu (*DatePicker*), mata kuliah (*Dropdown*), serta login dengan indikator kekuatan kata sandi dan sanitasi input anti-XSS.
- **State Management & Local Storage**: Pengelolaan state global menggunakan pola `InheritedWidget` yang efisien dan penyimpanan data tugas serta profil secara persisten via `SharedPreferences`.
- **Keamanan Data**: Penyimpanan token autentikasi mahasiswa secara terenkripsi (AES-256) menggunakan `flutter_secure_storage` serta konfigurasi environment via file `.env`.
- **Integrasi REST API**: Pengambilan data tips belajar produktif dengan *Repository Pattern* dan penanganan 3 status antarmuka (*Loading*, *Error*, dan *Success*).

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
