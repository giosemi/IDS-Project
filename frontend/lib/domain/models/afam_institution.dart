class AfamInstitution {
  const AfamInstitution({
    required this.id,
    required this.name,
    required this.city,
  });

  final String id;
  final String name;
  final String city;

  factory AfamInstitution.fromJson(Map<String, dynamic> json) {
    return AfamInstitution(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
    );
  }

  String get label => '$name — $city';
}
