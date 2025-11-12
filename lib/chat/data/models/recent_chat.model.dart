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

  RecentChat(
      {required this.id,
      required this.users,
      this.numMessagesNotSeen = 0,
      required this.image,
      required this.name,
      required this.lastMessage});

  factory RecentChat.fromMap(Map<String, dynamic> chatData) {
    return RecentChat(
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
