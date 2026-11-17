import 'package:flutter/material.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';

/// A small coloured label for a payment: Pending, Paid or Refunded.
/// Colours come from the app theme, so they follow the team's theme later.
class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      PaymentStatus.paid => (
          'Paid',
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      PaymentStatus.pending => (
          'Pending',
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      PaymentStatus.refunded => (
          'Refunded',
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
    };
    return Chip(
      label: Text(label, style: TextStyle(color: foreground)),
      backgroundColor: background,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
