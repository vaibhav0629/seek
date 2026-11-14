import 'package:flutter/material.dart';
import 'package:seek/core/utils/currency_format.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/presentation/widgets/payment_labels.dart';
import 'package:seek/features/payments/presentation/widgets/payment_status_chip.dart';

/// One row in the organizer's payment list: who paid, how much, how, and
/// the status. Pass [action] (for example a MarkPaidButton) to show a button,
/// and [onTap] to make the whole row tappable (for example to open a receipt).
class PaymentTile extends StatelessWidget {
  const PaymentTile({
    super.key,
    required this.payment,
    required this.userName,
    this.action,
    this.onTap,
  });

  final Payment payment;

  /// The payment only stores a user id, so the screen passes the name in.
  final String userName;

  final Widget? action;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initial = userName.isEmpty ? '?' : userName[0].toUpperCase();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(child: Text(initial)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${formatRupiah(payment.amount)} - ${payment.method.label}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PaymentStatusChip(status: payment.status),
                  if (action != null) ...[
                    const SizedBox(height: 8),
                    action!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
