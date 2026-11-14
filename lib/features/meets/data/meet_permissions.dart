import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/club_permissions.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/meets/data/meet_providers.dart';

/// True when the signed-in user may manage this meet: enter scores, check
/// players in, mark payments as paid.
///
/// Allowed: the person who created the meet, or an admin of the club that
/// runs it (see isCreatorOrClubAdmin). Everyone else gets false.
///
///   if (ref.watch(canManageMeetProvider(meetId))) {
///     // show the "Enter score" button
///   }
final canManageMeetProvider = Provider.family<bool, String>((ref, meetId) {
  final me = ref.watch(currentUserIdProvider);
  final meet = ref.watch(meetProvider(meetId)).value;
  if (me == null || meet == null) return false;

  final members = ref.watch(clubMembersProvider(meet.clubId)).value ??
      const <ClubMember>[];
  return isCreatorOrClubAdmin(
    userId: me,
    createdBy: meet.createdBy,
    clubMembers: members,
  );
});
