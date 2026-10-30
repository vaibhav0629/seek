import 'package:seek/core/utils/firestore_parsing.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime? sentAt;
  final bool isSystem;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.sentAt,
    this.isSystem = false,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) => Message(
        id: id,
        chatId: map['chatId'] as String? ?? '',
        senderId: map['senderId'] as String? ?? '',
        senderName: map['senderName'] as String? ?? '',
        text: map['text'] as String? ?? '',
        sentAt: dateFromFirestore(map['sentAt']),
        isSystem: map['isSystem'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'sentAt': dateToFirestore(sentAt),
        'isSystem': isSystem,
      };
}
