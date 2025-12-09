import 'dart:io';

import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/core/utils/snack_bar_type_enum.dart';
import 'package:chat_app/injections/injections_main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
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
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token;
    try {
      token = await messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return null;
        },
      );
    } catch (e) {
      return null;
    }

    return token;
  }

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }

    return deviceId;
  }

  Future<void> setUser();
  Future<void> logout();
  User? getUser();
  Locale? getLocale();
}
