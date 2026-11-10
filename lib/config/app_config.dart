import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi terpusat aplikasi Manajemen Tugas & Akademik Mahasiswa.
///
/// Memuat base URL dan API key dari file `.env` (Prinsip RPL & Keamanan Pertemuan 6).
class AppConfig {
  /// Base URL REST API untuk mengambil referensi tips belajar dan produktivitas.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://dummyjson.com';

  /// API key untuk autentikasi request ke server.
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  /// Batas waktu (timeout) request HTTP dalam detik.
  static const int timeoutSeconds = 10;

  /// Memeriksa kelengkapan konfigurasi environment (.env).
  static bool isConfigured() {
    return baseUrl.isNotEmpty && apiKey.isNotEmpty;
  }
}
