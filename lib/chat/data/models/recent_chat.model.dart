import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/core/utils/app_utils.dart';

class RecentChat {
  final String id;
  final List<User>? users;
  UserReadMessage? lastMessage;
  final String name;
  final String? image;
  int numMessagesNotSeen;
  final int? categoryId;
  final String? link_payment, payment_status;
  final bool? req_payment;

  RecentChat(
      {required this.id,
      required this.users,
      this.numMessagesNotSeen = 0,
      required this.image,
      required this.name,
      required this.categoryId,
      required this.lastMessage,
      required this.req_payment,
      this.link_payment,
      this.payment_status});

  factory RecentChat.fromMap(Map<String, dynamic> chatData) {
    return RecentChat(
      req_payment: chatData['req_payment'],
      link_payment: chatData['link_payment'],
      payment_status: chatData['payment_status'],
      id: chatData['id'],
      image: chatData['image'],
      name: chatData['name'] ?? '',
      lastMessage: chatData['last_message'] != null
          ? UserReadMessage.fromMap(chatData['last_message'])
          : null,
      users: chatData['users'] == null
          ? null
          : AppUtils.generateList(chatData['users'], User.fromMap),
      numMessagesNotSeen: chatData['num_messages_not_seen'],
      categoryId: chatData['category'],
    );
  }

  @override
  String toString() {
    return 'Recent Chat => ${lastMessage?.message.content}';
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'message': message.toMap(),
  //     'user': user.toMap(),
  //     'unreadCount': unreadCount,
  //   };
  // }
}
