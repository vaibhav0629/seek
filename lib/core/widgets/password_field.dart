import 'package:flutter/material.dart';
import 'package:seek/core/widgets/custom_text_field.dart';

/// A password input with an eye button to show or hide the text.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      icon: Icons.lock_outline,
      obscureText: _hidden,
      validator: widget.validator,
      suffixIcon: IconButton(
        icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    );
  }
}