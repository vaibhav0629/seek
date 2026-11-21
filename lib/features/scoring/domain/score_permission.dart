import 'package:seek/features/clubs/domain/club_permissions.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';

bool canEnterScore({
  required String userId,
  required Meet meet,
  required List<ClubMember> clubMembers,
}) => isCreatorOrClubAdmin(
  userId: userId,
  createdBy: meet.createdBy,
  clubMembers: clubMembers,
);

Map<String, String> playerNamesFrom(List<ClubMember> members) => {
  for (final m in members) m.userId: m.userName,
};
