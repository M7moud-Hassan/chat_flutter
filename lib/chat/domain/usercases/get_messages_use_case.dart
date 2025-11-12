import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/domain/entities/messgae_pagination.dart';
import 'package:chat_app/chat/domain/usercases/base_use_case.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class GetMessagesUseCase extends BaseUseCase {
  GetMessagesUseCase({required super.chatRepo});
  Future<Either<Failure, PageinationModel<UserReadMessage>>> call(
          MessgaePagination room) =>
      chatRepo.getMessages(room);
}
