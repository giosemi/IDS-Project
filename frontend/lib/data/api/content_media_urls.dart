import 'package:artid/data/api/api_constants.dart';

String contentMediaUrl({
  required String contentId,
  String? shareToken,
}) {
  if (shareToken != null) {
    return '$kBaseUrl/api/s/$shareToken/content/$contentId/media';
  }
  return '$kBaseUrl/api/content/$contentId/media';
}
