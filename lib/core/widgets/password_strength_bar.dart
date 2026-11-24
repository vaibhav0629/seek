import 'package:flutter/material.dart';
import 'package:seek/core/utils/validators.dart';

/// A bar under the password field that shows Weak / Medium / Strong while typing.
/// It listens to the controller itself, so the screen needs no setState.
class PasswordStrengthBar extends StatelessWidget {
  final TextEditingController controller;

  const PasswordStrengthBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) return const SizedBox.shrink();

        final score = Validators.passwordStrength(value.text);
        final colors = Theme.of(context).colorScheme;
        final Color color;
        final String label;
        if (score <= 1) {
          color = colors.error;
          label = 'Weak';
        } else if (score < 4) {
          color = Colors.orange;
          label = 'Medium';
        } else {
          color = Colors.green;
          label = 'Strong';
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 4,
                    minHeight: 6,
                    color: color,
                    backgroundColor: colors.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}