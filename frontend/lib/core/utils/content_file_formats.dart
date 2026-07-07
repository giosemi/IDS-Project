import 'package:artid/domain/models/content_type.dart';

abstract final class ContentFileFormats {
  static const audio = ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'];
  static const video = ['mov', 'webm', 'mkv'];
  static const score = ['musicxml', 'mxl', 'mid', 'midi'];
  static const cv = ['doc', 'docx'];
  static const image = ['jpg', 'jpeg', 'png', 'webp'];
  static const pdf = 'pdf';

  static List<String> get allowedExtensions => [...audio, ...video, ...score, ...cv, ...image, pdf];

  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  static bool isAllowed(String fileName) => allowedExtensions.contains(extensionOf(fileName));

  static bool isPdf(String fileName) => extensionOf(fileName) == pdf;

  static bool isImage(String fileName) => image.contains(extensionOf(fileName));

  static ContentType? resolveType(String fileName, {ContentType? pdfAs}) {
    final ext = extensionOf(fileName);
    if (ext == pdf) return pdfAs;
    if (audio.contains(ext)) return ContentType.audio;
    if (video.contains(ext)) return ContentType.video;
    if (score.contains(ext)) return ContentType.score;
    if (cv.contains(ext)) return ContentType.cv;
    if (image.contains(ext)) return ContentType.cv;
    return null;
  }

  static String get formatsHint => 'MP3, WAV, M4A · MP4, MOV · PDF, MID, MusicXML · JPG, PNG · DOC, DOCX';
}
