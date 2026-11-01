import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/payments/data/mock_payment_repository.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/domain/repositories/payment_repository.dart';

/// To switch to Firebase, return FirestorePaymentRepository() here instead.
final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => MockPaymentRepository(),
);

/// Payment records of one meet.
final meetPaymentsProvider = StreamProvider.family<List<Payment>, String>(
  (ref, meetId) => ref.watch(paymentRepositoryProvider).watchPayments(meetId),
);
