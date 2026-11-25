import 'package:flutter_test/flutter_test.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/scoring/domain/round_robin.dart';

void main() {
  group('goingPlayerIdsFromRsvps', () {
    test('hanya status going, urut joinedAt lalu userId', () {
      final ids = goingPlayerIdsFromRsvps([
        Rsvp(
          meetId: 'm1',
          userId: 'u3',
          userName: 'C',
          status: RsvpStatus.going,
          joinedAt: DateTime(2026, 1, 3),
        ),
        Rsvp(
          meetId: 'm1',
          userId: 'u1',
          userName: 'A',
          status: RsvpStatus.going,
          joinedAt: DateTime(2026, 1, 1),
        ),
        Rsvp(
          meetId: 'm1',
          userId: 'u2',
          userName: 'B',
          status: RsvpStatus.waitlist,
        ),
        Rsvp(
          meetId: 'm1',
          userId: 'u4',
          userName: 'D',
          status: RsvpStatus.going,
          joinedAt: DateTime(2026, 1, 2),
        ),
      ]);
      expect(ids, ['u1', 'u4', 'u3']);
    });
  });

  group('teamsForMeetRoundRobin', () {
    test('basketball: satu pemain satu tim', () {
      final teams = teamsForMeetRoundRobin(
        sport: 'Basketball',
        playerIds: ['a', 'b', 'c'],
      );
      expect(teams, [
        ['a'],
        ['b'],
        ['c'],
      ]);
    });

    test('padel genap >=4: pasangan ganda', () {
      final teams = teamsForMeetRoundRobin(
        sport: 'Padel',
        playerIds: ['a', 'b', 'c', 'd'],
      );
      expect(teams, [
        ['a', 'b'],
        ['c', 'd'],
      ]);
    });
  });

  group('generateRoundRobin', () {
    test('3 tim → 3 match (tanpa bye)', () {
      final matches = generateRoundRobin(
        teams: [
          ['t1'],
          ['t2'],
          ['t3'],
        ],
        idPrefix: 'm1',
        meetId: 'm1',
      );
      expect(matches, hasLength(3));
      expect(matches.map((m) => m.id).toSet(), {
        'm1-r1-1',
        'm1-r2-1',
        'm1-r3-1',
      });
    });

    test('generateMeetRoundRobin mengisi meetId', () {
      final matches = generateMeetRoundRobin(
        meetId: 'm1',
        sport: 'Basketball',
        playerIds: ['u1', 'u2'],
      );
      expect(matches, hasLength(1));
      expect(matches.first.meetId, 'm1');
      expect(matches.first.teamA, ['u1']);
      expect(matches.first.teamB, ['u2']);
    });
  });
}
