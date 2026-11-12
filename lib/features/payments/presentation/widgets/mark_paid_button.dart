import 'package:flutter/material.dart';

/// The organizer's "Mark as paid" button.
///
/// While the action runs it shows a small spinner and ignores extra taps.
/// Once [paid] is true it turns into a disabled "Paid" button.
class MarkPaidButton extends StatefulWidget {
  const MarkPaidButton({
    super.key,
    required this.paid,
    required this.onMarkPaid,
  });

  final bool paid;

  /// What to do when pressed. The button waits for it to finish.
  final Future<void> Function() onMarkPaid;

  @override
  State<MarkPaidButton> createState() => _MarkPaidButtonState();
}

class _MarkPaidButtonState extends State<MarkPaidButton> {
  bool _busy = false;

  Future<void> _handlePressed() async {
    setState(() => _busy = true);
    try {
      await widget.onMarkPaid();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paid) {
      return FilledButton.tonalIcon(
        onPressed: null,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('Paid'),
      );
    }
    return FilledButton(
      onPressed: _busy ? null : _handlePressed,
      child: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Mark as paid'),
    );
  }
}
