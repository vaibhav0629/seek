import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/club_permissions.dart';
import 'package:seek/features/competitions/data/competition_providers.dart';
import 'package:seek/features/scoring/data/match_providers.dart';
import 'package:seek/features/scoring/domain/bracket.dart';
import 'package:seek/features/scoring/domain/entities/game_match.dart';
import 'package:seek/features/scoring/domain/score_permission.dart';
import 'package:seek/features/scoring/presentation/widgets/bracket_view.dart';
import 'package:seek/features/scoring/presentation/widgets/score_input_sheet.dart';

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
        final matches =
            ref.watch(competitionMatchesProvider(competitionId)).value ?? [];
        final members = ref.watch(clubMembersProvider(comp.clubId)).value ?? [];
        final userId = ref.watch(currentUserIdProvider);
        final names = playerNamesFrom(members);
        final canScore = isCreatorOrClubAdmin(
          userId: userId,
          createdBy: comp.createdBy,
          clubMembers: members,
        );

        return Scaffold(
          appBar: AppBar(title: Text(comp.title)),
          body: BracketView(
            matches: matches,
            playerNames: names,
            onMatchTap: canScore
                ? (m) => _openSheet(context, ref, m, names, matches)
                : null,
          ),
        );
      },
    );
  }

  void _openSheet(
    BuildContext context,
    WidgetRef ref,
    GameMatch m,
    Map<String, String> names,
    List<GameMatch> all,
  ) {
    showScoreInputSheet(
      context: context,
      match: m,
      playerNames: names,
      onSubmit: (a, b) async {
        final repo = ref.read(matchRepositoryProvider);
        await repo.updateScore(matchId: m.id, scoreA: a, scoreB: b);
        final finished = m.copyWith(
          scoreA: a,
          scoreB: b,
          status: MatchStatus.finished,
        );
        final toSave = advanceWinner(finished: finished, allMatches: all);
        // toSave[0] sudah disimpan lewat updateScore; simpan match berikutnya.
        if (toSave.length > 1) await repo.saveMatches([toSave[1]]);
      },
    );
  }
}
