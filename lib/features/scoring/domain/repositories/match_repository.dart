import 'package:seek/features/scoring/domain/entities/game_match.dart';

/// Matches for casual meets and for tournaments.
/// Firestore path: matches/{matchId}
abstract class MatchRepository {
  /// Matches for a meet or for a competition, sorted by round then position.
  Stream<List<GameMatch>> watchMatches({String? meetId, String? competitionId});

  /// Creates or replaces matches. Every match must already have an id
  /// (the schedule generator makes ids like "m1-r1-1").
  Future<void> saveMatches(List<GameMatch> matches);

  /// Records the final score and marks the match finished.
  /// Moving the winner into the next bracket slot is the bracket logic's
  /// job (Member 5), not the repository's.
  Future<void> updateScore({
    required String matchId,
    required int scoreA,
    required int scoreB,
  });
}
