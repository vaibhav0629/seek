import 'package:flutter_test/flutter_test.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/scoring/domain/bracket_generator.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';

void main() {
  group('bracketSeedOrder', () {
    test('4 pemain', () {
      expect(bracketSeedOrder(4), [1, 4, 2, 3]);
    });
  });

  group('generateSingleEliminationBracket', () {
    test('4 pemain: semi + final, seeding 1v4 dan 2v3', () {
      final comp = Competition(
        id: 'comp-test',
        clubId: 'c1',
        title: 'Test',
        sport: 'Basketball',
        createdBy: 'u1',
        playerIds: ['u1', 'u2', 'u3', 'u5'],
        seeds: {'u1': 1, 'u2': 2, 'u3': 3, 'u5': 4},
        maxPlayers: 4,
      );
      final matches = generateSingleEliminationBracket(competition: comp);
      expect(matches, hasLength(3));

      final sf1 = matches.firstWhere((m) => m.id == 'comp-test-sf1');
      expect(sf1.teamA, ['u1']);
      expect(sf1.teamB, ['u5']);
      expect(sf1.nextMatchId, 'comp-test-final');
      expect(sf1.nextMatchSide, TeamSide.a);

      final sf2 = matches.firstWhere((m) => m.id == 'comp-test-sf2');
      expect(sf2.teamA, ['u2']);
      expect(sf2.teamB, ['u3']);
      expect(sf2.nextMatchSide, TeamSide.b);

      final fin = matches.firstWhere((m) => m.id == 'comp-test-final');
      expect(fin.nextMatchId, isNull);
    });

    test('2 pemain: hanya final', () {
      final comp = Competition(
        id: 'c2p',
        clubId: 'c1',
        title: 'T',
        sport: 'Basketball',
        createdBy: 'u1',
        playerIds: ['u1', 'u2'],
        maxPlayers: 8,
      );
      final matches = generateSingleEliminationBracket(competition: comp);
      expect(matches, hasLength(1));
      expect(matches.first.id, 'c2p-final');
      expect(matches.first.teamA, ['u1']);
      expect(matches.first.teamB, ['u2']);
    });
  });
}
