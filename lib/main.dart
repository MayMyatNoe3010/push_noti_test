import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:push_noti_test/noti_services.dart';
import 'firebase_options.dart';
import 'notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // // 🔹 Handle background notifications
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // // 🔹 Initialize Notification Service
  // await NotificationService().init();
  await NotiService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notification Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Push Notification Test'), actions: [
          IconButton(onPressed: (){

          }, icon: Icon(Icons.download_rounded))
        ],),
        body: Center(
          child: Column(
            children: [


              ElevatedButton(
                onPressed: () async {
                  final token = await NotificationService().getToken();
                  debugPrint('Device FCM Token: $token');
                },
                child: const Text('Get FCM Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
