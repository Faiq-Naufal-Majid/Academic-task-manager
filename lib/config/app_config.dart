import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi terpusat aplikasi Health Tracker yang dimuat dari file `.env`.
///
/// Menerapkan prinsip keamanan Pertemuan 6 untuk menghindari hardcoded credential.
class AppConfig {
  /// Base URL endpoint REST API.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://dummyjson.com';

  /// API key rahasia untuk autentikasi request.
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  /// Durasi batas waktu (timeout) request HTTP dalam detik.
  static const int timeoutSeconds = 10;

  /// Memeriksa apakah konfigurasi aplikasi lengkap.
  static bool isConfigured() {
    return baseUrl.isNotEmpty && apiKey.isNotEmpty;
  }
}
