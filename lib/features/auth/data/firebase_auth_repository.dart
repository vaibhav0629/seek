import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seek/features/auth/domain/auth_exception.dart';
import 'package:seek/features/auth/domain/repositories/auth_repository.dart';

/// The real login. Accounts live in Firebase Auth, and the profile is saved in
/// Firestore at users/{uid} (the same uid that currentUserId returns).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<String?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Login failed');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
    String? city,
    String? sport,
    String? skillLevel,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(displayName.trim());

      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': displayName.trim(),
        'email': email.trim(),
        'phone': phone?.trim(),
        'city': city,
        'sport': sport,
        'skillLevel': skillLevel,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}