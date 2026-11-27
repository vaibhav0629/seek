import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/payments/data/firestore_payment_repository.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => FirestorePaymentRepository(),
);

final meetPaymentsProvider = StreamProvider.family<List<Payment>, String>(
  (ref, meetId) => ref.watch(paymentRepositoryProvider).watchPayments(meetId),
);