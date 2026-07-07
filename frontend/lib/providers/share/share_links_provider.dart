import 'package:artid/data/services/share_links_api_service.dart';
import 'package:artid/domain/models/share_link.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:dio/dio.dart';
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

  Future<ShareLink> create({
    required String label,
    required List<String> contentIds,
    bool includeProfile = true,
    bool allowDownload = false,
    DateTime? expiresAt,
  }) async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      throw const ShareLinkException('Devi essere autenticato per creare un link');
    }
    try {
      final link = await ref.read(shareLinksApiServiceProvider).create(
            label: label,
            contentIds: contentIds,
            includeProfile: includeProfile,
            allowDownload: allowDownload,
            expiresAt: expiresAt,
          );
      state = [...state, link];
      return link;
    } on DioException catch (e) {
      throw ShareLinkException(_messageFromDio(e));
    } catch (_) {
      throw const ShareLinkException('Errore nella creazione del link');
    }
  }

  Future<void> remove(String id) async {
    try {
      await ref.read(shareLinksApiServiceProvider).delete(id);
      state = state.where((link) => link.id != id).toList();
    } catch (_) {}
  }
}

class ShareLinkException implements Exception {
  const ShareLinkException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _messageFromDio(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  if (e.response?.statusCode == 401) {
    return 'Sessione scaduta. Esci e accedi di nuovo.';
  }
  if (e.response?.statusCode == 400) {
    return 'Dati non validi. Verifica descrizione, opere selezionate e scadenza.';
  }
  return 'Impossibile creare il link. Verifica la connessione al server.';
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
