import 'package:artid/domain/models/share_link.dart';

/// Link di esempio sempre disponibile per testare l'accesso Esterno.
final mockDemoShareLink = ShareLink(
  id: 'demo-link',
  token: 'afam-demo',
  ownerId: 'user-1',
  label: 'Portfolio audizione',
  contentIds: const ['1', '4', '6'],
  includeProfile: true,
);

final mockShareLinks = [mockDemoShareLink];
