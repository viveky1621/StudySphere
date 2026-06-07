import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

final discoverServiceProvider = Provider((ref) {
  return DiscoverService(ref.watch(dioProvider));
});

final publicPdfsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(discoverServiceProvider).getPublicPdfs();
});

final publicQuizzesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(discoverServiceProvider).getPublicQuizzes();
});

class DiscoverService {
  final Dio _dio;
  
  DiscoverService(this._dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<List<dynamic>> getPublicPdfs() async {
    final response = await _dio.get('/pdfs/public', options: await _getAuthOptions());
    return response.data['pdfs'];
  }

  Future<List<dynamic>> getPublicQuizzes() async {
    final response = await _dio.get('/quizzes/public', options: await _getAuthOptions());
    return response.data['quizzes'];
  }
}
