import 'package:chat_app/core/entities/entity.dart';

class LoginEntity extends BaseEntity {
  final String username;
  final String password;
  final String deviceId;
  final String type;

  LoginEntity(
      {required this.username,
      required this.password,
      required this.deviceId,
      required this.type});

  @override
  Map<String, dynamic> toJson() =>
      {"username": username, "password": password, "device_id": deviceId};
}
