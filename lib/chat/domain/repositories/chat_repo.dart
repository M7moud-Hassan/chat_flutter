import 'package:chat_app/chat/data/models/attachement.model.dart';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/domain/entities/categories.dart';
import 'package:chat_app/chat/domain/entities/messgae_pagination.dart';
import 'package:chat_app/core/entities/entity.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepo {
  Future<Either<Failure, User>> login(BaseEntity username);
  Future<Either<Failure, RecentChat>> createRoom(BaseEntity entity);
  Future<Either<Failure, PageinationModel<RecentChat>>> getRooms(bool me);
  Future<Either<Failure, Attachment>> createAttachment(BaseEntity entity);
  Future<Either<Failure, PageinationModel<UserReadMessage>>> getMessages(
      MessgaePagination room);
  Future<Either<Failure, List<User>>> getAdmins();
  Future<Either<Failure, void>> updateInfo(BaseEntity entity);
  Future<Either<Failure, List<CategoryModel>>> categories();
}
