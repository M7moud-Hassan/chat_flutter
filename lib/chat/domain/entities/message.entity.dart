import 'package:chat_app/core/entities/entity.dart';

class MessageEntity extends BaseEntity {
  final String message;
  final int? attachment;

  MessageEntity({required this.message, required this.attachment});
  @override
  Map<String, dynamic> toJson() =>
      {'message': message, if (attachment != null) "attachment": attachment};
}
