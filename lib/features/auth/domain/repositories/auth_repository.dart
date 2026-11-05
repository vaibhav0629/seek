/// Login and sign-up. The real version wraps FirebaseAuth.
abstract class AuthRepository {
  /// Emits the signed-in user's id, or null when signed out.
  Stream<String?> authStateChanges();

  /// The signed-in user's id right now, or null.
  String? get currentUserId;

  Future<void> signIn({required String email, required String password});

  /// The extra profile fields are optional so existing callers keep working.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phone,
    String? city,
    String? sport,
    String? skillLevel,
  });

  Future<void> signOut();
}