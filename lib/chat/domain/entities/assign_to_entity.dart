import 'package:chat_app/core/entities/entity.dart';

class AssignToEntity extends BaseEntity {
  final String adminId;
  final String roomId;

  AssignToEntity({required this.adminId, required this.roomId});
  @override
  Map<String, dynamic> toJson() {
    return {
      'assign_to': adminId,
    };
  }
}
