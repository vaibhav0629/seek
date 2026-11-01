import 'package:seek/features/competitions/domain/entities/competition.dart';

/// Tournaments. Firestore path: competitions/{competitionId}
abstract class CompetitionRepository {
  Stream<List<Competition>> watchCompetitions({String? clubId});

  Stream<Competition?> watchCompetition(String competitionId);

  /// Pass a competition with an empty id and the repository assigns one.
  Future<String> createCompetition(Competition competition);

  /// Adds the player while registration is open and there is room.
  Future<void> registerPlayer({
    required String competitionId,
    required String userId,
  });

  /// Replaces the stored competition (status, seeds, champion...).
  Future<void> updateCompetition(Competition competition);
}
