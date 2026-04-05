import 'package:chat_app/core/entities/entity.dart';

class MessageEntity extends BaseEntity {
  final String message;
  final int? attachment;
  final int? replay_id;

  MessageEntity(
      {required this.message, required this.attachment, this.replay_id});
  @override
  Map<String, dynamic> toJson() => {
        'message': message,
        if (attachment != null) "attachment": attachment,
        if (replay_id != null) "replay_id": replay_id
      };
}
