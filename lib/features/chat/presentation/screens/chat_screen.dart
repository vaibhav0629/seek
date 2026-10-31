import 'package:flutter/material.dart';
import 'package:seek/core/widgets/placeholder_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Club chat',
      owner: 'Member 2',
      details: 'clubId: $clubId',
    );
  }
}
