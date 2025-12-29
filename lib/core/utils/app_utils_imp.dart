import 'dart:convert';
import 'dart:ui';

import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/domain/entities/update_fcm.dart';
import 'package:chat_app/chat/domain/usercases/update_info_user_case.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:chat_app/core/utils/check_internet.dart';
import 'package:chat_app/core/utils/dio.dart';
import 'package:chat_app/core/utils/notification.dart';
import 'package:chat_app/injections/injections_main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUtilsImp extends AppUtils {
  final DioConfig dio;
  // final CheckInternetConnection checkinternet;
  final SharedPreferences prefs;
  final NotificationServices notificationServices;

  AppUtilsImp(
      {required this.dio,
      // required this.checkinternet,
      required this.prefs,
      required this.notificationServices}) {
    AppUtils.getDeviceId().then((value) {
      if (value.isNotEmpty) {
        prefs.setString('id', value);
        AppUtils.idDevice = value;
      }
    });

    notificationServices.requestNotificationPermisions().then((_) {
      notificationServices.forgroundMessage().then((_) async {
        await Future.delayed(const Duration(seconds: 1));
        updateToken();
      });
    });
  }

  void updateToken() {
    final user = getUser();
    if (user != null && user.fcmToken == null) {
      final userUpdateUser = sl<UpdateInfoUserCase>();
      fcmToken().then((token) async {
        userUpdateUser(UpdateFcm(
            fcmToken: token ?? user.deviceId,
            deviceId: await AppUtils.getDeviceId()));
      });

      FirebaseMessaging.instance.onTokenRefresh.listen((value) async {
        userUpdateUser(
            UpdateFcm(fcmToken: value, deviceId: await AppUtils.getDeviceId()));
      });
    }
  }

  @override
  Locale? getLocale() {
    return null;
  }

  @override
  User? getUser() {
    if (prefs.containsKey('user')) {
      final data = prefs.getString('user');
      if (data != null) {
        final user = User.fromMap(jsonDecode(data));
        AppUtils.user = user;
        return user;
      }
    }
    return null;
  }

  @override
  Future<void> setUser() async {
    final user = AppUtils.user;
    await prefs.setString('user', jsonEncode(user!.toMap()));
    updateToken();
  }

  @override
  Future<void> logout() async {
    await prefs.remove('user');
    AppUtils.user = null;
  }

  @override
  void setUpNotifications(BuildContext context, WidgetRef ref) {
    notificationServices.requestNotificationPermisions();
    notificationServices.firebaseInit(context, ref);
    notificationServices.setupInteractMessage(context);
  }
}
