import 'dart:convert';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/presentation/bloc/categories/categories_bloc.dart';
import 'package:chat_app/chat/presentation/bloc/controllers/chat_controller.dart';
import 'package:chat_app/chat/presentation/pages/categores_page.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ===============================
/// 🔴 BACKGROUND HANDLER (IMPORTANT)
/// ===============================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('count') ?? 0;

    await prefs.setInt('count', count + 1);
    await AppBadgePlus.updateBadge(count + 1);
  } catch (e) {
    // ignore background errors
  }
}

class NotificationServices {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ===============================
  /// 🔑 TOKEN
  /// ===============================
  Future<String> getDeviceToken() async {
    if (Platform.isIOS) {
      final token = await messaging.getAPNSToken();
      return token ?? '';
    }
    final token = await messaging.getToken();
    return token ?? '';
  }

  void isRefreshToken() {
    messaging.onTokenRefresh.listen((event) {
      AppUtils.log('Token Refreshed: $event');
    });
  }

  /// ===============================
  /// 🔔 PERMISSIONS
  /// ===============================
  Future<void> requestNotificationPermisions() async {
    if (Platform.isIOS) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    try {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );
    } catch (e, stackTrace) {
      // تسجيل الخطأ لتسهيل debug
      print('Error requesting FCM permission: $e');
      print(stackTrace);

      // أو تعرض رسالة للمستخدم
      // AppUtils.showCustomSnackbar(
      //     title: 'خطأ',
      //     message: 'فشل السماح بالإشعارات',
      //     type: SnackType.FAILURE);
    }
  }

  /// ===============================
  /// 🍏 IOS FOREGROUND
  /// ===============================
  Future<void> forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// ===============================
  /// 🔥 FOREGROUND LISTENER
  /// ===============================
  void firebaseInit(BuildContext context, WidgetRef ref) {
    FirebaseMessaging.onMessage.listen((message) async {
      /// ---- BADGE (SAFE)
      try {
        final prefs = await SharedPreferences.getInstance();
        final count = prefs.getInt('count') ?? 0;

        await prefs.setInt('count', count + 1);
        await AppBadgePlus.updateBadge(count + 1);
      } catch (_) {}

      /// ---- DATA HANDLING (SAFE)
      try {
        final payloadString = message.data['payload'];
        if (payloadString != null) {
          final payload = jsonDecode(payloadString);
          final room = payload['data']?['room'];
          final roomDate = RecentChat.fromMap(room);

          if (roomDate.categoryId == AppUtils.activeRoom) {
            ref.read(chatControllerProvider.notifier).addNewChat(roomDate);
          }

          CategoresPage.contextPage
              ?.read<CategoriesBloc>()
              .add(GetCategories());
        }
      } catch (e) {
        // ignore UI errors (background-safe)
        AppUtils.log('UI update ignored: $e');
      }

      /// ---- LOCAL NOTIFICATION
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }

      if (Platform.isIOS) {
        forgroundMessage();
      }
    });
  }

  /// ===============================
  /// 📲 LOCAL NOTIFICATION INIT
  /// ===============================
  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings();

    final initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {
        handleMesssage(context, message);
      },
    );
  }

  /// ===============================
  /// 👉 HANDLE TAP
  /// ===============================
  void handleMesssage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'text') {
      // handle navigation if needed
    }
  }

  /// ===============================
  /// 🔔 SHOW NOTIFICATION
  /// ===============================
  Future<void> showNotification(RemoteMessage message) async {
    final channel = AndroidNotificationChannel(
      message.notification?.android?.channelId ?? 'default_channel',
      'Notifications',
      importance: Importance.max,
      showBadge: true,
    );

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  /// ===============================
  /// 🚀 INTERACTION (TERMINATED / BG)
  /// ===============================
  Future<void> setupInteractMessage(BuildContext context) async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMesssage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMesssage(context, event);
    });
  }
}
