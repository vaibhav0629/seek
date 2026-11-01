import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/scoring/data/mock_match_repository.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/domain/repositories/match_repository.dart';

/// To switch to Firebase, return FirestoreMatchRepository() here instead.
final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => MockMatchRepository(),
);

/// Matches of a casual meet (round robin).
final meetMatchesProvider = StreamProvider.family<List<GameMatch>, String>(
  (ref, meetId) =>
      ref.watch(matchRepositoryProvider).watchMatches(meetId: meetId),
);

/// Matches of a tournament (bracket).
final competitionMatchesProvider =
    StreamProvider.family<List<GameMatch>, String>(
  (ref, competitionId) => ref
      .watch(matchRepositoryProvider)
      .watchMatches(competitionId: competitionId),
);
