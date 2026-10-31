import 'package:flutter/material.dart';
import 'package:seek/core/widgets/placeholder_screen.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key, required this.meetId});

  final String meetId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Payments',
      owner: 'Member 1 (lead)',
      details: 'meetId: $meetId',
    );
  }
}
