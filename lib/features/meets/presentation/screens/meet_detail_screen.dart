import 'package:flutter/material.dart';
import 'package:seek/core/widgets/placeholder_screen.dart';

class MeetDetailScreen extends StatelessWidget {
  const MeetDetailScreen({super.key, required this.meetId});

  final String meetId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Meet',
      owner: 'Member 4',
      details: 'meetId: $meetId',
    );
  }
}
