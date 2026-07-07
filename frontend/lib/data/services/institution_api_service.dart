import 'dart:convert';

import 'package:artid/data/api/api_client.dart';
import 'package:artid/domain/models/afam_institution.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<dynamic> _parseJsonList(Object? data) {
  if (data == null) {
    throw const FormatException('Risposta vuota dal server');
  }
  if (data is List) return data;
  if (data is String) return jsonDecode(data) as List<dynamic>;
  throw FormatException('Formato risposta non valido: ${data.runtimeType}');
}

class InstitutionApiService {
  const InstitutionApiService(this._dio);

  final Dio _dio;

  Future<List<AfamInstitution>> fetchAfamInstitutions() async {
    final res = await _dio.get<dynamic>('/api/institutions/afam');
    return _parseJsonList(res.data)
        .map((item) => AfamInstitution.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}

final institutionApiServiceProvider = Provider<InstitutionApiService>((ref) {
  return InstitutionApiService(ref.watch(dioProvider));
});

final afamInstitutionsProvider = FutureProvider<List<AfamInstitution>>((ref) async {
  return ref.watch(institutionApiServiceProvider).fetchAfamInstitutions();
});
