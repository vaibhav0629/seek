import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/core/widgets/empty_state.dart';
import 'package:seek/core/widgets/loading_view.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/meets/data/meet_providers.dart';
import 'package:seek/features/payments/data/payment_providers.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';
import 'package:seek/features/payments/presentation/widgets/mark_paid_button.dart';
import 'package:seek/features/payments/presentation/widgets/payment_receipt_sheet.dart';
import 'package:seek/features/payments/presentation/widgets/payment_summary_card.dart';
import 'package:seek/features/payments/presentation/widgets/payment_tile.dart';

/// The organizer's view of who has paid for a meet.
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key, required this.meetId});

  final String meetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(meetPaymentsProvider(meetId));

    // Payments only store user ids, so look names up from the club members
    // (this also covers the organizer who confirmed a payment) and the RSVPs.
    final meet = ref.watch(meetProvider(meetId)).value;
    final members = meet == null
        ? const <ClubMember>[]
        : (ref.watch(clubMembersProvider(meet.clubId)).value ??
            const <ClubMember>[]);
    final rsvps = ref.watch(rsvpsProvider(meetId)).value ?? const [];
    final names = {
      for (final m in members) m.userId: m.userName,
      for (final r in rsvps) r.userId: r.userName,
    };
    final me = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: payments.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.payments_outlined,
              title: 'No payments yet',
              message: 'Payments for this meet will show up here.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PaymentSummaryCard(payments: list),
              const SizedBox(height: 12),
              for (final p in list)
                PaymentTile(
                  payment: p,
                  userName: names[p.userId] ?? 'Player',
                  onTap: () => PaymentReceiptSheet.show(
                    context,
                    payment: p,
                    userName: names[p.userId] ?? 'Player',
                    confirmedByName: names[p.confirmedBy],
                  ),
                  action: me == null
                      ? null
                      : MarkPaidButton(
                          paid: p.status == PaymentStatus.paid,
                          onMarkPaid: () => _markPaid(ref, p, me),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _markPaid(
    WidgetRef ref,
    Payment payment,
    String confirmedBy,
  ) async {
    await ref
        .read(paymentRepositoryProvider)
        .markPaid(paymentId: payment.id, confirmedBy: confirmedBy);
    // Keep the RSVP's "paid" flag in sync, so the RSVP list can show it too.
    await ref
        .read(meetRepositoryProvider)
        .setPaid(meetId: payment.meetId, userId: payment.userId, paid: true);
  }
}
