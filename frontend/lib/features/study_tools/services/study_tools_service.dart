import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

final studyToolsServiceProvider = Provider((ref) {
  return StudyToolsService(ref.watch(dioProvider));
});

final flashcardsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(studyToolsServiceProvider).getDueFlashcards();
});

final quizzesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(studyToolsServiceProvider).getQuizzes();
});

class StudyToolsService {
  final Dio _dio;
  
  StudyToolsService(this._dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // Quizzes
  Future<List<dynamic>> getQuizzes() async {
    final response = await _dio.get('/quizzes', options: await _getAuthOptions());
    return response.data['quizzes'];
  }

  Future<void> submitQuizScore(String quizId, num score) async {
    await _dio.post(
      '/quizzes/$quizId/submit',
      data: {'score': score},
      options: await _getAuthOptions(),
    );
  }

  // Flashcards
  Future<List<dynamic>> getDueFlashcards() async {
    final response = await _dio.get('/flashcards/review', options: await _getAuthOptions());
    return response.data['flashcards'];
  }

  Future<void> reviewFlashcard(String flashcardId, int quality) async {
    await _dio.post(
      '/flashcards/$flashcardId/review',
      data: {'quality': quality},
      options: await _getAuthOptions(),
    );
  }

  // One Day Batting (Study Plans)
  Future<List<dynamic>> getStudyPlans() async {
    final response = await _dio.get('/study-plans', options: await _getAuthOptions());
    return response.data['plans'];
  }

  Future<void> generateOneDayBatting(String subject) async {
    await _dio.post(
      '/study-plans/one-day-batting',
      data: {'subject': subject},
      options: await _getAuthOptions(),
    );
  }
}
