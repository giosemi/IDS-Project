import 'package:artid/data/services/content_api_service.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserContentsState {
  const UserContentsState({
    this.items = const [],
    this.isLoading = false,
  });

  final List<ContentItem> items;
  final bool isLoading;

  Set<String> get deletedIds => const {};

  UserContentsState copyWith({
    List<ContentItem>? items,
    bool? isLoading,
    Set<String>? deletedIds,
  }) {
    return UserContentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserContentsNotifier extends Notifier<UserContentsState> {
  @override
  UserContentsState build() {
    ref.listen(authProvider.select((s) => s.user?.id), (previous, next) {
      if (next == null) {
        state = const UserContentsState();
      } else if (previous != next) {
        Future.microtask(_load);
      }
    });

    final userId = ref.read(authProvider).user?.id;
    if (userId != null) Future.microtask(_load);

    return const UserContentsState();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await ref.read(contentApiServiceProvider).getMyContent();
      state = UserContentsState(items: items);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> add(ContentItem item) async {
    try {
      final created = await ref.read(contentApiServiceProvider).create(item);
      state = state.copyWith(items: [...state.items, created]);
    } catch (_) {}
  }

  Future<void> update(ContentItem item) async {
    try {
      final updated = await ref.read(contentApiServiceProvider).update(item.id, item);
      final index = state.items.indexWhere((e) => e.id == item.id);
      if (index >= 0) {
        final items = [...state.items]..[index] = updated;
        state = state.copyWith(items: items);
      } else {
        state = state.copyWith(items: [...state.items, updated]);
      }
    } catch (_) {}
  }

  Future<void> remove(String id) async {
    try {
      await ref.read(contentApiServiceProvider).delete(id);
      state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
    } catch (_) {}
  }
}

final userContentsProvider =
    NotifierProvider<UserContentsNotifier, UserContentsState>(UserContentsNotifier.new);
