import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission();

    // Get token and save to Firestore
    String? token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> _saveTokenToDatabase(String token) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('order_updates', 'Order Updates',
        importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  // Gửi thông báo đến khách hàng (Giả lập qua API hoặc Cloud Functions)
  Future<void> sendNotificationToUser(String userId, String title, String body) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String? token = (userDoc.data() as Map<String, dynamic>?)?['fcmToken'];

    if (token != null) {
      // Trong thực tế, việc gửi FCM nên được thực hiện từ Backend (Node.js/Cloud Functions)
      // Ở đây chúng ta ghi log vào Firestore để Cloud Function có thể trigger
      await FirebaseFirestore.instance.collection('notifications').add({
        'to': token,
        'userId': userId,
        'title': title,
        'body': body,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    }
  }
}
