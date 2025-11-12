import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/domain/usercases/base_use_case.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class GetRoomsUseCase extends BaseUseCase {
  GetRoomsUseCase({required super.chatRepo});
  Future<Either<Failure, PageinationModel<RecentChat>>> call(bool me) =>
      chatRepo.getRooms(me);
}
