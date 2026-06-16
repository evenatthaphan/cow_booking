import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Handler สำหรับ background message (ต้องอยู่นอก class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase จัดการแสดง notification อัตโนมัติเมื่อ app ปิดอยู่
  debugPrint('Background message: ${message.notification?.title}');
}

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// เรียกครั้งเดียวตอน app เริ่ม
  static Future<void> init() async {
    // ขอ permission (iOS จำเป็น, Android 13+ จำเป็น)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground: แสดง notification ขณะ app เปิดอยู่
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      // ถ้าอยากแสดง in-app dialog/snackbar เพิ่มตรงนี้ได้
    });
  }

  /// ดึง FCM Token เพื่อส่งขึ้น backend
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe refresh token (token อาจเปลี่ยนได้)
  static void onTokenRefresh(Future<void> Function(String) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}