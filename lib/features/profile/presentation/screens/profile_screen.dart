import 'package:flutter/material.dart';
import 'package:seek/core/widgets/placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Profile', owner: 'Member 2');
  }
}
