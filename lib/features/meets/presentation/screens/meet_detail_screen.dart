
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/meets/data/meet_providers.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/profile/data/profile_providers.dart';

class MeetDetailScreen extends ConsumerWidget {
  const MeetDetailScreen({super.key, required this.meetId});

  final String meetId;

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetAsync = ref.watch(meetProvider(meetId));
    final rsvpsAsync = ref.watch(rsvpsProvider(meetId));
    final myRsvpAsync = ref.watch(myRsvpProvider(meetId));

    final userId = ref.watch(currentUserIdProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final userName = currentUserAsync.value?.displayName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meet Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.discover);
            }
          },
        ),
      ),
      body: meetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (meet) {
          if (meet == null) {
            return const Center(child: Text('Meet not found.'));
          }

          final clubAsync = ref.watch(clubProvider(meet.clubId));
          final membersAsync = ref.watch(clubMembersProvider(meet.clubId));

          final club = clubAsync.value;
          final members = membersAsync.value ?? [];

          final isClubAdmin = members.any(
            (member) =>
                member.userId == userId && member.role == ClubRole.admin,
          );

          final canManage =
              userId != null && (meet.createdBy == userId || isClubAdmin);

          return rsvpsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (rsvps) {
              return myRsvpAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (myRsvp) {
                  final repository = ref.read(meetRepositoryProvider);
                  final isJoined =
                      myRsvp != null && myRsvp.status != RsvpStatus.cancelled;

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        meet.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Chip(label: Text(meet.sport)),
                      const SizedBox(height: 12),

                      _infoRow(
                        Icons.groups,
                        'Club',
                        club?.name ?? 'Loading club...',
                      ),
                      _infoRow(Icons.location_on, 'Venue', meet.venueName),
                      _infoRow(
                        Icons.calendar_month,
                        'Date',
                        MaterialLocalizations.of(context)
                            .formatMediumDate(meet.startsAt),
                      ),
                      _infoRow(
                        Icons.access_time,
                        'Time',
                        TimeOfDay.fromDateTime(meet.startsAt).format(context),
                      ),
                      _infoRow(
                        Icons.people,
                        'Capacity',
                        '${meet.goingCount}/${meet.maxPlayers} players',
                      ),
                      _infoRow(
                        Icons.hourglass_bottom,
                        'Waitlist',
                        '${meet.waitlistCount} players',
                      ),
                      _infoRow(
                        Icons.payments,
                        'Fee',
                        meet.fee == 0 ? 'Free' : 'Rp ${meet.fee}',
                      ),

                      if (meet.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'About this meet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(meet.description),
                      ],

                      const SizedBox(height: 24),

                      // Navigation to Scoring and Payments.
                      Text(
                        'Meet Tools',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.push(AppRoutes.meetScoring(meetId));
                              },
                              icon: const Icon(Icons.scoreboard),
                              label: const Text('Scoring'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.push(AppRoutes.meetPayments(meetId));
                              },
                              icon: const Icon(Icons.payments),
                              label: const Text('Payments'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      if (userId != null)
                        if (isJoined)
                          OutlinedButton(
                            onPressed: () => _runAction(
                              context,
                              () => repository.leaveMeet(
                                meetId: meetId,
                                userId: userId,
                              ),
                            ),
                            child: const Text('Leave Meet'),
                          )
                        else
                          FilledButton(
                            onPressed:
                                meet.status == MeetStatus.cancelled ||
                                    meet.status == MeetStatus.finished
                                ? null
                                : () => _runAction(
                                    context,
                                    () => repository.joinMeet(
                                      meetId: meetId,
                                      userId: userId,
                                      userName: userName,
                                    ),
                                  ),
                            child: const Text('Join Meet'),
                          ),

                      if (myRsvp != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your status: ${myRsvp.status.name.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],

                      const SizedBox(height: 28),
                      Text(
                        'Participants (${rsvps.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),

                      if (rsvps.isEmpty)
                        const Text('No participants yet.')
                      else
                        ...rsvps.map(
                          (rsvp) => _participantTile(
                            context,
                            rsvp,
                            canManage: canManage,
                            fee: meet.fee,
                            onPaidChanged: (paid) => _runAction(
                              context,
                              () => repository.setPaid(
                                meetId: meetId,
                                userId: rsvp.userId,
                                paid: paid,
                              ),
                            ),
                            onCheckInChanged: (checkedIn) => _runAction(
                              context,
                              () => repository.setCheckedIn(
                                meetId: meetId,
                                userId: rsvp.userId,
                                checkedIn: checkedIn,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _participantTile(
    BuildContext context,
    Rsvp rsvp, {
    required bool canManage,
    required int fee,
    required ValueChanged<bool> onPaidChanged,
    required ValueChanged<bool> onCheckInChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rsvp.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(rsvp.status.name.toUpperCase()),
                    ],
                  ),
                ),
              ],
            ),
            if (canManage && rsvp.status == RsvpStatus.going) ...[
              const Divider(height: 20),
              if (fee > 0)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Payment received'),
                  value: rsvp.paid,
                  onChanged: onPaidChanged,
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Checked in'),
                value: rsvp.checkedIn,
                onChanged: onCheckInChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
