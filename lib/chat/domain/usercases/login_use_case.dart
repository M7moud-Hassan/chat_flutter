import 'package:chat_app/chat/domain/usercases/base_use_case.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class LoginUSeCase extends BaseUseCase {
  LoginUSeCase({required super.chatRepo});
  Future<Either<Failure, void>> call() => chatRepo.login();
}
