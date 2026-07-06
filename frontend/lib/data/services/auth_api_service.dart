import 'package:artid/data/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
  });

  final String token;
  final String userId;
  final String name;
  final String email;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthResponse(
      token: json['token'] as String,
      userId: user['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
    );
  }
}

class AuthApiService {
  const AuthApiService(this._dio);

  final Dio _dio;

  Future<AuthResponse> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(res.data!);
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthResponse.fromJson(res.data!);
  }
}

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(dioProvider));
});
