import '../models/study_tip.dart';
import '../services/api_service.dart';
import 'article_repository.dart';

/// Implementasi konkret dari [ArticleRepository] yang menggunakan [ApiService].
class ArticleRepositoryImpl implements ArticleRepository {
  final ApiService _apiService;

  ArticleRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<StudyTip>> fetchStudyTips() async {
    return await _apiService.getStudyTips();
  }
}
