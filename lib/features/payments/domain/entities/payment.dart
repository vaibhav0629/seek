import 'package:seek/core/utils/firestore_parsing.dart';

enum PaymentMethod { cash, bankTransfer, eWallet, other }

enum PaymentStatus { pending, paid, refunded }

class Payment {
  final String id;
  final String meetId;
  final String userId;
  final int amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? confirmedBy;
  final String? note;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const Payment({
    required this.id,
    required this.meetId,
    required this.userId,
    required this.amount,
    this.currency = 'IDR',
    this.method = PaymentMethod.cash,
    this.status = PaymentStatus.pending,
    this.confirmedBy,
    this.note,
    this.paidAt,
    this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map, String id) => Payment(
        id: id,
        meetId: map['meetId'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        amount: (map['amount'] as num?)?.toInt() ?? 0,
        currency: map['currency'] as String? ?? 'IDR',
        method:
            enumFromName(PaymentMethod.values, map['method'], PaymentMethod.cash),
        status: enumFromName(
            PaymentStatus.values, map['status'], PaymentStatus.pending),
        confirmedBy: map['confirmedBy'] as String?,
        note: map['note'] as String?,
        paidAt: dateFromFirestore(map['paidAt']),
        createdAt: dateFromFirestore(map['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'meetId': meetId,
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'method': method.name,
        'status': status.name,
        'confirmedBy': confirmedBy,
        'note': note,
        'paidAt': dateToFirestore(paidAt),
        'createdAt': dateToFirestore(createdAt),
      };

  Payment copyWith({
    PaymentMethod? method,
    PaymentStatus? status,
    String? confirmedBy,
    String? note,
    DateTime? paidAt,
  }) =>
      Payment(
        id: id,
        meetId: meetId,
        userId: userId,
        amount: amount,
        currency: currency,
        method: method ?? this.method,
        status: status ?? this.status,
        confirmedBy: confirmedBy ?? this.confirmedBy,
        note: note ?? this.note,
        paidAt: paidAt ?? this.paidAt,
        createdAt: createdAt,
      );
}
