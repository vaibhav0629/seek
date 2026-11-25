import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/club_permissions.dart';
import 'package:seek/features/competitions/data/competition_permissions.dart';
import 'package:seek/features/competitions/data/competition_providers.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';
import 'package:seek/features/competitions/presentation/widgets/register_competition_button.dart';
import 'package:seek/features/scoring/data/match_providers.dart';
import 'package:seek/features/scoring/domain/bracket.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/domain/score_permission.dart';
import 'package:seek/features/scoring/domain/tournament_completion.dart';
import 'package:seek/features/scoring/presentation/widgets/bracket_view.dart';
import 'package:seek/features/scoring/presentation/widgets/generate_bracket_button.dart';
import 'package:seek/features/scoring/presentation/widgets/generate_competition_round_robin_button.dart';
import 'package:seek/features/scoring/presentation/widgets/match_history_list.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';
import 'package:seek/features/scoring/presentation/widgets/score_input_sheet.dart';
import 'package:seek/features/scoring/presentation/widgets/standings_table.dart';

class CompetitionScreen extends ConsumerWidget {
  const CompetitionScreen({super.key, required this.competitionId});

  final String competitionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compAsync = ref.watch(competitionProvider(competitionId));
    return compAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Tournament')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Tournament')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (comp) {
        if (comp == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tournament')),
            body: const Center(child: Text('Tournament tidak ditemukan.')),
          );
        }
        return _CompetitionBody(competition: comp);
      },
    );
  }
}

class _CompetitionBody extends ConsumerWidget {
  const _CompetitionBody({required this.competition});

  final Competition competition;

  String _statusLabel(CompetitionStatus s) => switch (s) {
        CompetitionStatus.registration => 'Pendaftaran',
        CompetitionStatus.inProgress => 'Berlangsung',
        CompetitionStatus.finished => 'Selesai',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(competitionMatchesProvider(competition.id));
    final members = ref.watch(clubMembersProvider(competition.clubId)).value ?? [];
    final userId = ref.watch(currentUserIdProvider);
    final names = playerNamesFrom(members);
    final canManage = ref.watch(canManageCompetitionProvider(competition.id));
    final canScore = isCreatorOrClubAdmin(
      userId: userId,
      createdBy: competition.createdBy,
      clubMembers: members,
    );

    final championName = competition.championId != null
        ? names[competition.championId!] ?? competition.championId!
        : null;

    return matchesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(competition.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(competition.title)),
        body: Center(child: Text('Error: $e')),
      ),
      data: (matches) {
        final header = _CompetitionHeader(
          competition: competition,
          statusLabel: _statusLabel(competition.status),
          championName: championName,
        );

        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(competition.title)),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                header,
                const SizedBox(height: 16),
                RegisterCompetitionButton(competition: competition),
                if (canManage &&
                    competition.status == CompetitionStatus.registration) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Setelah pemain cukup, buat jadwal atau bagan:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  if (competition.format ==
                      CompetitionFormat.singleElimination)
                    GenerateBracketButton(competition: competition)
                  else
                    GenerateCompetitionRoundRobinButton(
                      competition: competition,
                    ),
                ],
              ],
            ),
          );
        }

        if (competition.format == CompetitionFormat.roundRobin) {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text(competition.title),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Match'),
                    Tab(text: 'Klasemen'),
                    Tab(text: 'Riwayat'),
                  ],
                ),
              ),
              body: Column(
                children: [
                  header,
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          children: [
                            for (final m in matches)
                              MatchScoreCard(
                                match: m,
                                playerNames: names,
                                onTap: canScore
                                    ? () => _openSheet(
                                          context,
                                          ref,
                                          competition,
                                          m,
                                          names,
                                          matches,
                                        )
                                    : null,
                              ),
                          ],
                        ),
                        StandingsTable(matches: matches, playerNames: names),
                        MatchHistoryList(
                          matches: matches,
                          playerNames: names,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(competition.title)),
          body: Column(
            children: [
              header,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RegisterCompetitionButton(competition: competition),
              ),
              Expanded(
                child: BracketView(
                  matches: matches,
                  playerNames: names,
                  onMatchTap: canScore
                      ? (m) => _openSheet(
                            context,
                            ref,
                            competition,
                            m,
                            names,
                            matches,
                          )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSheet(
    BuildContext context,
    WidgetRef ref,
    Competition comp,
    GameMatch m,
    Map<String, String> names,
    List<GameMatch> all,
  ) {
    showScoreInputSheet(
      context: context,
      match: m,
      sport: comp.sport,
      playerNames: names,
      onSubmit: (a, b) async {
        final repo = ref.read(matchRepositoryProvider);
        await repo.updateScore(matchId: m.id, scoreA: a, scoreB: b);
        final finished = m.copyWith(
          scoreA: a,
          scoreB: b,
          status: MatchStatus.finished,
        );
        final advanced = advanceWinner(finished: finished, allMatches: all);
        if (advanced.length > 1) {
          await repo.saveMatches([advanced[1]]);
        }

        final updatedMatches = _matchesAfterScore(all, advanced);
        final compRepo = ref.read(competitionRepositoryProvider);
        final next = comp.format == CompetitionFormat.singleElimination
            ? competitionAfterBracketScore(
                competition: comp,
                matches: updatedMatches,
              )
            : competitionAfterRoundRobinComplete(
                competition: comp,
                matches: updatedMatches,
              );
        if (next != null) {
          await compRepo.updateCompetition(next);
        }
      },
    );
  }

  List<GameMatch> _matchesAfterScore(
    List<GameMatch> all,
    List<GameMatch> advanced,
  ) {
    final map = {for (final m in all) m.id: m};
    for (final m in advanced) {
      map[m.id] = m;
    }
    return map.values.toList()
      ..sort((a, b) {
        final cr = a.round.compareTo(b.round);
        return cr != 0 ? cr : a.position.compareTo(b.position);
      });
  }
}

class _CompetitionHeader extends StatelessWidget {
  const _CompetitionHeader({
    required this.competition,
    required this.statusLabel,
    this.championName,
  });

  final Competition competition;
  final String statusLabel;
  final String? championName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              competition.sport,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Status: $statusLabel · '
              '${competition.playerIds.length}/${competition.maxPlayers} pemain',
            ),
            if (championName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.emoji_events, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Juara: $championName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
