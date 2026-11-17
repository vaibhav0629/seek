import 'package:flutter/material.dart';
import 'package:seek/core/utils/currency_format.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/presentation/widgets/payment_labels.dart';
import 'package:seek/features/payments/presentation/widgets/payment_status_chip.dart';

/// A bottom sheet with the full record of ONE payment: who paid, how much,
/// how, who confirmed it and when.
///
/// Open it with:
///   PaymentReceiptSheet.show(context, payment: p, userName: 'Sari');
class PaymentReceiptSheet extends StatelessWidget {
  const PaymentReceiptSheet({
    super.key,
    required this.payment,
    required this.userName,
    this.confirmedByName,
  });

  final Payment payment;

  /// The payment only stores a user id, so the screen passes the name in.
  final String userName;

  /// Name of the organizer who confirmed the payment, if known.
  final String? confirmedByName;

  static Future<void> show(
    BuildContext context, {
    required Payment payment,
    required String userName,
    String? confirmedByName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => PaymentReceiptSheet(
        payment: payment,
        userName: userName,
        confirmedByName: confirmedByName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmedBy = payment.confirmedBy == null
        ? '-'
        : (confirmedByName ?? 'Organizer');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Payment receipt',
                      style: theme.textTheme.titleLarge),
                ),
                PaymentStatusChip(status: payment.status),
              ],
            ),
            const SizedBox(height: 16),
            _ReceiptRow('Paid by', userName),
            _ReceiptRow('Amount', formatRupiah(payment.amount)),
            _ReceiptRow('Method', payment.method.label),
            _ReceiptRow('Confirmed by', confirmedBy),
            _ReceiptRow(
              'Paid at',
              payment.paidAt == null ? '-' : _formatDateTime(payment.paidAt!),
            ),
            if (payment.note != null && payment.note!.isNotEmpty)
              _ReceiptRow('Note', payment.note!),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = d.hour.toString().padLeft(2, '0');
  final minute = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]} ${d.year}, $hour:$minute';
}
