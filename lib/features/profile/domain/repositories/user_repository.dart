import 'package:seek/features/profile/domain/entities/app_user.dart';

/// User profiles. Firestore path: users/{uid}
abstract class UserRepository {
  Stream<AppUser?> watchUser(String userId);

  /// Creates or updates a profile (the document id is the user id).
  Future<void> saveUser(AppUser user);
}
