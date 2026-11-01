import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/domain/repositories/match_repository.dart';

class MockMatchRepository implements MatchRepository {
  final MockCollection<GameMatch> _matches =
      MockCollection<GameMatch>(mockMatches);

  @override
  Stream<List<GameMatch>> watchMatches({String? meetId, String? competitionId}) {
    return _matches.watch((matches) {
      final result = matches
          .where((m) => meetId == null || m.meetId == meetId)
          .where((m) =>
              competitionId == null || m.competitionId == competitionId)
          .toList()
        ..sort((a, b) {
          final byRound = a.round.compareTo(b.round);
          return byRound != 0 ? byRound : a.position.compareTo(b.position);
        });
      return result;
    });
  }

  @override
  Future<void> saveMatches(List<GameMatch> matches) async {
    await mockDelay();
    _matches.mutate((items) {
      for (final match in matches) {
        final index = items.indexWhere((m) => m.id == match.id);
        if (index == -1) {
          items.add(match);
        } else {
          items[index] = match;
        }
      }
    });
  }

  @override
  Future<void> updateScore({
    required String matchId,
    required int scoreA,
    required int scoreB,
  }) async {
    await mockDelay();
    _matches.mutate((items) {
      final index = items.indexWhere((m) => m.id == matchId);
      if (index == -1) return;
      items[index] = items[index].copyWith(
        scoreA: scoreA,
        scoreB: scoreB,
        status: MatchStatus.finished,
        playedAt: DateTime.now(),
      );
    });
  }
}
