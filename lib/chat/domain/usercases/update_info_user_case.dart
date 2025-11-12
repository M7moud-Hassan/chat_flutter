import 'package:chat_app/chat/domain/usercases/base_use_case.dart';
import 'package:chat_app/core/entities/entity.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class UpdateInfoUserCase extends BaseUseCase {
  UpdateInfoUserCase({required super.chatRepo});
  Future<Either<Failure, void>> call(BaseEntity entity) =>
      chatRepo.updateInfo(entity);
}
