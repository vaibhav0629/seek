import 'package:flutter/material.dart';

/// One row of profile info: an icon, a small label and the value under it.
/// Pass a [child] instead of [value] for custom content (like sport chips).
class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? child;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    this.value = '',
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodySmall),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: child ??
              Text(
                value.isEmpty ? '-' : value,
                style: theme.textTheme.bodyLarge,
              ),
        ),
      ),
    );
  }
}