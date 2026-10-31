import 'package:flutter/material.dart';
import 'package:seek/core/widgets/placeholder_screen.dart';

class ClubDetailScreen extends StatelessWidget {
  const ClubDetailScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Club',
      owner: 'Member 3',
      details: 'clubId: $clubId',
    );
  }
}
