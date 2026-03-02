import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handling is automatic with FCM
  debugPrint('Background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  // Callback for when a notification triggers navigation
  static Function(Map<String, dynamic>)? onNotificationTap;

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token
    _fcmToken = await _messaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _onTokenRefresh(newToken);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.data}');
      onNotificationTap?.call(message.data);
    });

    // Background → App opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Opened from background: ${message.data}');
      onNotificationTap?.call(message.data);
    });

    // Terminated → App opened via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Opened from terminated: ${initialMessage.data}');
      // Delay slightly to allow app to initialize
      Future.delayed(const Duration(milliseconds: 500), () {
        onNotificationTap?.call(initialMessage.data);
      });
    }
  }

  static String? get fcmToken => _fcmToken;

  static Future<String?> getToken() async {
    _fcmToken ??= await _messaging.getToken();
    return _fcmToken;
  }

  // Called when FCM token refreshes — update Firestore
  static void _onTokenRefresh(String newToken) async {
    // Import firebase_service lazily to avoid circular imports
    // This is handled in FirebaseService.updateFcmToken
    debugPrint('Token refreshed: $newToken');
  }
}