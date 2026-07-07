import 'package:artid/data/api/content_media_urls.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class SharedContentDownloadService {
  const SharedContentDownloadService();

  Future<String> download({
    required String shareToken,
    required ContentItem item,
  }) async {
    final fileName = item.fileName;
    if (fileName == null || fileName.isEmpty) {
      throw SharedContentDownloadException('Nessun file associato a questa opera');
    }
    if (!item.hasMedia) {
      throw SharedContentDownloadException('Il file non è disponibile sul server');
    }

    final url = contentMediaUrl(contentId: item.id, shareToken: shareToken);
    final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final safeName = _safeFileName(fileName);
    final savePath = '${directory.path}/$safeName';

    try {
      await Dio().download(url, savePath);
      return savePath;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
        throw SharedContentDownloadException('Download non consentito o file non trovato');
      }
      throw SharedContentDownloadException('Impossibile scaricare il file');
    }
  }

  String _safeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}

class SharedContentDownloadException implements Exception {
  const SharedContentDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
