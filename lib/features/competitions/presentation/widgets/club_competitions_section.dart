import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/features/competitions/data/competition_providers.dart';
import 'package:seek/features/competitions/domain/entities/competition.dart';

class ClubCompetitionsSection extends ConsumerWidget {
  const ClubCompetitionsSection({super.key, required this.clubId});

  final String clubId;

  String _statusLabel(CompetitionStatus s) => switch (s) {
        CompetitionStatus.registration => 'Pendaftaran',
        CompetitionStatus.inProgress => 'Berlangsung',
        CompetitionStatus.finished => 'Selesai',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clubCompetitionsProvider(clubId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Gagal memuat turnamen: $e'),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Belum ada turnamen di club ini.'),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Turnamen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                return ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: Text(c.title),
                  subtitle: Text(
                    '${c.sport} · ${_statusLabel(c.status)} · '
                    '${c.playerIds.length}/${c.maxPlayers} pemain',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(AppRoutes.competition(c.id)),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
