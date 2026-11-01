import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/mock_auth_repository.dart';
import 'package:seek/features/auth/domain/repositories/auth_repository.dart';

/// To switch to Firebase, return FirebaseAuthRepository() here instead.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

/// Emits the signed-in user's id, or null when signed out.
final authStateProvider = StreamProvider<String?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// The signed-in user's id, or null. Use this in screens.
final currentUserIdProvider = Provider<String?>(
  (ref) =>
      ref.watch(authStateProvider).value ??
      ref.watch(authRepositoryProvider).currentUserId,
);
