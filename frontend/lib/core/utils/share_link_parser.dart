/// Estrae il token da un URL ArtID o da testo incollato.
String? parseShareToken(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final pathMatch = RegExp(r'/s/([^/?#\s]+)').firstMatch(trimmed);
  if (pathMatch != null) return pathMatch.group(1);

  if (RegExp(r'^afam-[a-z0-9]+$').hasMatch(trimmed)) return trimmed;

  return null;
}
