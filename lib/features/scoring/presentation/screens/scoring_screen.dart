import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/meets/data/meet_providers.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/scoring/data/match_providers.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/domain/score_permission.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';
import 'package:seek/features/scoring/presentation/widgets/score_input_sheet.dart';
import 'package:seek/features/scoring/presentation/widgets/standings_table.dart';

class ScoringScreen extends ConsumerWidget {
  const ScoringScreen({super.key, required this.meetId});

  final String meetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetAsync = ref.watch(meetProvider(meetId));
    return meetAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Scoring')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Scoring')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (meet) {
        if (meet == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Scoring')),
            body: const Center(child: Text('Meet tidak ditemukan.')),
          );
        }
        return _ScoringBody(meet: meet);
      },
    );
  }
}

class _ScoringBody extends ConsumerWidget {
  const _ScoringBody({required this.meet});

  final Meet meet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(meetMatchesProvider(meet.id));
    final members = ref.watch(clubMembersProvider(meet.clubId)).value ?? [];
    final userId = ref.watch(currentUserIdProvider);

    final names = playerNamesFrom(members);
    final canScore = userId != null &&
        canEnterScore(userId: userId, meet: meet, clubMembers: members);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scoring - ${meet.title}'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Match'), Tab(text: 'Klasemen')],
          ),
        ),
        body: matchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (matches) {
            if (matches.isEmpty) {
              return const Center(child: Text('Belum ada jadwal match.'));
            }
            return TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final m in matches)
                      MatchScoreCard(
                        match: m,
                        playerNames: names,
                        onTap: canScore
                            ? () => _openSheet(context, ref, m, names)
                            : null,
                      ),
                  ],
                ),
                StandingsTable(matches: matches, playerNames: names),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref, GameMatch m,
      Map<String, String> names) {
    showScoreInputSheet(
      context: context,
      match: m,
      playerNames: names,
      onSubmit: (a, b) => ref
          .read(matchRepositoryProvider)
          .updateScore(matchId: m.id, scoreA: a, scoreB: b),
    );
  }
}