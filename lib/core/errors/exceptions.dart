import 'package:chat_app/core/errors/failure.dart';

abstract interface class AppException implements Exception {
  Failure map(String message, String title);
}

class OffLineException implements AppException {
  @override
  Failure map(String message, String title) {
    return OfflineFailure(message: message, title: title);
  }
}

class FireBaseDataBaseException extends AppException {
  @override
  Failure map(String message, String title) =>
      FirebaseDatabaseFailure(message: message, title: title);
}
