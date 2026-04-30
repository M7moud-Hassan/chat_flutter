import 'package:chat_app/chat/data/models/attachement.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';

enum MessageStatus {
  pending('PENDING'),
  sent('SENT'),
  delivered('DELIVERED'),
  seen('SEEN');

  const MessageStatus(this.value);
  final String value;

  factory MessageStatus.fromValue(String value) {
    final res = MessageStatus.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid status code';
    }

    return res.first;
  }
}

class Message {
  final int id;
  final String content;
  final Attachment? attachment;
  final DateTime createAt;
  final User? user;
  final Message? replyToMessage;
  final double? ammount;
  final String? payment_url;
  final bool closeChat;

  Message(
      {required this.id,
      required this.content,
      this.attachment,
      required this.createAt,
      this.replyToMessage,
      this.payment_url,
      this.ammount,
      required this.closeChat,
      this.user});

  factory Message.fromMap(Map<String, dynamic> msgData) {
    return Message(
        closeChat: msgData['close_chat'],
        id: msgData['id'],
        ammount: msgData['ammount'] != null
            ? double.parse(msgData['ammount'])
            : null,
        payment_url: msgData['payment_url'],
        content: msgData['content'] ?? '',
        attachment: msgData["attachment"] != null
            ? Attachment.fromMap(msgData["attachment"])
            : null,
        user: msgData['user'] != null ? User.fromMap(msgData['user']) : null,
        replyToMessage:
            msgData['reply'] != null ? Message.fromMap(msgData['reply']) : null,
        createAt: DateTime.parse(msgData['created']));
  }

  Message copyWith({
    int? id,
    String? content,
    Attachment? attachment,
    Message? replyToMessage,
  }) {
    return Message(
        closeChat: closeChat,
        id: id ?? this.id,
        content: content ?? this.content,
        attachment: attachment ?? this.attachment,
        replyToMessage: replyToMessage ?? this.replyToMessage,
        createAt: createAt);
  }

  @override
  String toString() {
    return content;
  }
}

class UserReadMessage {
  final int id;
  final Message message;
  final bool isRead;

  UserReadMessage(
      {required this.id, required this.message, required this.isRead});

  factory UserReadMessage.fromMap(Map<String, dynamic> json) => UserReadMessage(
      id: json['id'],
      message: Message.fromMap(json['message']),
      isRead: json['is_read']);
}
