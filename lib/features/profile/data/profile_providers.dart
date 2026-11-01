import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/profile/data/mock_user_repository.dart';
import 'package:seek/features/profile/domain/entities/app_user.dart';
import 'package:seek/features/profile/domain/repositories/user_repository.dart';

/// To switch to Firebase, return FirestoreUserRepository() here instead.
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => MockUserRepository(),
);

/// Any user's profile, by id.
final userProvider = StreamProvider.family<AppUser?, String>(
  (ref, userId) => ref.watch(userRepositoryProvider).watchUser(userId),
);

/// The signed-in user's profile (null when signed out).
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream<AppUser?>.value(null);
  return ref.watch(userRepositoryProvider).watchUser(userId);
});
