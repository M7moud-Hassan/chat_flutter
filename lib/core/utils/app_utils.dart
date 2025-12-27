import 'dart:io';

import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/core/utils/snack_bar_type_enum.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';

abstract class AppUtils {
  static final instance = sl<AppUtils>();
  static final GetIt sl = GetIt.instance;
  static bool netConnect = true;
  static final logger = Logger();
  static String? idDevice = '';
  static User? user;
  static BuildContext? context;
  static int? activeRoom;

  static List<T> generateList<T>(List<dynamic> data, Function fromJson) {
    final list = <T>[];
    for (final item in data) {
      list.add(fromJson(item));
    }
    return list;
  }

  static void showCustomSnackbar(String message, SnackType type,
      {String title = ''}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.snackbar(
        title,
        message,
        titleText: title.isEmpty
            ? Container()
            : Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
        snackPosition: SnackPosition.TOP,
        forwardAnimationCurve: Curves.easeInOutCubic,
        reverseAnimationCurve: Curves.easeInOutCubic,
        backgroundColor: type == SnackType.FAILURE ? Colors.red : Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        icon: type != SnackType.FAILURE
            ? const Icon(
                Icons.check_circle,
                color: Colors.white,
              )
            : const Icon(
                Icons.error,
                color: Colors.white,
              ),
        duration: const Duration(milliseconds: 3000),
      );
    });
  }

  void setUpNotifications(BuildContext context, WidgetRef ref);
  static void log(String log, {Level levelLog = Level.info}) {
    logger.log(levelLog, log);
  }

  Future<String?> fcmToken() async {
    final messaging = FirebaseMessaging.instance;

    // 1️⃣ اطلب الإذن
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      print('❌ Notification permission not granted');
      return null;
    }

    // 2️⃣ تأكد من APNs
    String? apnsToken = await messaging.getAPNSToken();
    print('🍎 APNs Token: $apnsToken');

    // انتظر APNs شوية لو لسه
    int retry = 0;
    while (apnsToken == null && retry < 5) {
      await Future.delayed(const Duration(seconds: 1));
      apnsToken = await messaging.getAPNSToken();
      retry++;
    }

    if (apnsToken == null) {
      print('❌ APNs token still null');
      return null;
    }

    // 3️⃣ هات FCM Token
    final token = await messaging.getToken();
    print('🔥 FCM Token: $token');

    return token;
  }

  static Future<String> getDeviceId() async {
    String deviceName = '';
    String deviceVersion = '';
    String identifier = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.id; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor ?? ''; //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

//if (!mounted) return;
    return deviceName + deviceVersion + identifier;
  }

  Future<void> setUser();
  Future<void> logout();
  User? getUser();
  Locale? getLocale();
}
