import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';

/// Hanya admin club atau pembuat meet yang boleh input skor.
bool canEnterScore({
  required String userId,
  required Meet meet,
  required List<ClubMember> clubMembers,
}) {
  if (meet.createdBy == userId) return true;
  return clubMembers.any((m) => m.userId == userId && m.role == ClubRole.admin);
}

/// id pemain -> nama.
Map<String, String> playerNamesFrom(List<ClubMember> members) => {
  for (final m in members) m.userId: m.userName,
};
