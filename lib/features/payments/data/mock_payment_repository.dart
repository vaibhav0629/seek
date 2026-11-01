import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/domain/repositories/payment_repository.dart';

class MockPaymentRepository implements PaymentRepository {
  final MockCollection<Payment> _payments =
      MockCollection<Payment>(mockPayments);

  @override
  Stream<List<Payment>> watchPayments(String meetId) {
    return _payments.watch(
      (payments) => payments.where((p) => p.meetId == meetId).toList(),
    );
  }

  @override
  Future<void> savePayment(Payment payment) async {
    await mockDelay();
    final saved = payment.id.isEmpty
        ? Payment(
            id: mockId('payment'),
            meetId: payment.meetId,
            userId: payment.userId,
            amount: payment.amount,
            currency: payment.currency,
            method: payment.method,
            status: payment.status,
            confirmedBy: payment.confirmedBy,
            note: payment.note,
            paidAt: payment.paidAt,
            createdAt: payment.createdAt ?? DateTime.now(),
          )
        : payment;
    _payments.mutate((items) {
      final index = items.indexWhere((p) => p.id == saved.id);
      if (index == -1) {
        items.add(saved);
      } else {
        items[index] = saved;
      }
    });
  }

  @override
  Future<void> markPaid({
    required String paymentId,
    required String confirmedBy,
    PaymentMethod method = PaymentMethod.cash,
  }) async {
    await mockDelay();
    _payments.mutate((items) {
      final index = items.indexWhere((p) => p.id == paymentId);
      if (index == -1) return;
      items[index] = items[index].copyWith(
        status: PaymentStatus.paid,
        method: method,
        confirmedBy: confirmedBy,
        paidAt: DateTime.now(),
      );
    });
  }
}
