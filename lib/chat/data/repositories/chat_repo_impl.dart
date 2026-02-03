import 'package:chat_app/chat/data/datasources/chat_db.dart';
import 'package:chat_app/chat/data/models/attachement.model.dart';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/domain/entities/categories.dart';
import 'package:chat_app/chat/domain/entities/messgae_pagination.dart';
import 'package:chat_app/chat/domain/repositories/chat_repo.dart';
import 'package:chat_app/core/entities/entity.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:chat_app/core/utils/calling.dart';
import 'package:dartz/dartz.dart';

class ChatRepoImpl implements ChatRepo {
  final ChatDB chatdb;
  final Calling calling;

  ChatRepoImpl({required this.chatdb, required this.calling});

  @override
  Future<Either<Failure, User>> login(BaseEntity username) =>
      calling(chatdb.login, username);

  @override
  Future<Either<Failure, RecentChat>> createRoom(BaseEntity entity) =>
      calling(chatdb.createChat, entity);
  @override
  Future<Either<Failure, PageinationModel<RecentChat>>> getRooms(bool me) =>
      calling(chatdb.getRooms, me);

  @override
  Future<Either<Failure, PageinationModel<UserReadMessage>>> getMessages(
          MessgaePagination room) =>
      calling(chatdb.getMessage, room);

  @override
  Future<Either<Failure, Attachment>> createAttachment(BaseEntity entity) =>
      calling(chatdb.sendAttachment, entity);

  @override
  Future<Either<Failure, List<User>>> getAdmins() =>
      calling(chatdb.getAdmins, null);
  @override
  Future<Either<Failure, void>> updateInfo(BaseEntity entity) =>
      calling(chatdb.updateUserInfo, entity);

  @override
  Future<Either<Failure, List<CategoryModel>>> categories() =>
      calling(chatdb.categories, null);
}
