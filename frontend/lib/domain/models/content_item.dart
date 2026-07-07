import 'package:artid/domain/models/content_type.dart';

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.ownerId,
    required this.type,
    this.duration,
    this.fileName,
    this.filePath,
    this.hasMedia = false,
  });

  final String id;
  final String title;
  final String description;
  final int year;
  final String ownerId;
  final ContentType type;
  final String? duration;
  final String? fileName;
  final String? filePath;
  final bool hasMedia;

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      ownerId: json['ownerId'] as String,
      type: ContentType.fromJson(json['type'] as String),
      duration: json['duration'] as String?,
      fileName: json['fileName'] as String?,
      hasMedia: json['hasMedia'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'year': year,
        'type': type.toJson(),
        if (duration != null) 'duration': duration,
        if (fileName != null) 'fileName': fileName,
      };

  ContentItem copyWith({
    String? title,
    String? description,
    int? year,
    ContentType? type,
    String? duration,
    String? fileName,
    String? filePath,
    bool? hasMedia,
  }) {
    return ContentItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      year: year ?? this.year,
      ownerId: ownerId,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      hasMedia: hasMedia ?? this.hasMedia,
    );
  }
}
