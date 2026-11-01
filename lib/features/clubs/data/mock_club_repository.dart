import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/clubs/domain/repositories/club_repository.dart';

class MockClubRepository implements ClubRepository {
  final MockCollection<Club> _clubs = MockCollection<Club>(mockClubs);
  final MockCollection<ClubMembership> _members =
      MockCollection<ClubMembership>(mockClubMembers);

  @override
  Stream<List<Club>> watchClubs({String? city, String? sport}) {
    return _clubs.watch(
      (clubs) => clubs
          .where((c) => !c.isPrivate)
          .where((c) =>
              city == null || c.city.toLowerCase() == city.toLowerCase())
          .where((c) =>
              sport == null || c.sport.toLowerCase() == sport.toLowerCase())
          .toList(),
    );
  }

  @override
  Stream<List<Club>> watchMyClubs(String userId) {
    return _members.watch((members) {
      final clubIds = members
          .where((m) => m.member.userId == userId)
          .map((m) => m.clubId)
          .toSet();
      return _clubs.items.where((c) => clubIds.contains(c.id)).toList();
    });
  }

  @override
  Stream<Club?> watchClub(String clubId) {
    return _clubs.watch(
      (clubs) => clubs.where((c) => c.id == clubId).firstOrNull,
    );
  }

  @override
  Stream<List<ClubMember>> watchMembers(String clubId) {
    return _members.watch(
      (members) => members
          .where((m) => m.clubId == clubId)
          .map((m) => m.member)
          .toList(),
    );
  }

  @override
  Future<String> createClub(Club club, {required String ownerName}) async {
    await mockDelay();
    final id = club.id.isEmpty ? mockId('club') : club.id;
    _clubs.mutate((items) => items.add(_copy(club, id: id, memberCount: 1)));
    _members.mutate(
      (items) => items.add((
        clubId: id,
        member: ClubMember(
          userId: club.ownerId,
          userName: ownerName,
          role: ClubRole.admin,
          joinedAt: DateTime.now(),
        ),
      )),
    );
    return id;
  }

  @override
  Future<void> joinClub({
    required String clubId,
    required String userId,
    required String userName,
  }) async {
    await mockDelay();
    final alreadyMember = _members.items
        .any((m) => m.clubId == clubId && m.member.userId == userId);
    if (alreadyMember) return;
    _members.mutate(
      (items) => items.add((
        clubId: clubId,
        member: ClubMember(
          userId: userId,
          userName: userName,
          joinedAt: DateTime.now(),
        ),
      )),
    );
    _adjustCount(clubId, 1);
  }

  @override
  Future<void> leaveClub({
    required String clubId,
    required String userId,
  }) async {
    await mockDelay();
    final before = _members.items.length;
    _members.mutate(
      (items) => items
          .removeWhere((m) => m.clubId == clubId && m.member.userId == userId),
    );
    if (_members.items.length < before) _adjustCount(clubId, -1);
  }

  void _adjustCount(String clubId, int delta) {
    _clubs.mutate((items) {
      final index = items.indexWhere((c) => c.id == clubId);
      if (index == -1) return;
      items[index] =
          _copy(items[index], memberCount: items[index].memberCount + delta);
    });
  }

  Club _copy(Club c, {String? id, int? memberCount}) => Club(
        id: id ?? c.id,
        name: c.name,
        sport: c.sport,
        city: c.city,
        ownerId: c.ownerId,
        description: c.description,
        isPrivate: c.isPrivate,
        memberCount: memberCount ?? c.memberCount,
        createdAt: c.createdAt ?? DateTime.now(),
      );
}
