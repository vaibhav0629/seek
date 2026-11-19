import 'package:flutter/material.dart';
import 'package:seek/features/profile/domain/entities/app_user.dart';

/// Avatar, name and email at the top of the profile screen.
class ProfileHeader extends StatelessWidget {
  final AppUser user;

  const ProfileHeader({super.key, required this.user});

  String get _initial {
    final name = user.displayName.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: colors.primary,
          foregroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
          child: Text(
            _initial,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName.isEmpty ? 'Player' : user.displayName,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(user.email, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}