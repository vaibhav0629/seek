import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/data/mock_club_repository.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/clubs/presentation/screens/join_club_button.dart';

class RecordingClubRepository extends MockClubRepository {
  int leaveCalls = 0;

  @override
  Future<void> leaveClub({
    required String clubId,
    required String userId,
  }) async {
    expect(clubId, 'test-club');
    expect(userId, 'member');
    leaveCalls++;
  }
}

void main() {
  testWidgets('leaving requires explicit confirmation', (tester) async {
    final repository = RecordingClubRepository();
    const club = Club(
      id: 'test-club',
      name: 'Test Club',
      sport: 'Padel',
      city: 'Jakarta',
      ownerId: 'owner',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWithValue('member'),
          clubRepositoryProvider.overrideWithValue(repository),
          clubMembersProvider(club.id).overrideWith(
            (ref) => Stream.value([
              const ClubMember(userId: 'member', userName: 'Member'),
            ]),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: JoinClubButton(club: club)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Keluar dari club?'), findsOneWidget);
    expect(repository.leaveCalls, 0);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(repository.leaveCalls, 0);
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya, keluar'));
    await tester.pumpAndSettle();
    expect(repository.leaveCalls, 1);
    expect(find.text('Kamu keluar dari Test Club'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
