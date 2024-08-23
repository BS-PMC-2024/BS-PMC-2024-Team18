// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:quiz_learn_app_ai/auth/realsecrets.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:quiz_learn_app_ai/services/firebase_service.dart';

class PushNotifications {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final FirebaseAuth fbAuth = FirebaseAuth.instance;
  final FirebaseService firebaseService = FirebaseService();
  final firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveLocalNotification(
      NotificationResponse notificationResponse) async {
    if (kDebugMode) {
      print('onDidReceiveLocalNotification called');
    }
  }

  // request notification permission
  Future<void> requestPermission() async {
    PermissionStatus permission = await Permission.notification.request();
    if (permission.isGranted) {
      if (kDebugMode) {
        print('Notification permission granted');
      }
    } else {
      throw Exception('Notification permission not granted');
    }
  }

  // initialize local notifications
  Future init() async {
    // initialize the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    // final LinuxInitializationSettings initializationSettingsLinux =
    //     LinuxInitializationSettings(defaultActionName: 'Open notification');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    //linux: initializationSettingsLinux);

    // request notification permissions for android 13 or above
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveLocalNotification,
    );
  }

  Future<String> getUserToken(String userId) async {
    try {
      final snapshot = await database
          .child('users')
          .child(userId)
          .child("deviceToken")
          .get();
      if (snapshot.exists) {
        return (snapshot.value as Map<String, dynamic>?)?['deviceToken'];
      }
      return '';
    } catch (e) {
      throw Exception('Error loading user token: ${e.toString()}');
    }
  }

  Future<void> sendSinglePushNotification(
      String token, String title, String body) async {}

  // get the fcm device token
  Future<String?> generateDeviceToken() async {
    User? user = fbAuth.currentUser;
    try {
      // get the device fcm token
      String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print("for android device token: $deviceToken");
      }
      firebaseMessaging.onTokenRefresh.listen((event) async {
        try {
          await database
              .child('users')
              .child(user!.uid)
              .child('deviceToken')
              .set(deviceToken);
          if (kDebugMode) {
            print(
                'Token updated, new Token: $deviceToken. User token saved successfully');
          }
          firebaseMessaging.subscribeToTopic("students");
          firebaseMessaging.subscribeToTopic("lecturers");
        } catch (e) {
          throw Exception('Error saving user token: ${e.toString()}');
        }
      });
      try {
        await database
            .child('users')
            .child(user!.uid)
            .child('deviceToken')
            .set(deviceToken);
        if (kDebugMode) {
          print('User token saved successfully');
        }
        firebaseMessaging.subscribeToTopic("students");
        firebaseMessaging.subscribeToTopic("lecturers");
      } catch (e) {
        throw Exception('Error saving user token: ${e.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("failed to get device token");
      }
    }
    return null;
  }

  startListeningForNewNotifications(BuildContext context) {
    // terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print("Launched from terminated state");
        }
        Future.delayed(const Duration(seconds: 1), () {});
      }
    });
    // foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print("Launched from terminated state");
        }
        Future.delayed(const Duration(seconds: 1), () {});
      }
    });
    // background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message?.notification != null) {
        if (kDebugMode) {
          print("Background Notification Tapped");
        }
      }
    });

    // Listen to background notifications
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessage);
  }

  // function to listen to background changes
  Future firebaseBackgroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      if (kDebugMode) {
        print("Some notification Received in background...");
      }
    }
  }

  

  // show a simple notification
  Future<void> showSimpleNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000).toString(),
      'Quiz Learn App AI',
      importance: Importance.max,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker'),
        iOS: const DarwinNotificationDetails());

    await flutterLocalNotificationsPlugin.show(1, message.notification!.title,
        message.notification!.body, platformChannelSpecifics,
        payload: message.data['data']);
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<bool> sendPushNotifications(String deviceToken, String? body,
      String? title, String? data, BuildContext? context) async {
    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/quizlearnappai/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': title ?? 'New Message',
          'body': body ?? 'You have a new message',
        },
        'data': {'data': data, 'click_action': 'FLUTTER_NOTIFICATION_CLICK'}
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Notification sent successfully');
      }
      return true;
    } else {
      if (kDebugMode) {
        print('Failed to send notification: ${response.statusCode}');
      }
      return false;
    }
  }

  Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = jsonServiceKey;

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }
}
