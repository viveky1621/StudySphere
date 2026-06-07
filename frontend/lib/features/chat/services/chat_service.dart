import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart';

final chatServiceProvider = Provider((ref) {
  return ChatService(ref.watch(dioProvider));
});

class ChatService {
  final Dio _dio;
  
  ChatService(this._dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<String> createChat(String title) async {
    try {
      final response = await _dio.post(
        '/chats', 
        data: {'title': title},
        options: await _getAuthOptions(),
      );
      return response.data['chat']['id'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to create chat');
    }
  }

  Future<Map<String, dynamic>> sendMessage(String chatId, String content, {String? pdfId}) async {
    try {
      final response = await _dio.post(
        '/chats/$chatId/messages',
        data: {
          'content': content,
          'pdfId': pdfId,
        },
        options: await _getAuthOptions(),
      );
      return response.data['message'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to send message');
    }
  }
}
