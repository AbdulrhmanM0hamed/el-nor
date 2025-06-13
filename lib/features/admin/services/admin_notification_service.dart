// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AdminNotificationService {
//   final supabase = Supabase.instance.client;
//   static const String serverUrl = 'https://notification-server-elnor.vercel.app'; 

//   Future<void> sendNotificationToAll({
//     required String title,
//     required String body,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     try {
//       // Get all FCM tokens
//       final response = await supabase
//           .from('user_tokens')
//           .select('fcm_token');

//       final List<String> tokens = (response as List)
//           .map((item) => item['fcm_token'].toString())
//           .toList();

//       if (tokens.isEmpty) {
//         print('لا يوجد مستخدمين مسجلين للإشعارات');
//         return;
//       }

//       // Send notification to each token
//       for (final token in tokens) {
//         await _sendNotification(
//           token: token,
//           title: title,
//           body: body,
//           data: additionalData,
//         );
//       }

//     } catch (e) {
//       print('خطأ في إرسال الإشعارات: $e');
//       rethrow;
//     }
//   }

//   Future<void> sendNotificationToUsers({
//     required List<String> userIds,
//     required String title,
//     required String body,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     try {
//       // Get FCM tokens for specific users
//       final response = await supabase
//           .from('user_tokens')
//           .select('fcm_token')
//           .filter('user_id', 'in', userIds);

//       final List<String> tokens = (response as List)
//           .map((item) => item['fcm_token'].toString())
//           .toList();

//       if (tokens.isEmpty) {
//         print('لا يوجد مستخدمين مسجلين للإشعارات');
//         return;
//       }

//       // Send notification to each token
//       for (final token in tokens) {
//         await _sendNotification(
//           token: token,
//           title: title,
//           body: body,
//           data: additionalData,
//         );
//       }

//       print('تم إرسال الإشعار بنجاح لـ ${tokens.length} مستخدم');
//     } catch (e) {
//       print('خطأ في إرسال الإشعارات: $e');
//       rethrow;
//     }
//   }

//   Future<void> _sendNotification({
//     required String token,
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$serverUrl/send-notification'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'token': token,
//           'title': title,
//           'body': body,
//           'data': data ?? {},
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw Exception('فشل في إرسال الإشعار. الحالة: ${response.statusCode}\nالرد: ${response.body}');
//       }
//     } catch (e) {
//       print('خطأ في إرسال الإشعار: $e');
//       rethrow;
//     }
//   }
// } 