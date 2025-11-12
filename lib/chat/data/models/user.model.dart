enum UserActivityStatus {
  online('Online'),
  offline('Offline');

  const UserActivityStatus(this.value);
  final String value;

  factory UserActivityStatus.fromValue(String value) {
    final res = UserActivityStatus.values.where(
      (element) => element.value == value,
    );

    if (res.isEmpty) {
      throw 'ValueError: $value is not a valid status code';
    }

    return res.first;
  }
}

class Token {
  final String token;
  final DateTime expireAt;

  Token({required this.token, required this.expireAt});

  factory Token.fromMap(Map<String, dynamic> data) {
    return Token(
      token: data['token'],
      expireAt: DateTime.parse(data['expire_at']),
    );
  }

  Map<String, dynamic> toMap() => {
        'token': token,
        'expire_at': expireAt.toIso8601String(),
      };

  bool get isExpired => DateTime.now().isAfter(expireAt);
}

class User {
  final int id;
  final String deviceId;
  final bool isActive;
  final String createdAt;
  final String? lastLogin;
  final Token? refresh;
  final Token? access;
  final bool isAdmin;
  String? fcmToken;

  // @Enumerated(EnumType.value, 'value')
  // UserActivityStatus activityStatus;

  setFcm(String fcm) {
    fcmToken = fcm;
  }

  User(
      {required this.id,
      required this.deviceId,
      required this.isActive,
      required this.createdAt,
      required this.lastLogin,
      required this.refresh,
      required this.access,
      this.fcmToken,
      required this.isAdmin});

  factory User.fromMap(Map<String, dynamic> userData) {
    return User(
        id: userData['id'],
        deviceId: userData['device_id'],
        isActive: userData['is_active'],
        lastLogin: userData['last_login'],
        createdAt: userData['created_at'],
        isAdmin: userData['is_staff'] ?? false,
        fcmToken: userData['fcm_token'],
        access: userData.containsKey('access')
            ? Token.fromMap(userData['access'])
            : null,
        refresh: userData.containsKey('refresh')
            ? Token.fromMap(userData['refresh'])
            : null);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'is_active': isActive,
      'last_login': lastLogin,
      'created_at': createdAt,
      'is_staff': isAdmin,
      'access': access?.toMap(),
      'refresh': refresh?.toMap(),
      'fcm_token': fcmToken,
    };
  }

  @override
  String toString() {
    return deviceId;
  }
}
