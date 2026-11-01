import 'package:seek/features/payments/domain/entities/payment.dart';

/// Payment records. Firestore path: payments/{paymentId}
///
/// Remember Rsvp.paid mirrors a paid Payment. The Firestore version should
/// update both together (a batch write).
abstract class PaymentRepository {
  Stream<List<Payment>> watchPayments(String meetId);

  /// Creates or replaces a payment. An empty id gets a new one.
  Future<void> savePayment(Payment payment);

  /// Marks a payment as paid, confirmed by an organizer.
  Future<void> markPaid({
    required String paymentId,
    required String confirmedBy,
    PaymentMethod method = PaymentMethod.cash,
  });
}
