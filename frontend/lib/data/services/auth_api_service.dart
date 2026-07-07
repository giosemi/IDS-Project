import 'dart:convert';

import 'package:artid/data/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, dynamic> _parseJsonMap(Object? data) {
  if (data == null) {
    throw const FormatException('Risposta vuota dal server');
  }
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is String) return jsonDecode(data) as Map<String, dynamic>;
  throw FormatException('Formato risposta non valido: ${data.runtimeType}');
}

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
    final user = _parseJsonMap(json['user']);
    return AuthResponse(
      token: json['token'] as String,
      userId: user['id'] as String,
      name: user['name'] as String,
      email: user['email'] as String,
    );
  }
}

class OtpSentResponse {
  const OtpSentResponse({
    required this.email,
    this.devOtp,
  });

  final String email;
  final String? devOtp;

  factory OtpSentResponse.fromJson(Map<String, dynamic> json) {
    return OtpSentResponse(
      email: json['email'] as String,
      devOtp: json['devOtp'] as String?,
    );
  }
}

class AuthApiService {
  const AuthApiService(this._dio);

  final Dio _dio;

  Future<OtpSentResponse> requestLoginOtp(String email, String password) async {
    final res = await _dio.post<dynamic>(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    return OtpSentResponse.fromJson(_parseJsonMap(res.data));
  }

  Future<AuthResponse> verifyOtp(String email, String code) async {
    final res = await _dio.post<dynamic>(
      '/api/auth/verify-otp',
      data: {'email': email, 'code': code},
    );
    return AuthResponse.fromJson(_parseJsonMap(res.data));
  }

  Future<OtpSentResponse> resendOtp(String email) async {
    final res = await _dio.post<dynamic>(
      '/api/auth/resend-otp',
      data: {'email': email},
    );
    return OtpSentResponse.fromJson(_parseJsonMap(res.data));
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    final res = await _dio.post<dynamic>(
      '/api/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthResponse.fromJson(_parseJsonMap(res.data));
  }
}

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(dioProvider));
});
