import 'dart:async';

import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/auth/domain/repositories/auth_repository.dart';

/// Fake login. It starts signed in as the mock user (Budi, id "u1").
/// Any email and password signs in as that same user.
class MockAuthRepository implements AuthRepository {
  String? _userId = kMockCurrentUserId;
  final StreamController<String?> _changes =
      StreamController<String?>.broadcast();

  @override
  String? get currentUserId => _userId;

  @override
  Stream<String?> authStateChanges() async* {
    yield _userId;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await mockDelay();
    _setUser(kMockCurrentUserId);
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
    await mockDelay();
    _setUser(kMockCurrentUserId);
  }

  @override
  Future<void> signOut() async {
    await mockDelay();
    _setUser(null);
  }

  void _setUser(String? userId) {
    _userId = userId;
    _changes.add(userId);
  }
}