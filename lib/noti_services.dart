import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import '../firebase_options.dart';
import 'notification_vo.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  print('Handling a background message: ${message.messageId}');
  //showNotification(message);
  // Update SharedPreferences safely in the background
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('newNoti', true);
}

class NotiService {
  NotiService._();
  static final NotiService instance = NotiService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Setup message handlers
    await setupFlutterNotifications();
    await _setupMessageHandlers();

    // try{
    //   await setupFlutterNotifications();
    // }catch(e){
    //   log(e.toString(), name:'NotificationError');
    // }



    // Get FCM token
    final token = await _messaging.getToken();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

  }

  Future<String?> getFCMToken() async {
    final token = await _messaging.getToken();
    log(token!, name: 'FirebaseToken');
    return token;
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // android setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // ios setup
    const initializationSettingsDarwin = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // flutter notification setup
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleBackgroundMessage(
            RemoteMessage(data: {'data': details.payload}));
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print("Background message: ${message.messageId}");

    final data = message.data;
    String? notiData = data['data'];
    NotificationVO? notiFromNotiTap;
    if (notiData != null) {
      Map<String, dynamic>? formatData = jsonDecode(notiData);
      notiFromNotiTap = NotificationVO.fromJson(formatData ?? {});
    }
    // if (notiFromNotiTap?.type == 'news') {
    //   navigatorKey.currentState
    //       ?.pushNamed('/notification_detail', arguments: data);
    // }
  }

  Future<void> _setupMessageHandlers() async {
    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      log('Foreground',name: 'NotiType');
      showNotification(message);
     // NotiStatus().setNotificationStatus(true);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        log('Background',name: 'NotiType');
        _handleBackgroundMessage(message);
      },
    );



    // opened app
    //final initialMessage = await _messaging.getInitialMessage();
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      log('OpenApp',name: 'NotiType');
      _handleBackgroundMessage(initialMessage);
    }
  }
}

@pragma('vm:entry-point')
Future<void> showNotification(RemoteMessage message) async {
  log('${message.toMap().toString()}',name: 'RemoteMessage');
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    await FlutterLocalNotificationsPlugin().show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
          'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}