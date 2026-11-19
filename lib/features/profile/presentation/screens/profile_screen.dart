import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/core/widgets/empty_state.dart';
import 'package:seek/core/widgets/loading_view.dart';
import 'package:seek/core/widgets/primary_button.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/profile/data/profile_providers.dart';
import 'package:seek/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:seek/features/profile/presentation/widgets/profile_header.dart';
import 'package:seek/features/profile/presentation/widgets/profile_info_tile.dart';

/// The signed-in user's profile: info, edit button and log out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load your profile',
          message: 'Check your connection and try again.',
        ),
        data: (user) {
          if (user == null) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Profile not found',
              message: 'Your account has no profile yet. Try logging in again.',
              action: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeader(user: user),
              const SizedBox(height: 24),
              ProfileInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone,
              ),
              ProfileInfoTile(
                icon: Icons.location_city_outlined,
                label: 'City',
                value: user.city,
              ),
              ProfileInfoTile(
                icon: Icons.bar_chart,
                label: 'Skill level',
                value: user.skillLevel,
              ),
              ProfileInfoTile(
                icon: Icons.sports_tennis,
                label: 'Sports',
                child: user.sports.isEmpty
                    ? const Text('-')
                    : Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: user.sports
                            .map((sport) => Chip(label: Text(sport)))
                            .toList(),
                      ),
              ),
              if (user.rating != null)
                ProfileInfoTile(
                  icon: Icons.star_outline,
                  label: 'Rating',
                  value: user.rating!.toStringAsFixed(1),
                ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Edit profile',
                onPressed: () => showEditProfileSheet(context, user),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}