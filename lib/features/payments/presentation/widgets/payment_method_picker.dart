import 'package:flutter/material.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/presentation/widgets/payment_labels.dart';

/// A row of choices for how a payment was made: Cash, Bank transfer,
/// E-wallet or Other. The chips wrap onto a second line on narrow screens.
///
/// To ask the organizer inside a bottom sheet, use [pick]. It returns the
/// chosen method, or null if they dismiss the sheet.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  static Future<PaymentMethod?> pick(
    BuildContext context, {
    PaymentMethod initial = PaymentMethod.cash,
  }) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      showDragHandle: true,
      builder: (_) => _PickerSheet(initial: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final method in PaymentMethod.values)
          ChoiceChip(
            avatar: Icon(method.icon, size: 18),
            label: Text(method.label),
            selected: method == selected,
            onSelected: (_) => onChanged(method),
          ),
      ],
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({required this.initial});

  final PaymentMethod initial;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late PaymentMethod _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was it paid?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            PaymentMethodPicker(
              selected: _selected,
              onChanged: (method) => setState(() => _selected = method),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                child: const Text('Confirm payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
