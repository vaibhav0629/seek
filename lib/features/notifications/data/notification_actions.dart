import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/meets/data/meet_providers.dart';
import 'package:seek/features/meets/domain/entities/rsvp.dart';
import 'package:seek/features/notifications/data/notification_providers.dart';
import 'package:seek/features/notifications/domain/notification_messages.dart';
import 'package:seek/features/payments/domain/entities/payment.dart';

// Each function is ONE line to call from a screen. A failed notification never
// breaks the real action (sending a message, confirming a payment, joining...).

/// Call after the organizer confirms a payment.
Future<void> notifyPaymentConfirmed(
  WidgetRef ref,
  Payment payment,
  String confirmedBy,
) async {
  if (payment.userId == confirmedBy) return; // no need to tell yourself
  try {
    final meetTitle = ref.read(meetProvider(payment.meetId)).value?.title;
    final message = NotificationMessages.paymentConfirmed(
      meetTitle: meetTitle,
      amount: payment.amount,
    );
    await ref.read(notificationRepositoryProvider).send(
          toUserId: payment.userId,
          title: message.title,
          body: message.body,
          type: 'payment',
          route: AppRoutes.meet(payment.meetId),
        );
  } catch (e) {
    debugPrint('Could not send the payment notification: $e');
  }
}

/// Call after a chat message was sent: tells every other member of the club.
Future<void> notifyClubMembers(
  WidgetRef ref, {
  required String clubId,
  required String senderId,
  required String senderName,
  required String text,
}) async {
  try {
    final members = ref.read(clubMembersProvider(clubId)).value;
    if (members == null) return;
    final others = members
        .map((member) => member.userId)
        .where((id) => id != senderId)
        .toList();
    if (others.isEmpty) return;

    final clubName = ref.read(clubProvider(clubId)).value?.name ?? 'Club chat';
    await ref.read(notificationRepositoryProvider).sendToMany(
          toUserIds: others,
          title: clubName,
          body: '$senderName: $text',
          type: 'chat',
          route: AppRoutes.clubChat(clubId),
        );
  } catch (e) {
    debugPrint('Could not send the chat notifications: $e');
  }
}

/// Use this instead of meetRepository.joinMeet() on the Join button.
/// Returns the same RsvpStatus. If the meet is full, the user is told that
/// they are on the waiting list, and at which place.
Future<RsvpStatus> joinMeetWithNotifications(
  WidgetRef ref, {
  required String meetId,
  required String userId,
  required String userName,
}) async {
  final meets = ref.read(meetRepositoryProvider);
  final status = await meets.joinMeet(
    meetId: meetId,
    userId: userId,
    userName: userName,
  );

  if (status == RsvpStatus.waitlist) {
    try {
      final rsvps = await meets.watchRsvps(meetId).first;
      final waiting = rsvps.where((r) => r.status == RsvpStatus.waitlist).toList()
        ..sort((a, b) => (a.joinedAt ?? DateTime.now())
            .compareTo(b.joinedAt ?? DateTime.now()));
      final index = waiting.indexWhere((r) => r.userId == userId);
      final position = index < 0 ? waiting.length : index + 1;

      final meetTitle = ref.read(meetProvider(meetId)).value?.title;
      final message = NotificationMessages.waitlistJoined(
        meetTitle: meetTitle,
        position: position,
      );
      await ref.read(notificationRepositoryProvider).send(
            toUserId: userId,
            title: message.title,
            body: message.body,
            type: 'waitlist',
            route: AppRoutes.meet(meetId),
          );
    } catch (e) {
      debugPrint('Could not send the waiting list notification: $e');
    }
  }
  return status;
}

/// Use this instead of meetRepository.leaveMeet() on the Leave button.
/// The repository moves the first waitlisted person up; this tells them.
Future<void> leaveMeetWithNotifications(
  WidgetRef ref, {
  required String meetId,
  required String userId,
}) async {
  final meets = ref.read(meetRepositoryProvider);

  // Who was waiting before, so we can see who moved up.
  final before = await meets.watchRsvps(meetId).first;
  final waitingBefore = before
      .where((r) => r.status == RsvpStatus.waitlist)
      .map((r) => r.userId)
      .toSet();

  await meets.leaveMeet(meetId: meetId, userId: userId);

  try {
    final after = await meets.watchRsvps(meetId).first;
    final promoted = after
        .where((r) => r.status == RsvpStatus.going && waitingBefore.contains(r.userId))
        .map((r) => r.userId)
        .toList();
    if (promoted.isEmpty) return;

    final meetTitle = ref.read(meetProvider(meetId)).value?.title;
    final message = NotificationMessages.spotOpened(meetTitle: meetTitle);
    await ref.read(notificationRepositoryProvider).sendToMany(
          toUserIds: promoted,
          title: message.title,
          body: message.body,
          type: 'waitlist',
          route: AppRoutes.meet(meetId),
        );
  } catch (e) {
    debugPrint('Could not send the spot-opened notification: $e');
  }
}