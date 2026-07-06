import 'package:artid/domain/models/student_profile.dart';

StudentProfile mockProfileForUser(String userId, {String? name, String? email}) {
  return StudentProfile(
    userId: userId,
    fullName: name ?? 'Studente AFAM',
    email: email ?? 'studente@conservatorio.it',
    institution: 'Conservatorio Statale di Musica',
    course: 'Violino · Biennio superiori',
    studyYear: 2,
    bio:
        'Violinista in formazione con esperienza in ensemble cameristici e orchestra sinfonica. '
        'Interessata alla musica contemporanea e alla didattica.',
    skills: const ['Violino', 'Musica da camera', 'Improvvisazione', 'Solfeggio'],
    cvSummary: 'Biennio superiori · 3 concorsi nazionali · 2 masterclass internazionali',
  );
}
