import 'dart:convert';
import 'dart:io';

import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/core/utils/snack_bar_type_enum.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:crypto/crypto.dart';

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

  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Notification Permission: ${settings.authorizationStatus}');
  }

  Future<String?> fcmToken() async {
    final messaging = FirebaseMessaging.instance;

    // iOS: make sure permissions are granted
    await requestPermission();

    // Get the FCM token
    final token = await messaging.getToken();
    print('🔥 FCM Token: $token');

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: $newToken');
      // TODO: Send new token to backend
    });

    return token;
  }

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String rawData = '';

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      rawData = [
        ios.name,
        ios.model,
        ios.systemName,
        ios.systemVersion,
        ios.utsname.machine,
        ios.identifierForVendor, // optional, adds uniqueness
      ].join('|');
    } else if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      rawData = [
        android.brand,
        android.device,
        android.model,
        android.hardware,
        android.manufacturer,
        android.product,
        android.version.sdkInt.toString(),
      ].join('|');
    }

    // Generate hash (SHA-256) to get a fixed-length unique ID
    final bytes = utf8.encode(rawData);
    return sha256.convert(bytes).toString();
  }

  Future<void> setUser();
  Future<void> logout();
  User? getUser();
  Locale? getLocale();
}
