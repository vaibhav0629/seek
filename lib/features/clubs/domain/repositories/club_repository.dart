import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';

/// Clubs and their members.
/// Firestore paths: clubs/{clubId} and clubs/{clubId}/members/{userId}
abstract class ClubRepository {
  /// Public clubs, optionally filtered by city and/or sport.
  Stream<List<Club>> watchClubs({String? city, String? sport});

  /// Clubs the user is a member of (private ones included).
  Stream<List<Club>> watchMyClubs(String userId);

  Stream<Club?> watchClub(String clubId);

  Stream<List<ClubMember>> watchMembers(String clubId);

  /// Pass a club with an empty id and the repository assigns one.
  /// The owner becomes the club's first admin. Returns the new id.
  Future<String> createClub(Club club, {required String ownerName});

  Future<void> joinClub({
    required String clubId,
    required String userId,
    required String userName,
  });

  Future<void> leaveClub({required String clubId, required String userId});

  /// Promotes a member to [ClubRole.admin].
  Future<void> promoteMember({
    required String clubId,
    required String userId,
  });

  /// Removes a member from the club (same effect as leaving, but done by an admin).
  Future<void> kickMember({
    required String clubId,
    required String userId,
  });
}