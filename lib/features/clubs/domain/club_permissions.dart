import 'package:seek/features/clubs/domain/entities/club_member.dart';

/// The ONE rule for "who may manage this meet or tournament":
/// the person who created it, or an admin of the club that runs it.
///
/// Scoring, payments, check-in and tournaments should all use this (directly,
/// or through canManageMeetProvider / canManageCompetitionProvider), so the
/// rule can never differ between screens.
///
/// It only decides what the app SHOWS. The real lock will be Firestore
/// security rules, added later.
bool isCreatorOrClubAdmin({
  required String? userId,
  required String createdBy,
  required List<ClubMember> clubMembers,
}) {
  if (userId == null) return false; // signed out
  if (createdBy == userId) return true;
  return clubMembers
      .any((m) => m.userId == userId && m.role == ClubRole.admin);
}
