import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/competitions/domain/repositories/competition_repository.dart';

class MockCompetitionRepository implements CompetitionRepository {
  final MockCollection<Competition> _competitions =
      MockCollection<Competition>(mockCompetitions);

  @override
  Stream<List<Competition>> watchCompetitions({String? clubId}) {
    return _competitions.watch(
      (items) => items.where((c) => clubId == null || c.clubId == clubId).toList(),
    );
  }

  @override
  Stream<Competition?> watchCompetition(String competitionId) {
    return _competitions.watch(
      (items) => items.where((c) => c.id == competitionId).firstOrNull,
    );
  }

  @override
  Future<String> createCompetition(Competition competition) async {
    await mockDelay();
    final id = competition.id.isEmpty ? mockId('competition') : competition.id;
    _competitions.mutate(
      (items) => items.add(
        Competition(
          id: id,
          clubId: competition.clubId,
          title: competition.title,
          sport: competition.sport,
          createdBy: competition.createdBy,
          format: competition.format,
          status: competition.status,
          playerIds: competition.playerIds,
          seeds: competition.seeds,
          maxPlayers: competition.maxPlayers,
          startsAt: competition.startsAt,
          championId: competition.championId,
          createdAt: competition.createdAt ?? DateTime.now(),
        ),
      ),
    );
    return id;
  }

  @override
  Future<void> registerPlayer({
    required String competitionId,
    required String userId,
  }) async {
    await mockDelay();
    _competitions.mutate((items) {
      final index = items.indexWhere((c) => c.id == competitionId);
      if (index == -1) return;
      final c = items[index];
      final canRegister = c.status == CompetitionStatus.registration &&
          !c.playerIds.contains(userId) &&
          c.playerIds.length < c.maxPlayers;
      if (!canRegister) return;
      items[index] = c.copyWith(playerIds: [...c.playerIds, userId]);
    });
  }

  @override
  Future<void> updateCompetition(Competition competition) async {
    await mockDelay();
    _competitions.mutate((items) {
      final index = items.indexWhere((c) => c.id == competition.id);
      if (index == -1) return;
      items[index] = competition;
    });
  }
}
