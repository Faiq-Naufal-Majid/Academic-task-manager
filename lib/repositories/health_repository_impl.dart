import '../models/health_tip.dart';
import '../services/api_service.dart';
import 'health_repository.dart';

/// Implementasi konkret dari [HealthRepository] yang berkomunikasi dengan [ApiService].
class HealthRepositoryImpl implements HealthRepository {
  final ApiService _apiService;

  HealthRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<HealthTip>> fetchHealthTips() async {
    return await _apiService.getHealthTips();
  }
}
