import 'package:flutter_test/flutter_test.dart';
import 'package:seek/features/clubs/data/mock_club_repository.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';

void main() {
  test(
    'creates a club and rejects a normalized duplicate without side effects',
    () async {
      final repository = MockClubRepository();
      Club club(String name) => Club(
        id: '',
        name: name,
        sport: 'Padel',
        city: 'Jakarta',
        ownerId: 'test-owner',
      );

      final id = await repository.createClub(
        club('Test Community'),
        ownerName: 'Test Owner',
      );
      final created = await repository.watchClub(id).first;
      expect(created?.name, 'Test Community');
      expect(created?.memberCount, 1);

      await expectLater(
        repository.createClub(
          club('  TEST COMMUNITY  '),
          ownerName: 'Test Owner',
        ),
        throwsA(isA<StateError>()),
      );

      expect(await repository.watchMyClubs('test-owner').first, hasLength(1));
      expect(await repository.watchMembers(id).first, hasLength(1));
      final otherId = await repository.createClub(
        club('Another Test Community'),
        ownerName: 'Test Owner',
      );
      expect(otherId, isNot(id));
    },
  );

  test('does not allow the club owner to leave', () async {
    final repository = MockClubRepository();
    const ownerId = 'club-owner';
    final clubId = await repository.createClub(
      const Club(
        id: '',
        name: 'Owner Protected Club',
        sport: 'Running',
        city: 'Bandung',
        ownerId: ownerId,
      ),
      ownerName: 'Owner',
    );

    await expectLater(
      repository.leaveClub(clubId: clubId, userId: ownerId),
      throwsA(isA<StateError>()),
    );
    expect(await repository.watchClub(clubId).first, isNotNull);
    expect(await repository.watchMembers(clubId).first, hasLength(1));
  });
}
