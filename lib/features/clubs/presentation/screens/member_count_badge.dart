import 'package:flutter/material.dart';

class MemberCountBadge extends StatelessWidget {
  final int count;
  const MemberCountBadge({super.key, required this.count});

  String _format(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.people_outline, size: 16, color: color),
        const SizedBox(width: 4),
        Text(_format(count), style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}