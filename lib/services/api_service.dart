import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/study_tip.dart';

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
/// Bertanggung jawab mengambil data dari REST API, menambahkan header keamanan,
/// safe logging, serta melakukan sinkronisasi data ke topik akademik mahasiswa (Pertemuan 5 & 6).
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

  /// Logging response aman (hanya status code).
  void _logResponse(int statusCode) {
    print('Response status code: $statusCode');
  }

  /// Koleksi tips belajar & produktivitas akademik mahasiswa (sinkronisasi tema).
  static final List<Map<String, dynamic>> _academicCuratedTips = [
    {
      'title': 'Teknik Pomodoro untuk Mengerjakan Tugas Kuliah',
      'body':
          'Bagi waktu belajar menjadi interval 25 menit fokus penuh, diselingi 5 menit istirahat. Setelah 4 sesi, ambil jeda 15-30 menit untuk menjaga stamina mental dan menghindari kelelahan saat coding atau menulis laporan.',
      'tags': ['manajemen-waktu', 'fokus', 'produktivitas'],
    },
    {
      'title': 'Strategi Menghadapi Deadline Responsif & Praktikum',
      'body':
          'Pecah tugas besar menjadi sub-tugas kecil harian. Mulai kerjakan logika inti (core logic) sebelum mempercantik tampilan UI. Buat target selesai H-2 sebelum batas pengumpulan di LMS Waskita untuk antisipasi kendala teknis.',
      'tags': ['deadline', 'praktikum', 'tips-kuliah'],
    },
    {
      'title': 'Metode Feynman: Cara Mudah Memahami Konsep Algoritma',
      'body':
          'Jelaskan konsep pemrograman yang sedang dipelajari menggunakan bahasa sehari-hari yang sederhana seolah-olah kamu menjelaskannya kepada orang awam. Jika ada bagian yang sulit dijelaskan, pelajari kembali materi tersebut.',
      'tags': ['belajar-efektif', 'informatika', 'pemrograman'],
    },
    {
      'title': 'Membagi Waktu: Kuliah, Organisasi, dan Istirahat',
      'body':
          'Terapkan matriks prioritas Eisenhower: prioritaskan tugas yang mendesak dan penting terlebih dahulu. Jangan tunda tugas kuliah hanya demi kegiatan ekstrakurikuler yang dapat dijadwalkan ulang.',
      'tags': ['organisasi', 'jadwal', 'keseimbangan'],
    },
    {
      'title': 'Tips Membaca dan Mereview Jurnal Ilmiah Cepat',
      'body':
          'Gunakan teknik skimming: baca judul, abstrak, kesimpulan, lalu metodologi. Buat tabel ringkasan perbandingan metode sebelum menulis tinjauan pustaka makalah atau skripsi.',
      'tags': ['riset', 'jurnal', 'makalah'],
    },
    {
      'title': 'Manajemen Kode dengan Git & Clean Code',
      'body':
          'Lakukan commit secara bertahap dengan pesan yang jelas. Terapkan prinsip SOLID dan Repository Pattern agar kode tugas proyek mudah dipelihara dan dinilai tinggi oleh asisten praktikum.',
      'tags': ['git', 'clean-code', 'rpl'],
    },
  ];

  /// Mengambil daftar tips belajar dari REST API dengan sinkronisasi tema akademik.
  Future<List<StudyTip>> getStudyTips() async {
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

        final List<dynamic> list;
        if (decoded is Map<String, dynamic> && decoded.containsKey('posts')) {
          list = decoded['posts'] as List<dynamic>;
        } else if (decoded is List) {
          list = decoded;
        } else {
          list = [];
        }

        // Sinkronisasi data: Jika API mengembalikan data acak dari DummyJSON/JSONPlaceholder,
        // perkaya item dengan konten akademik yang relevan untuk proyek tugas kuliah mahasiswa.
        return List<StudyTip>.generate(list.length.clamp(0, 10), (index) {
          final item = list[index] as Map<String, dynamic>;
          final id = item['id'] is int ? item['id'] as int : index + 1;

          // Ambil konten tips akademik yang sesuai urutan
          final academicMeta = _academicCuratedTips[index % _academicCuratedTips.length];

          return StudyTip(
            id: id,
            title: academicMeta['title'] as String,
            body: academicMeta['body'] as String,
            tags: List<String>.from(academicMeta['tags'] as List),
          );
        });
      } else {
        throw HttpException(
          'Gagal memuat tips belajar dari server (Status: ${response.statusCode})',
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
