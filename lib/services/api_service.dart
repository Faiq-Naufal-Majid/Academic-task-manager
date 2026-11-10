import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/health_tip.dart';

/// Exception khusus untuk kesalahan komunikasi HTTP.
class HttpException implements Exception {
  final String message;
  final int? statusCode;
  HttpException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Service komunikasi jaringan REST API.
///
/// Bertanggung jawab menangani request HTTP, penambahan header keamanan,
/// safe logging, serta penanganan error koneksi (Materi Pertemuan 5 & 6).
class ApiService {
  final http.Client _client;
  final String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.baseUrl;

  /// Header request dengan API Key dari environment variable (.env).
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-API-Key': AppConfig.apiKey,
    };
  }

  /// Logging request aman tanpa mencetak data rahasia.
  void _logRequest(String method, String endpoint) {
    print('[$method] $endpoint');
  }

  /// Logging response aman (hanya kode status).
  void _logResponse(int statusCode) {
    print('Response status code: $statusCode');
  }

  /// Mengambil daftar tips kesehatan dari endpoint /posts.
  Future<List<HealthTip>> getHealthTips() async {
    const endpoint = '/posts';
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      _logRequest('GET', endpoint);
      final response = await _client
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _logResponse(response.statusCode);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        // Menangani format { posts: [...] } (seperti DummyJSON) maupun direct List [...]
        final List<dynamic> list;
        if (decoded is Map<String, dynamic> && decoded.containsKey('posts')) {
          list = decoded['posts'] as List<dynamic>;
        } else if (decoded is List) {
          list = decoded;
        } else {
          list = [];
        }

        return list.map((item) => HealthTip.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw HttpException(
          'Gagal memuat data kesehatan dari server (Status: ${response.statusCode})',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw HttpException('Batas waktu request habis (Timeout). Periksa koneksi internet Anda.');
    } on SocketException {
      throw HttpException('Tidak ada koneksi internet. Pastikan perangkat Anda terhubung.');
    } on FormatException {
      throw HttpException('Format data respons server tidak valid.');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Membersihkan resource client HTTP saat tidak digunakan.
  void dispose() {
    _client.close();
  }
}
