import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/domain/repositories/payment_repository.dart';

class FirestorePaymentRepository implements PaymentRepository {
  FirestorePaymentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  late final _payments = _db.collection('payments');

  @override
  Stream<List<Payment>> watchPayments(String meetId) {
    return _payments
        .where('meetId', isEqualTo: meetId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> savePayment(Payment payment) async {
    final docRef =
        payment.id.isEmpty ? _payments.doc() : _payments.doc(payment.id);
    final data = payment.toMap();
    if (payment.createdAt == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await docRef.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> markPaid({
    required String paymentId,
    required String confirmedBy,
    PaymentMethod method = PaymentMethod.cash,
  }) async {
    await _payments.doc(paymentId).update({
      'status': PaymentStatus.paid.name,
      'method': method.name,
      'confirmedBy': confirmedBy,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }
}