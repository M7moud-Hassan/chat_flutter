import 'package:chat_app/chat/domain/entities/categories.dart';
import 'package:chat_app/chat/domain/usercases/base_use_case.dart';
import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';

class GetCategoriesUseCase extends BaseUseCase {
  GetCategoriesUseCase({required super.chatRepo});
  Future<Either<Failure, List<CategoryModel>>> call() => chatRepo.categories();
}
