
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/features/meets/data/meet_providers.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/app/router/app_routes.dart';

class MeetsListScreen extends ConsumerWidget {
  const MeetsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetsAsync = ref.watch(meetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meets'),
      ),
      body: meetsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Failed to load meets: $error'),
        ),
        data: (meets) {
          if (meets.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy, size: 56),
                  SizedBox(height: 12),
                  Text('No meets available yet.'),
                  SizedBox(height: 4),
                  Text('Create a new meet to get started.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(meetsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meets.length,
              itemBuilder: (context, index) {
                final meet = meets[index];

                return _MeetCard(meet: meet);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MeetCard extends StatelessWidget {
  const _MeetCard({required this.meet});

  final Meet meet;

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(meet.startsAt);

    final time =
        TimeOfDay.fromDateTime(meet.startsAt).format(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.meet(meet.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sports),
                  const SizedBox(width: 8),
                  Text(
                    meet.sport,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  _statusChip(meet.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                meet.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _info(Icons.location_on, meet.venueName),
              _info(Icons.calendar_month, '$date • $time'),
              _info(
                Icons.people,
                '${meet.goingCount}/${meet.maxPlayers} players',
              ),
              _info(
                Icons.payments,
                meet.fee == 0 ? 'Free' : 'Rp ${meet.fee}',
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View details'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _statusChip(MeetStatus status) {
    return Chip(
      label: Text(status.name.toUpperCase()),
      visualDensity: VisualDensity.compact,
    );
  }
}
