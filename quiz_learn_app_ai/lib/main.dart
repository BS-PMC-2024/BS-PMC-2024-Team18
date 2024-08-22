import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiz_learn_app_ai/auth_pages/auth_page.dart';
import 'package:quiz_learn_app_ai/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:quiz_learn_app_ai/notifications/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    if (kDebugMode) {
      print("Some notification Received in background...");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  // initialize firebase messaging
  await PushNotifications().init();
  //await PushNotifications().requestPermission();

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // void notificationHandler() {

  //   // terminated
  //   FirebaseMessaging.instance
  //       .getInitialMessage()
  //       .then((RemoteMessage? message) async {
  //     if (message != null) {
  //       String? data = message.data['data'];
  //       if (kDebugMode) {
  //         print("Launched from terminated state");
  //       }
  //       Future.delayed(const Duration(seconds: 1), () {});
  //     }
  //   });
  //   // foreground
  //   FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
  //     if (message != null) {
  //       if (kDebugMode) {
  //         print(message.notification!.title);
  //       }
  //       String? data = message.data['data'];
  //       if (kDebugMode) {
  //         print("Got a message in foreground");
  //       }
  //       if (message.notification != null) {
  //         PushNotifications().showSimpleNotification(message);
  //       }
  //     }
  //   });
  //   // background
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
  //     if (message?.notification != null) {
  //       if (kDebugMode) {
  //         print("Background Notification Tapped");
  //       }
  //     }
  //   });

  //   // Listen to background notifications
  //   FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage(),
      // navigatorKey: navigatorKey,
      // routes: {
      //   "/message": (context) => const Message(),
      // },
    );
  }
}
