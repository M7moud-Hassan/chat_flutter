import 'package:chat_app/core/errors/exceptions.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class Calling {
  Future<Either<Failure, T>> call<T>(fun, dynamic input) async {
    try {
      return Right<Failure, T>(input == null ? await fun() : await fun(input));
    } on AppException catch (e) {
      return Left<Failure, T>(
          e.map('OFFLINEEXCEPTION_MESSAGE', 'OFFLINEEXCEPTION_TITLE'));
    }
  }
}
