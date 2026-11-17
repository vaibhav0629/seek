import 'package:flutter/material.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';

/// Display text and icons for a payment method, so every widget shows
/// "Bank transfer" the same way.
extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.bankTransfer => 'Bank transfer',
        PaymentMethod.eWallet => 'E-wallet',
        PaymentMethod.other => 'Other',
      };

  IconData get icon => switch (this) {
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.bankTransfer => Icons.account_balance_outlined,
        PaymentMethod.eWallet => Icons.account_balance_wallet_outlined,
        PaymentMethod.other => Icons.more_horiz,
      };
}
