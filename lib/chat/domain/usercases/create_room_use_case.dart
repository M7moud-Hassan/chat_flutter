import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/domain/usercases/base_use_case.dart';
import 'package:chat_app/core/entities/entity.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class CreateRoomUseCase extends BaseUseCase {
  CreateRoomUseCase({required super.chatRepo});
  Future<Either<Failure, RecentChat>> call(BaseEntity entity) =>
      chatRepo.createRoom(entity);
}
