import 'package:artid/data/api/api_client.dart';
import 'package:artid/domain/models/student_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileApiService {
  const ProfileApiService(this._dio);

  final Dio _dio;

  Future<StudentProfile> getMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/profile');
    return StudentProfile.fromJson(res.data!);
  }

  Future<StudentProfile> updateProfile(StudentProfile profile) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/profile',
      data: profile.toJson(),
    );
    return StudentProfile.fromJson(res.data!);
  }

  Future<StudentProfile> getProfileById(String userId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/profile/$userId');
    return StudentProfile.fromJson(res.data!);
  }
}

final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  return ProfileApiService(ref.watch(dioProvider));
});
