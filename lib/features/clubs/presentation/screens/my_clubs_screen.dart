import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/presentation/screens/club_card.dart';
import 'package:seek/features/clubs/presentation/screens/club_empty_state.dart';

class MyClubsScreen extends ConsumerWidget {
  const MyClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(myClubsProvider);
    final hasClubs = clubsAsync.asData?.value.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('My Clubs')),
// FAB hanya muncul kalau sudah punya club
      floatingActionButton: hasClubs
          ? FloatingActionButton.extended(
        onPressed: () => context.push('/clubs/create'), // sesuaikan route
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
              onAction: () => context.push('/clubs/create'), // sesuaikan route
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: clubs.length,
            itemBuilder: (context, i) =>
                ClubCard(
                  club: clubs[i],
                  onTap: () =>
                      context.push('/clubs/${clubs[i].id}'), // sesuaikan route
                ),
          );
        },
      ),
    );
  }
}