import '../models/study_tip.dart';

/// Abstraksi Repository untuk mengelola data artikel tips belajar (Prinsip SOLID: DIP).
///
/// Memisahkan antarmuka pengguna dari detail komunikasi jaringan REST API.
abstract class ArticleRepository {
  /// Mengambil daftar artikel tips belajar & produktivitas.
  Future<List<StudyTip>> fetchStudyTips();
}
