import 'package:seek/core/utils/currency_format.dart';

/// The texts of the notifications, in one place.
class NotificationMessages {
  NotificationMessages._();

  static ({String title, String body}) waitlistJoined({
    required String? meetTitle,
    required int position,
  }) =>
      (
        title: 'You are on the waiting list',
        body: '${meetTitle ?? 'The meet'} is full. You are #$position on the '
            'waiting list. We will tell you if a spot opens up.',
      );

  static ({String title, String body}) spotOpened({
    required String? meetTitle,
  }) =>
      (
        title: 'A spot opened up!',
        body: 'You are now going to ${meetTitle ?? 'the meet'}.',
      );

  static ({String title, String body}) paymentConfirmed({
    required String? meetTitle,
    required int amount,
  }) =>
      (
        title: 'Payment confirmed',
        body: 'The organizer confirmed your payment of ${formatRupiah(amount)} '
            'for ${meetTitle ?? 'the meet'}.',
      );
}