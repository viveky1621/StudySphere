import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

final adminServiceProvider = Provider((ref) {
  return AdminService(ref.watch(dioProvider));
});

final platformStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(adminServiceProvider).getStats();
});

final usersListProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(adminServiceProvider).getUsers();
});

class AdminService {
  final Dio _dio;
  
  AdminService(this._dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/admin/stats', options: await _getAuthOptions());
      return response.data['stats'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to load stats');
    }
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get('/admin/users', options: await _getAuthOptions());
      return response.data['users'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to load users');
    }
  }

  Future<void> upgradeUser(String userId) async {
    await _dio.post(
      '/admin/users/$userId/upgrade',
      options: await _getAuthOptions(),
    );
  }
}
