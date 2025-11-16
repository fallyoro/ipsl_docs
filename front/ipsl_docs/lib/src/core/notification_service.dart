import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/services/auth_service.dart';

import 'utils.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final UserService userService = GetIt.I<UserService>();
  //final UserService userService = UserService(dio: dio);
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _token;
  //getter for the variable token
  static String? get token {
    return _token;
  }

  static Future<void> init() async {
    // Initialisation des notifications locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(initSettings);
    // Request permission for iOS (no effect on Android)
    await _messaging.requestPermission();

    // Get the token each time the application loads
    String? t = await _messaging.getToken();
    _token = t;
    logInfo("Firebase Messaging Token: $token");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
      logInfo('Received a message while in the foreground!');
      logInfo('Message data: ${message.data}');

      if (message.notification != null) {
        logInfo(
          'Message also contained a notification: ${message.notification}',
        );
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    logInfo('Handling a background message: ${message.messageId}');
  }

  //Linsten to token refresh and send it to the backend (async)
  Future<void> listenToTokenRefresh(String userName) async {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _token = newToken;
      logInfo("Firebase Messaging Token refreshed: $newToken");
      if (await isConnectedToInternet()) {
        try {
          await userService.updateFcmToken(userName, newToken);
          logInfo("FCM token registered for user: $userName");
        } catch (e) {
          logError("Failed to register FCM token: $e");
        }
      }
    });
  }

  static String? _lastMessageId;
  static Future<void> _showNotification(RemoteMessage message) async {
    if (message.messageId == _lastMessageId) {
      logInfo("Notification déjà affichée : ${message.messageId}");
      return; // 🔒 évite un doublon
    }
    _lastMessageId = message.messageId;
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel_id',
          'Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    //make the id notification unique by using the hashcode of the message
    final int notificationId = message.messageId.hashCode;
    logInfo("Notification ID: $notificationId=================");
    //  final int notificationId =  DateTime.now().millisecondsSinceEpoch;
    await _localNotifications.show(
      notificationId,
      message.notification?.title ?? 'Nouvelle notification',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }
}
