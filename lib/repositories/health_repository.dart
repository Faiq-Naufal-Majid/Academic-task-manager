import '../models/health_tip.dart';

/// Abstraksi Repository untuk mengelola data tips kesehatan (Prinsip SOLID: DIP).
///
/// Memisahkan logika UI/Provider dari sumber data jaringan/lokal (Repository Pattern).
abstract class HealthRepository {
  /// Mengambil daftar tips kesehatan terbaru.
  Future<List<HealthTip>> fetchHealthTips();
}
