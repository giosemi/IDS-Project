class ShareLink {
  const ShareLink({
    required this.id,
    required this.token,
    required this.ownerId,
    required this.label,
    required this.contentIds,
    this.includeProfile = true,
    this.allowDownload = false,
    this.expiresAt,
    this.viewCount = 0,
    this.lastViewedAt,
  });

  final String id;
  final String token;
  final String ownerId;
  final String label;
  final List<String> contentIds;
  final bool includeProfile;
  final bool allowDownload;
  final DateTime? expiresAt;
  final int viewCount;
  final DateTime? lastViewedAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  String get shareUrl => 'https://artid.afam.it/s/$token';

  factory ShareLink.fromJson(Map<String, dynamic> json) {
    return ShareLink(
      id: json['id'] as String,
      token: json['token'] as String,
      ownerId: json['ownerId'] as String,
      label: json['label'] as String,
      contentIds: (json['contentIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      includeProfile: json['includeProfile'] as bool? ?? true,
      allowDownload: json['allowDownload'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      viewCount: json['viewCount'] as int? ?? 0,
      lastViewedAt: json['lastViewedAt'] != null
          ? DateTime.parse(json['lastViewedAt'] as String)
          : null,
    );
  }

  ShareLink copyWith({
    String? label,
    List<String>? contentIds,
    bool? includeProfile,
    bool? allowDownload,
    DateTime? expiresAt,
    int? viewCount,
    DateTime? lastViewedAt,
  }) {
    return ShareLink(
      id: id,
      token: token,
      ownerId: ownerId,
      label: label ?? this.label,
      contentIds: contentIds ?? this.contentIds,
      includeProfile: includeProfile ?? this.includeProfile,
      allowDownload: allowDownload ?? this.allowDownload,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
    );
  }
}
