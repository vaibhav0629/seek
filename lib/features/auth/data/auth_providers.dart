import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/firebase_auth_repository.dart';

import 'package:seek/features/auth/domain/repositories/auth_repository.dart';

/// Uses the mock repository while developing without Firebase sign-in.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
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
