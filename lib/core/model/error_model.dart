import 'package:chat_app/core/utils/app_utils.dart';

class ErrorModel {
  final String key;
  final List<String> messages;

  ErrorModel({
    required this.key,
    required this.messages,
  });

  static List<ErrorModel> fromJson(dynamic json) {
    List<ErrorModel> errors = [];
    if (json is Map) {
      json.forEach((key, value) {
        AppUtils.log(key);
        if (value is String) {
          errors.add(ErrorModel(key: key, messages: [value]));
        } else if (value is List) {
          errors.add(ErrorModel(key: key, messages: List<String>.from(value)));
        }
      });
    } else if (json is List) {
      for (var i = 0; i < json.length; i++) {
        json[i].forEach((key, value) {
          AppUtils.log(key);
          if (value is String) {
            errors.add(ErrorModel(key: key, messages: [value]));
          } else if (value is List) {
            errors
                .add(ErrorModel(key: key, messages: List<String>.from(value)));
          }
        });
      }
    }

    return errors;
  }
}
