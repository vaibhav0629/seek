import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/presentation/screens/club_header.dart';
import 'package:seek/features/clubs/presentation/screens/club_members_list.dart';
import 'package:seek/features/clubs/presentation/screens/join_club_button.dart';

class ClubDetailScreen extends ConsumerWidget {
  final String clubId;

  const ClubDetailScreen({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubProvider(clubId));

    return clubAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Gagal memuat club')),
      ),
      data: (club) {
        if (club == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Club tidak ditemukan')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(club.name)),
          body: Column(
            children: [
              ClubHeader(club: club, action: JoinClubButton(club: club)),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Member',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(child: ClubMembersList(club: club)),
            ],
          ),
        );
      },
    );
  }
}