import 'package:artid/data/api/api_client.dart';
import 'package:artid/domain/models/portfolio_section.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioApiService {
  const PortfolioApiService(this._dio);

  final Dio _dio;

  Future<List<PortfolioSection>> getSections() async {
    final res = await _dio.get<List<dynamic>>('/api/portfolio/sections');
    return res.data!
        .cast<Map<String, dynamic>>()
        .map(PortfolioSection.fromJson)
        .toList();
  }

  Future<PortfolioSection> addSection(String title) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/portfolio/sections',
      data: {'title': title},
    );
    return PortfolioSection.fromJson(res.data!);
  }

  Future<PortfolioSection> renameSection(String id, String title) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/portfolio/sections/$id',
      data: {'title': title},
    );
    return PortfolioSection.fromJson(res.data!);
  }

  Future<void> deleteSection(String id) async {
    await _dio.delete<void>('/api/portfolio/sections/$id');
  }

  Future<void> reorderSections(List<String> ids) async {
    await _dio.put<void>(
      '/api/portfolio/sections/reorder',
      data: {'ids': ids},
    );
  }

  Future<void> assignContent(String sectionId, String contentId) async {
    await _dio.put<void>(
      '/api/portfolio/sections/$sectionId/assign',
      data: {'contentId': contentId},
    );
  }
}

final portfolioApiServiceProvider = Provider<PortfolioApiService>((ref) {
  return PortfolioApiService(ref.watch(dioProvider));
});
