import 'package:flutter/material.dart';

/// Temporary screen body. The owner replaces it with the real screen.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.owner,
    this.details,
  });

  final String title;
  final String owner;
  final String? details;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 48),
              const SizedBox(height: 16),
              Text(title, style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Owner: $owner', style: textTheme.bodyMedium),
              if (details != null) ...[
                const SizedBox(height: 8),
                Text(details!, style: textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
