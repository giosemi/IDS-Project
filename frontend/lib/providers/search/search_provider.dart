import 'package:artid/domain/models/content_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;

  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

final searchResultsProvider = Provider<List<ContentItem>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return [];

  return [];
});
