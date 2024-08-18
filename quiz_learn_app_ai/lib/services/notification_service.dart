import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quiz_learn_app_ai/main.dart';
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class PushNotifications {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseService firebaseService = FirebaseService();
  final firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // request notification permission
  Future init() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }

  Future<String> getUserToken(String userId) async {
    try {
      final snapshot = await database.child('users').child(userId).get();
      if (snapshot.exists) {
        return (snapshot.value as Map<String, dynamic>?)?['token'];
      }
      return '';
    } catch (e) {
      throw Exception('Error loading user token: ${e.toString()}');
    }
  }

  Future<void> sendSinglePushNotification(
      String token, String title, String body) async {}

  Future<void> saveUserToken(String token) async {
    User? user = auth.currentUser;
    // Remove the condition since the user variable is already checked for nullability.
    try {
      await database.child('users').child(user!.uid).update({'token': token});
      if (kDebugMode) {
        print('User token saved successfully');
      }
    } catch (e) {
      throw Exception('Error saving user token: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    User? user = auth.currentUser;
    return user != null;
  }

  // get the fcm device token
  Future getDeviceToken({int maxRetires = 3}) async {
    try {
      String? token;
      if (kIsWeb) {
        // get the device fcm token
        token = await firebaseMessaging.getToken(
            vapidKey:
                "BPA9r_00LYvGIV9GPqkpCwfIl3Es4IfbGqE9CSrm6oeYJslJNmicXYHyWOZQMPlORgfhG8RNGe7hIxmbLXuJ92k");
        if (kDebugMode) {
          print("for web device token: $token");
        }
      } else {
        // get the device fcm token
        token = await firebaseMessaging.getToken();
        print("for android device token: $token");
      }
      saveTokenToFirebase(token: token!);
      return token;
    } catch (e) {
      if (kDebugMode) {
        print("failed to get device token");
      }
      if (maxRetires > 0) {
        if (kDebugMode) {
          print("try after 10 sec");
        }
        await Future.delayed(const Duration(seconds: 10));
        return getDeviceToken(maxRetires: maxRetires - 1);
      } else {
        return null;
      }
    }
  }

  saveTokenToFirebase({required String token}) async {
    bool isUserLoggedIn = await isLoggedIn();
    if (kDebugMode) {
      print("User is logged in $isUserLoggedIn");
    }
    if (isUserLoggedIn) {
      await saveUserToken(token);
      if (kDebugMode) {
        print("save to firebase");
      }
    }
    //save if token changes
    firebaseMessaging.onTokenRefresh.listen((event) async {
      if (isUserLoggedIn) {
        await saveUserToken(token);
        if (kDebugMode) {
          print("save to firebase");
        }
      }
    });
  }

  // initialize local notifications
   Future localNotificationsInit() async {
    // initialize the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/luncher_icon',
    );
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    // request notification permissions for android 13 or above
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!
        .pushNamed("/message", arguments: notificationResponse);
  }

  // show a simple notification
   Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }
}
