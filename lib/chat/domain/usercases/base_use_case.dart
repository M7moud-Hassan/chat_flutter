import 'package:chat_app/chat/domain/repositories/chat_repo.dart';

abstract class BaseUseCase {
  final ChatRepo chatRepo;

  BaseUseCase({required this.chatRepo});
}
