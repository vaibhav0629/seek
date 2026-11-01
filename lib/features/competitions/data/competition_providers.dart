import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/competitions/data/mock_competition_repository.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/competitions/domain/repositories/competition_repository.dart';

/// To switch to Firebase, return FirestoreCompetitionRepository() here.
final competitionRepositoryProvider = Provider<CompetitionRepository>(
  (ref) => MockCompetitionRepository(),
);

final competitionProvider = StreamProvider.family<Competition?, String>(
  (ref, competitionId) =>
      ref.watch(competitionRepositoryProvider).watchCompetition(competitionId),
);

/// Tournaments of one club.
final clubCompetitionsProvider =
    StreamProvider.family<List<Competition>, String>(
  (ref, clubId) =>
      ref.watch(competitionRepositoryProvider).watchCompetitions(clubId: clubId),
);
