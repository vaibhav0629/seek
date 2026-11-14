import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/club_permissions.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/competitions/data/competition_providers.dart';

/// True when the signed-in user may manage this tournament: enter scores,
/// start it, close registration.
///
/// Allowed: the person who created the tournament, or an admin of its club
/// (see isCreatorOrClubAdmin). Everyone else gets false.
///
///   if (ref.watch(canManageCompetitionProvider(competitionId))) {
///     // show the "Enter score" button
///   }
final canManageCompetitionProvider =
    Provider.family<bool, String>((ref, competitionId) {
  final me = ref.watch(currentUserIdProvider);
  final competition = ref.watch(competitionProvider(competitionId)).value;
  if (me == null || competition == null) return false;

  final members = ref.watch(clubMembersProvider(competition.clubId)).value ??
      const <ClubMember>[];
  return isCreatorOrClubAdmin(
    userId: me,
    createdBy: competition.createdBy,
    clubMembers: members,
  );
});
