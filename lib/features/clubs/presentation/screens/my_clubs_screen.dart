import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/presentation/screens/club_card.dart';
import 'package:seek/features/clubs/presentation/screens/club_empty_state.dart';
import 'package:seek/features/clubs/presentation/screens/nearby_clubs_screen.dart';

class MyClubsScreen extends ConsumerWidget {
  const MyClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(myClubsProvider);
    final hasClubs = clubsAsync.asData?.value.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Clubs'),
        actions: [
          TextButton.icon(
<<<<<<< HEAD
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NearbyClubsScreen(),
              ),
            ),
=======
            onPressed: () => context.push(AppRoutes.nearbyClubs),
>>>>>>> main
            icon: const Icon(Icons.near_me_outlined),
            label: const Text('Near Me'),
          ),
        ],
      ),
      // FAB hanya muncul kalau sudah punya club
      floatingActionButton: hasClubs
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.newClub),
              icon: const Icon(Icons.add),
              label: const Text('Buat Club'),
            )
          : null,
      body: clubsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Gagal memuat club')),
        data: (clubs) {
          if (clubs.isEmpty) {
            return ClubEmptyState(
              message: 'Kamu belum gabung club apa pun',
              actionLabel: 'Buat Club',
              onAction: () => context.push(AppRoutes.newClub),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: clubs.length,
            itemBuilder: (context, i) => ClubCard(
              club: clubs[i],
              onTap: () => context.push(AppRoutes.club(clubs[i].id)),
            ),
          );
        },
      ),
    );
  }
}
