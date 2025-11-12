import 'package:chat_app/core/entities/entity.dart';

class UpdateFcm extends BaseEntity {
  final String fcmToken;
  final String deviceId;

  UpdateFcm({required this.fcmToken, required this.deviceId});
  @override
  Map<String, dynamic> toJson() => {
        'fcm_token': fcmToken,
        'device_id': deviceId,
      };
}
