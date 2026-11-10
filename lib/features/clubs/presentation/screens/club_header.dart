import 'package:flutter/material.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/presentation/screens/member_count_badge.dart';
import 'package:seek/features/clubs/presentation/screens/sport_chip.dart';

class ClubHeader extends StatelessWidget {
  final Club club;

  /// Biasanya JoinClubButton.
  final Widget? action;

  const ClubHeader({super.key, required this.club, this.action});

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final style = SportStyle.of(club.sport);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: style.color.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: style.color.withValues(alpha: 0.2),
                child: Icon(style.icon, size: 32, color: style.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SportChip(sport: club.sport),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place_outlined, size: 14),
                            const SizedBox(width: 2),
                            Text(club.city, style: textTheme.bodySmall),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              club.isPrivate ? Icons.lock : Icons.public,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              club.isPrivate ? 'Private' : 'Public',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (club.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(club.description, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              MemberCountBadge(count: club.memberCount),
              if (club.createdAt != null) ...[
                const SizedBox(width: 16),
                Text(
                  'Dibuat ${_date(club.createdAt!)}',
                  style: textTheme.bodySmall,
                ),
              ],
              const Spacer(),
              ?action,
            ],
          ),
        ],
      ),
    );
  }
}