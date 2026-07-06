class PortfolioSection {
  const PortfolioSection({
    required this.id,
    required this.title,
    this.contentIds = const [],
  });

  final String id;
  final String title;
  final List<String> contentIds;

  factory PortfolioSection.fromJson(Map<String, dynamic> json) {
    return PortfolioSection(
      id: json['id'] as String,
      title: json['title'] as String,
      contentIds: (json['contentIds'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  PortfolioSection copyWith({
    String? title,
    List<String>? contentIds,
  }) {
    return PortfolioSection(
      id: id,
      title: title ?? this.title,
      contentIds: contentIds ?? this.contentIds,
    );
  }
}
