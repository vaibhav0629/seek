import 'package:flutter/material.dart';

/// Widget 5: "Don't have an account? Register" style link.
class AuthSwitchText extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onTap;

  const AuthSwitchText({
    super.key,
    required this.question,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question),
        TextButton(onPressed: onTap, child: Text(actionText)),
      ],
    );
  }
}