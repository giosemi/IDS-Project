import 'package:flutter/material.dart';

enum ContentType {
  audio('Audio', Icons.audiotrack_rounded),
  video('Video', Icons.videocam_rounded),
  score('Spartito', Icons.music_note_rounded),
  cv('Curriculum', Icons.description_rounded);

  const ContentType(this.label, this.icon);

  final String label;
  final IconData icon;

  static ContentType fromJson(String value) => ContentType.values.firstWhere(
        (e) => e.name.toUpperCase() == value.toUpperCase(),
      );

  String toJson() => name.toUpperCase();
}
