import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

final dioProvider = Provider((ref) => Dio(BaseOptions(
      baseUrl: 'http://10.246.176.191:3000/api', // PC Local IP for physical device testing
      connectTimeout: const Duration(seconds: 5),
    )));

final authServiceProvider = Provider((ref) {
  return AuthService(ref.watch(dioProvider));
});

// Auth State Notifier
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthService {
  final Dio _dio;
  
  AuthService(this._dio);

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      
      // Optionally store user data here
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  Future<void> loginWithGoogle() async {
    throw Exception('Google Sign-In is temporarily disabled for this build.');
  }

  Future<void> loginAsGuest() async {
    try {
      final response = await _dio.post('/auth/guest');
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    } on DioException catch (e) {
      final message = e.response?.data['error'] ?? 'Guest login failed';
      throw Exception(message);
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      
      final token = response.data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    } on DioException catch (e) {
      var message = e.response?.data['error'];
      if (message is List) {
         message = message.map((m) => m['message']).join(', ');
      }
      throw Exception(message ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncData(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _authService.login(email, password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _authService.loginWithGoogle();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> loginAsGuest() async {
    state = const AsyncLoading();
    try {
      await _authService.loginAsGuest();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = const AsyncLoading();
    try {
      await _authService.register(name, email, password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
