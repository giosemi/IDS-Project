import 'package:artid/data/services/profile_api_service.dart';
import 'package:artid/domain/models/student_profile.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileNotifier extends Notifier<StudentProfile?> {
  @override
  StudentProfile? build() {
    ref.listen(authProvider.select((s) => s.user?.id), (previous, next) {
      if (next == null) {
        state = null;
      } else if (previous != next) {
        Future.microtask(_load);
      }
    });

    final userId = ref.read(authProvider).user?.id;
    if (userId != null) Future.microtask(_load);

    return null;
  }

  Future<void> _load() async {
    try {
      state = await ref.read(profileApiServiceProvider).getMyProfile();
    } catch (_) {}
  }

  Future<void> update(StudentProfile profile) async {
    try {
      state = await ref.read(profileApiServiceProvider).updateProfile(profile);
    } catch (_) {
      state = profile;
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, StudentProfile?>(ProfileNotifier.new);

final profileByUserIdProvider = Provider.family<StudentProfile?, String>((ref, userId) {
  final profile = ref.watch(profileProvider);
  if (profile?.userId == userId) return profile;
  return null;
});
