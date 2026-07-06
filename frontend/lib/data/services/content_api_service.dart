import 'package:artid/data/api/api_client.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentApiService {
  const ContentApiService(this._dio);

  final Dio _dio;

  Future<List<ContentItem>> getMyContent() async {
    final res = await _dio.get<List<dynamic>>('/api/content');
    return res.data!
        .cast<Map<String, dynamic>>()
        .map(ContentItem.fromJson)
        .toList();
  }

  Future<ContentItem> create(ContentItem item) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/content',
      data: item.toJson(),
    );
    return ContentItem.fromJson(res.data!);
  }

  Future<ContentItem> update(String id, ContentItem item) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/content/$id',
      data: item.toJson(),
    );
    return ContentItem.fromJson(res.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/api/content/$id');
  }

  Future<List<ContentItem>> search(String query) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/search',
      queryParameters: {'q': query},
    );
    return res.data!
        .cast<Map<String, dynamic>>()
        .map(ContentItem.fromJson)
        .toList();
  }
}

final contentApiServiceProvider = Provider<ContentApiService>((ref) {
  return ContentApiService(ref.watch(dioProvider));
});
