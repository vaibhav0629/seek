import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/meets/data/meet_permissions.dart';
import 'package:seek/features/meets/data/meet_providers.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/scoring/data/match_providers.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/core/config/app_options.dart';
import 'package:seek/features/scoring/domain/score_permission.dart';
import 'package:seek/features/scoring/presentation/widgets/match_score_card.dart';
import 'package:seek/features/scoring/presentation/widgets/score_input_sheet.dart';
import 'package:seek/features/scoring/presentation/widgets/standings_table.dart';
import 'package:seek/features/scoring/presentation/widgets/generate_schedule_button.dart';
import 'package:seek/features/scoring/presentation/widgets/match_history_list.dart';

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
        if (!AppOptions.supportsScoring(meet.sport)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Scoring')),
            body: const Center(
              child: Text('Scoring hanya tersedia untuk basket dan padel.'),
            ),
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
    final rsvpsAsync = ref.watch(rsvpsProvider(meet.id));
    final members = ref.watch(clubMembersProvider(meet.clubId)).value ?? [];
    final userId = ref.watch(currentUserIdProvider);
    final canManage = ref.watch(canManageMeetProvider(meet.id));

    final names = _playerNames(members, rsvpsAsync.value ?? const []);
    final canScore =
        userId != null &&
        canEnterScore(userId: userId, meet: meet, clubMembers: members);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scoring - ${meet.title}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Match'),
              Tab(text: 'Klasemen'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: matchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (matches) {
            if (matches.isEmpty) {
              return _EmptySchedule(
                meet: meet,
                canManage: canManage,
                rsvpsAsync: rsvpsAsync,
              );
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
                MatchHistoryList(matches: matches, playerNames: names),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSheet(
    BuildContext context,
    WidgetRef ref,
    GameMatch m,
    Map<String, String> names,
  ) {
    showScoreInputSheet(
      context: context,
      match: m,
      sport: meet.sport,
      playerNames: names,
      onSubmit: (a, b) => ref
          .read(matchRepositoryProvider)
          .updateScore(matchId: m.id, scoreA: a, scoreB: b),
    );
  }
}

Map<String, String> _playerNames(
  List<ClubMember> members,
  List<Rsvp> rsvps,
) {
  final names = playerNamesFrom(members);
  for (final r in rsvps) {
    names[r.userId] = r.userName;
  }
  return names;
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({
    required this.meet,
    required this.canManage,
    required this.rsvpsAsync,
  });

  final Meet meet;
  final bool canManage;
  final AsyncValue<List<Rsvp>> rsvpsAsync;

  @override
  Widget build(BuildContext context) {
    return rsvpsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error RSVP: $e')),
      data: (rsvps) {
        final going =
            rsvps.where((r) => r.status == RsvpStatus.going).length;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum ada jadwal match.'),
                const SizedBox(height: 8),
                Text(
                  '$going peserta going',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (canManage) ...[
                  const SizedBox(height: 24),
                  GenerateScheduleButton(
                    meetId: meet.id,
                    sport: meet.sport,
                    rsvps: rsvps,
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Hanya pembuat meet atau admin klub yang bisa membuat jadwal.',
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
