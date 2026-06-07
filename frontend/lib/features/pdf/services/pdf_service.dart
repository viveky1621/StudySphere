import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/services/auth_service.dart'; // To reuse dioProvider

final pdfServiceProvider = Provider((ref) {
  return PdfService(ref.watch(dioProvider));
});

final pdfListProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(pdfServiceProvider).fetchPdfs();
});

class PdfService {
  final Dio _dio;
  
  PdfService(this._dio);

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<List<dynamic>> fetchPdfs() async {
    try {
      final response = await _dio.get('/pdfs', options: await _getAuthOptions());
      return response.data['pdfs'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to fetch PDFs');
    }
  }

  Future<void> uploadPdf(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'title': fileName,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      await _dio.post(
        '/pdfs/upload',
        data: formData,
        options: await _getAuthOptions(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to upload PDF');
    }
  }
}
