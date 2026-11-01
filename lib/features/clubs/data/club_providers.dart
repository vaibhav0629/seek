import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/mock_club_repository.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/clubs/domain/repositories/club_repository.dart';

/// To switch to Firebase, return FirestoreClubRepository() here instead.
final clubRepositoryProvider = Provider<ClubRepository>(
  (ref) => MockClubRepository(),
);

/// All public clubs. For filtering, call the repository's watchClubs.
final clubsProvider = StreamProvider<List<Club>>(
  (ref) => ref.watch(clubRepositoryProvider).watchClubs(),
);

/// Clubs the signed-in user belongs to.
final myClubsProvider = StreamProvider<List<Club>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream<List<Club>>.value(const []);
  return ref.watch(clubRepositoryProvider).watchMyClubs(userId);
});

final clubProvider = StreamProvider.family<Club?, String>(
  (ref, clubId) => ref.watch(clubRepositoryProvider).watchClub(clubId),
);

final clubMembersProvider = StreamProvider.family<List<ClubMember>, String>(
  (ref, clubId) => ref.watch(clubRepositoryProvider).watchMembers(clubId),
);
