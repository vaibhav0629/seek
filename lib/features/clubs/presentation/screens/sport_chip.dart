import 'package:flutter/material.dart';

class SportStyle {
  final IconData icon;
  final Color color;
  const SportStyle(this.icon, this.color);

  static SportStyle of(String sport) {
    switch (sport.toLowerCase()) {
      case 'futsal':
      case 'sepak bola':
      case 'football':
        return const SportStyle(Icons.sports_soccer, Colors.green);
      case 'badminton':
        return const SportStyle(Icons.sports_tennis, Colors.orange);
      case 'basket':
      case 'basketball':
        return const SportStyle(Icons.sports_basketball, Colors.deepOrange);
      case 'lari':
      case 'running':
        return const SportStyle(Icons.directions_run, Colors.blue);
      case 'voli':
      case 'volleyball':
        return const SportStyle(Icons.sports_volleyball, Colors.purple);
      default:
        return const SportStyle(Icons.sports, Colors.blueGrey);
    }
  }
}

class SportChip extends StatelessWidget {
  final String sport;
  const SportChip({super.key, required this.sport});

  @override
  Widget build(BuildContext context) {
    final style = SportStyle.of(sport);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.color),
          const SizedBox(width: 4),
          Text(
            sport.isEmpty ? 'Olahraga' : sport,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: style.color,
            ),
          ),
        ],
      ),
    );
  }
}