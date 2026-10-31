import 'package:flutter/material.dart';
import 'package:seek/core/widgets/placeholder_screen.dart';

class ScoringScreen extends StatelessWidget {
  const ScoringScreen({super.key, required this.meetId});

  final String meetId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Scoring',
      owner: 'Member 5',
      details: 'meetId: $meetId',
    );
  }
}
