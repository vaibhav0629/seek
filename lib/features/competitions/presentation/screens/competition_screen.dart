import 'package:flutter/material.dart';
import 'package:seek/core/widgets/placeholder_screen.dart';

class CompetitionScreen extends StatelessWidget {
  const CompetitionScreen({super.key, required this.competitionId});

  final String competitionId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Tournament',
      owner: 'Member 5',
      details: 'competitionId: $competitionId',
    );
  }
}
