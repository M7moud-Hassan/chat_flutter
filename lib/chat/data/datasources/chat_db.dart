import 'package:chat_app/chat/data/models/attachement.model.dart';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/domain/entities/assign_to_entity.dart';
import 'package:chat_app/chat/domain/entities/categories.dart';
import 'package:chat_app/chat/domain/entities/messgae_pagination.dart';
import 'package:chat_app/chat/domain/entities/update_fcm.dart';
import 'package:chat_app/core/entities/entity.dart';

abstract class ChatDB {
  Future<User> login();
  Future<RecentChat> createChat(BaseEntity entity);
  Future<PageinationModel<RecentChat>> getRooms(bool me);
  Future<PageinationModel<UserReadMessage>> getMessage(MessgaePagination room);
  Future<Attachment> sendAttachment(BaseEntity entity);
  Future<List<User>> getAdmins();
  Future<void> assignChat(AssignToEntity entity);
  Future<void> updateUserInfo(UpdateFcm entity);
  Future<List<CategoryModel>> categories();
}
