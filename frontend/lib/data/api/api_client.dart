import 'package:artid/data/api/api_constants.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(authProvider).token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));
  return dio;
});
