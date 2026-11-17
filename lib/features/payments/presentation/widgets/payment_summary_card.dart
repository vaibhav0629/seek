import 'package:flutter/material.dart';
import 'package:seek/core/utils/currency_format.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';

/// The overview at the top of the payments screen: how much money has been
/// collected so far, out of the total, with a progress bar.
///
/// It looks at the whole list of payments for a meet, and only counts
/// payments whose status is paid.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.payments});

  final List<Payment> payments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paid =
        payments.where((p) => p.status == PaymentStatus.paid).toList();
    final total = payments.fold<int>(0, (sum, p) => sum + p.amount);
    final collected = paid.fold<int>(0, (sum, p) => sum + p.amount);
    final progress = total == 0 ? 0.0 : collected / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collected',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '${formatRupiah(collected)} of ${formatRupiah(total)}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${paid.length} of ${payments.length} paid',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
