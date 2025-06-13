import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure you have initialized Firebase here if needed
  debugPrint('تم استلام إشعار في الخلفية: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final supabase = Supabase.instance.client;
  
  static const String serverUrl = 'https://notification-server-elnor.vercel.app';

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initNotifications() async {
    try {
      // Request permissions first
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          debugPrint('تم منح إذن الإشعارات');
          
          // Initialize local notifications in parallel
          await _initLocalNotifications();
          
          // Setup message handlers in parallel
          await _setupMessageHandlers();
          
          // Get and save FCM token
          final fcmToken = await getFCMToken();
          if (fcmToken != null) {
            await saveTokenToSupabase(fcmToken);
          }
          break;
        
        case AuthorizationStatus.provisional:
          debugPrint('تم منح إذن الإشعارات مؤقتاً');
          break;
        
        case AuthorizationStatus.denied:
          debugPrint('تم رفض إذن الإشعارات');
          break;
        
        case AuthorizationStatus.notDetermined:
          debugPrint('لم يتم تحديد حالة إذن الإشعارات');
          break;
      }
    } catch (e) {
      debugPrint('خطأ في تهيئة الإشعارات: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details);
      },
    );
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> saveTokenToSupabase(String? token) async {
    if (token == null) return;
    
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Delete existing tokens for this user first
      await supabase
          .from('user_tokens')
          .delete()
          .eq('user_id', userId);

      // Insert new token
      await supabase.from('user_tokens').insert({
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      print('تم حفظ التوكن بنجاح');
    } catch (e) {
      print('خطأ في حفظ التوكن: $e');
    }
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // لا نقوم بعرض إشعار محلي عندما يكون التطبيق في المقدمة
      // سيتم عرض الإشعار تلقائياً بواسطة FCM
      debugPrint('تم استلام إشعار في المقدمة: ${message.messageId}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidDetails =  AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(dynamic details) {
    print('تم الضغط على الإشعار: $details');
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('NotificationService: بدء إرسال إشعار لـ token: ${token.substring(0, 10)}...');
      print('NotificationService: محتوى الإشعار:');
      print('- العنوان: $title');
      print('- المحتوى: $body');
      print('- البيانات الإضافية: $data');

      final response = await http.post(
        Uri.parse('$serverUrl/send-notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('فشل في إرسال الإشعار. الحالة: ${response.statusCode}\nالرد: ${response.body}');
      }

      print('NotificationService: تم إرسال الإشعار بنجاح');
    } catch (e) {
      print('NotificationService: خطأ في إرسال الإشعار:');
      print('NotificationService: نوع الخطأ: ${e.runtimeType}');
      print('NotificationService: تفاصيل الخطأ: $e');
      rethrow;
    }
  }

  Future<void> deleteToken() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase
          .from('user_tokens')
          .delete()
          .eq('user_id', userId);
      
      print('تم حذف التوكن بنجاح');
    } catch (e) {
      print('خطأ في حذف التوكن: $e');
    }
  }

  Future<void> cleanupDuplicateTokens() async {
    try {
      // Get all tokens with their user_id and updated_at
      final allTokens = await supabase
          .from('user_tokens')
          .select('user_id,fcm_token,updated_at');

      // Group tokens by user_id and keep only the latest one
      final Map<String, Map<String, dynamic>> latestTokens = {};
      for (final token in allTokens) {
        final userId = token['user_id'];
        if (!latestTokens.containsKey(userId)) {
          latestTokens[userId] = token;
        } else {
          final existingToken = latestTokens[userId]!;
          if (token['updated_at'] != null && existingToken['updated_at'] != null) {
            final existingDateTime = DateTime.parse(existingToken['updated_at']);
            final newDateTime = DateTime.parse(token['updated_at']);
            if (newDateTime.isAfter(existingDateTime)) {
              latestTokens[userId] = token;
            }
          }
        }
      }

      // Delete all tokens that are not the latest for each user
      for (final token in allTokens) {
        final userId = token['user_id'];
        final latestToken = latestTokens[userId];
        if (latestToken != null && token['fcm_token'] != latestToken['fcm_token']) {
          await supabase
              .from('user_tokens')
              .delete()
              .eq('user_id', userId)
              .eq('fcm_token', token['fcm_token']);
        }
      }
      
      print('تم تنظيف التوكنات المكررة بنجاح');
    } catch (e) {
      print('خطأ في تنظيف التوكنات المكررة: $e');
    }
  }
} 