class StudentProfile {
  const StudentProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.institution,
    required this.course,
    required this.studyYear,
    required this.bio,
    this.skills = const [],
    this.cvSummary,
  });

  final String userId;
  final String fullName;
  final String email;
  final String institution;
  final String course;
  final int studyYear;
  final String bio;
  final List<String> skills;
  final String? cvSummary;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      course: json['course'] as String? ?? '',
      studyYear: json['studyYear'] as int? ?? 1,
      bio: json['bio'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? const [],
      cvSummary: json['cvSummary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'institution': institution,
        'course': course,
        'studyYear': studyYear,
        'bio': bio,
        'skills': skills,
        if (cvSummary != null) 'cvSummary': cvSummary,
      };

  StudentProfile copyWith({
    String? fullName,
    String? email,
    String? institution,
    String? course,
    int? studyYear,
    String? bio,
    List<String>? skills,
    String? cvSummary,
  }) {
    return StudentProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      institution: institution ?? this.institution,
      course: course ?? this.course,
      studyYear: studyYear ?? this.studyYear,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      cvSummary: cvSummary ?? this.cvSummary,
    );
  }
}
