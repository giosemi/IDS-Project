import 'package:artid/data/api/api_client.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/domain/models/share_link.dart';
import 'package:artid/domain/models/student_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedViewData {
  const SharedViewData({
    required this.label,
    required this.token,
    required this.items,
    this.profile,
  });

  final String label;
  final String token;
  final List<ContentItem> items;
  final StudentProfile? profile;
}

class ShareLinksApiService {
  const ShareLinksApiService(this._dio);

  final Dio _dio;

  Future<List<ShareLink>> getMyLinks() async {
    final res = await _dio.get<List<dynamic>>('/api/share-links');
    return res.data!
        .cast<Map<String, dynamic>>()
        .map(ShareLink.fromJson)
        .toList();
  }

  Future<ShareLink> create({
    required String label,
    required List<String> contentIds,
    bool includeProfile = true,
    DateTime? expiresAt,
  }) async {
    final data = <String, dynamic>{
      'label': label,
      'contentIds': contentIds,
      'includeProfile': includeProfile,
    };
    if (expiresAt != null) {
      data['expiresAt'] = expiresAt.toUtc().toIso8601String();
    }
    final res = await _dio.post<Map<String, dynamic>>('/api/share-links', data: data);
    return ShareLink.fromJson(res.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/share-links/$id');
  }

  Future<SharedViewData> viewByToken(String token) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/s/$token');
    final json = res.data!;
    final items = (json['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ContentItem.fromJson)
        .toList();
    StudentProfile? profile;
    if (json['profile'] != null) {
      profile = StudentProfile.fromJson(json['profile'] as Map<String, dynamic>);
    }
    return SharedViewData(
      label: json['label'] as String,
      token: json['token'] as String,
      items: items,
      profile: profile,
    );
  }
}

final shareLinksApiServiceProvider = Provider<ShareLinksApiService>((ref) {
  return ShareLinksApiService(ref.watch(dioProvider));
});

final sharedViewProvider = FutureProvider.family<SharedViewData, String>((ref, token) {
  return ref.read(shareLinksApiServiceProvider).viewByToken(token);
});
