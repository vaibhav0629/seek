import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/profile/domain/entities/app_user.dart';
import 'package:seek/features/profile/domain/repositories/user_repository.dart';

/// The real profiles. One document per user at users/{uid}.
class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<AppUser?> watchUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return AppUser.fromMap(data, snapshot.id);
    });
  }

  @override
  Future<void> saveUser(AppUser user) {
    // merge: true keeps any field this app does not know about.
    return _db
        .collection('users')
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }
}