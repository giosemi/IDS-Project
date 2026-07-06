import 'package:artid/data/services/share_links_api_service.dart';
import 'package:artid/domain/models/share_link.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareLinksNotifier extends Notifier<List<ShareLink>> {
  @override
  List<ShareLink> build() {
    ref.listen(authProvider.select((s) => s.user?.id), (previous, next) {
      if (next == null) {
        state = [];
      } else if (previous != next) {
        Future.microtask(_load);
      }
    });

    final userId = ref.read(authProvider).user?.id;
    if (userId != null) Future.microtask(_load);

    return [];
  }

  Future<void> _load() async {
    try {
      state = await ref.read(shareLinksApiServiceProvider).getMyLinks();
    } catch (_) {}
  }

  Future<ShareLink?> create({
    required String label,
    required List<String> contentIds,
    bool includeProfile = true,
    DateTime? expiresAt,
  }) async {
    final user = ref.read(authProvider).user;
    if (user == null) return null;
    try {
      final link = await ref.read(shareLinksApiServiceProvider).create(
            label: label,
            contentIds: contentIds,
            includeProfile: includeProfile,
            expiresAt: expiresAt,
          );
      state = [...state, link];
      return link;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String id) async {
    try {
      await ref.read(shareLinksApiServiceProvider).delete(id);
      state = state.where((link) => link.id != id).toList();
    } catch (_) {}
  }
}

final shareLinksProvider =
    NotifierProvider<ShareLinksNotifier, List<ShareLink>>(ShareLinksNotifier.new);

final shareLinkByTokenProvider = Provider.family<ShareLink?, String>((ref, token) {
  final links = ref.watch(shareLinksProvider);
  try {
    return links.firstWhere((link) => link.token == token);
  } catch (_) {
    return null;
  }
});
