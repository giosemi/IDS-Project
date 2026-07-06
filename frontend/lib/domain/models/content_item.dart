import 'package:artid/domain/models/content_type.dart';

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.ownerId,
    required this.type,
    this.technique,
    this.dimensions,
    this.duration,
    this.subtitle,
    this.fileName,
    this.filePath,
  });

  final String id;
  final String title;
  final String description;
  final int year;
  final String ownerId;
  final ContentType type;
  final String? technique;
  final String? dimensions;
  final String? duration;
  final String? subtitle;
  final String? fileName;
  final String? filePath;

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      ownerId: json['ownerId'] as String,
      type: ContentType.fromJson(json['type'] as String),
      technique: json['technique'] as String?,
      dimensions: json['dimensions'] as String?,
      duration: json['duration'] as String?,
      subtitle: json['subtitle'] as String?,
      fileName: json['fileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'year': year,
        'type': type.toJson(),
        if (technique != null) 'technique': technique,
        if (dimensions != null) 'dimensions': dimensions,
        if (duration != null) 'duration': duration,
        if (subtitle != null) 'subtitle': subtitle,
        if (fileName != null) 'fileName': fileName,
      };

  ContentItem copyWith({
    String? title,
    String? description,
    int? year,
    ContentType? type,
    String? technique,
    String? dimensions,
    String? duration,
    String? subtitle,
    String? fileName,
    String? filePath,
  }) {
    return ContentItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      year: year ?? this.year,
      ownerId: ownerId,
      type: type ?? this.type,
      technique: technique ?? this.technique,
      dimensions: dimensions ?? this.dimensions,
      duration: duration ?? this.duration,
      subtitle: subtitle ?? this.subtitle,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
    );
  }
}
