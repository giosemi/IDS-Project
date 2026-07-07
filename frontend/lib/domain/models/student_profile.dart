class StudentProfile {
  const StudentProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.institution,
    required this.studyYear,
    required this.bio,
  });

  final String userId;
  final String fullName;
  final String email;
  final String institution;
  final int studyYear;
  final String bio;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      studyYear: json['studyYear'] as int? ?? 1,
      bio: json['bio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'institution': institution,
        'studyYear': studyYear,
        'bio': bio,
      };

  StudentProfile copyWith({
    String? fullName,
    String? email,
    String? institution,
    int? studyYear,
    String? bio,
  }) {
    return StudentProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      institution: institution ?? this.institution,
      studyYear: studyYear ?? this.studyYear,
      bio: bio ?? this.bio,
    );
  }
}
