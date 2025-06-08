import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer';
import '../utils/user_role.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final _supabaseClient = Supabase.instance.client;
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _useSharedPrefs = false;
  
  static const String _sessionKey = 'user_session';
  static const String _roleKey = 'user_role';
  static const String _permissionsKey = 'user_permissions';
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Try to initialize secure storage
      try {
        await _secureStorage.deleteAll();
        _useSharedPrefs = false;
      } catch (e) {
        // If secure storage fails, fall back to shared preferences
        log('SessionService: التخزين الآمن غير متاح، استخدام SharedPreferences كبديل');
        _prefs = await SharedPreferences.getInstance();
        await _prefs.clear();
        _useSharedPrefs = true;
      }
      
      _isInitialized = true;
      log('SessionService: تم التهيئة بنجاح');
    } catch (e) {
      log('SessionService: خطأ في التهيئة: $e');
      rethrow;
    }
  }

  Future<void> _writeSecure(String key, String value) async {
    if (_useSharedPrefs) {
      await _prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  Future<String?> _readSecure(String key) async {
    if (_useSharedPrefs) {
      return _prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  Future<void> _deleteSecure(String key) async {
    if (_useSharedPrefs) {
      await _prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> _deleteAllSecure() async {
    if (_useSharedPrefs) {
      await _prefs.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }
  
  Future<void> createSession(String userId, UserRole role) async {
    try {
      await initialize();
      
      final sessionData = {
        'userId': userId,
        'role': role.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final permissions = _getPermissionsForRole(role);
      
      // Update database first
      await _supabaseClient
          .from('students')
          .update({
            'session_key': sessionData['timestamp'],
            'last_session': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      
      // Then update secure storage
      await Future.wait([
        _writeSecure(_sessionKey, json.encode(sessionData)),
        _writeSecure(_roleKey, role.toString()),
        _writeSecure(_permissionsKey, json.encode(permissions)),
      ]);
          
      log('SessionService: تم إنشاء جلسة جديدة مع الدور: ${role.toString()}');
    } catch (e) {
      log('SessionService: خطأ في إنشاء الجلسة: $e');
      await clearSession();
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> getCurrentSession() async {
    try {
      await initialize();
      
      final sessionStr = await _readSecure(_sessionKey);
      if (sessionStr == null) return null;
      
      final sessionData = json.decode(sessionStr) as Map<String, dynamic>;
      final userId = sessionData['userId'] as String;
      final roleStr = sessionData['role'] as String;
      
      // Validate session in database
      final dbUser = await _supabaseClient
          .from('students')
          .select('session_key, is_admin, is_teacher')
          .eq('id', userId)
          .single();
          
      if (dbUser == null || dbUser['session_key'] != sessionData['timestamp']) {
        await clearSession();
        return null;
      }

      // Validate that the stored role matches the database role
      final dbRole = _getRoleFromDatabase(dbUser);
      if (dbRole.toString() != roleStr) {
        await clearSession();
        return null;
      }
      
      return sessionData;
    } catch (e) {
      log('SessionService: خطأ في قراءة الجلسة: $e');
      await clearSession();
      return null;
    }
  }
  
  Future<UserRole?> getCurrentRole() async {
    try {
      await initialize();
      final roleStr = await _readSecure(_roleKey);
      
      if (roleStr != null) {
        final session = await getCurrentSession();
        if (session != null && session['role'] == roleStr) {
          return UserRole.values.firstWhere(
            (r) => r.toString() == roleStr,
            orElse: () => UserRole.student,
          );
        }
        await clearSession();
      }
      return null;
    } catch (e) {
      log('SessionService: خطأ في قراءة الدور: $e');
      return null;
    }
  }

  Future<Map<String, bool>> getCurrentPermissions() async {
    try {
      await initialize();
      final permissionsStr = await _readSecure(_permissionsKey);
      
      if (permissionsStr != null) {
        final session = await getCurrentSession();
        if (session != null) {
          return Map<String, bool>.from(
            json.decode(permissionsStr) as Map<String, dynamic>
          );
        }
      }
      return {};
    } catch (e) {
      log('SessionService: خطأ في قراءة الصلاحيات: $e');
      return {};
    }
  }
  
  Future<void> clearSession() async {
    try {
      await initialize();
      
      final sessionStr = await _readSecure(_sessionKey);
      if (sessionStr != null) {
        final sessionData = json.decode(sessionStr) as Map<String, dynamic>;
        final userId = sessionData['userId'] as String;
        
        // Clear session in database
        await _supabaseClient
            .from('students')
            .update({
              'session_key': null,
              'last_session': null,
            })
            .eq('id', userId);
      }
      
      // Clear secure storage
      await _deleteAllSecure();
      
      log('SessionService: تم مسح الجلسة');
    } catch (e) {
      log('SessionService: خطأ في مسح الجلسة: $e');
      // Still try to clear storage
      await _deleteAllSecure();
    }
  }
  
  Future<bool> validateSession(String userId) async {
    try {
      await initialize();
      
      final sessionStr = await _readSecure(_sessionKey);
      if (sessionStr == null) return false;
      
      final sessionData = json.decode(sessionStr) as Map<String, dynamic>;
      if (sessionData['userId'] != userId) {
        await clearSession();
        return false;
      }
      
      final dbUser = await _supabaseClient
          .from('students')
          .select('session_key, is_admin, is_teacher')
          .eq('id', userId)
          .single();
          
      if (dbUser == null || dbUser['session_key'] != sessionData['timestamp']) {
        await clearSession();
        return false;
      }

      // Validate that the stored role matches the database role
      final dbRole = _getRoleFromDatabase(dbUser);
      if (dbRole.toString() != sessionData['role']) {
        await clearSession();
        return false;
      }
      
      return true;
    } catch (e) {
      log('SessionService: خطأ في التحقق من الجلسة: $e');
      await clearSession();
      return false;
    }
  }

  UserRole _getRoleFromDatabase(Map<String, dynamic> dbUser) {
    final isAdmin = dbUser['is_admin'] as bool? ?? false;
    final isTeacher = dbUser['is_teacher'] as bool? ?? false;
    
    if (isAdmin) return UserRole.admin;
    if (isTeacher) return UserRole.teacher;
    return UserRole.student;
  }

  Map<String, bool> _getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return {
          'is_admin': true,
          'is_teacher': true,
          'can_mark_attendance': true,
          'can_evaluate_students': true,
          'can_manage_circles': true,
          'can_manage_users': true,
        };
      case UserRole.teacher:
        return {
          'is_admin': false,
          'is_teacher': true,
          'can_mark_attendance': true,
          'can_evaluate_students': true,
          'can_manage_circles': true,
          'can_manage_users': false,
        };
      case UserRole.student:
        return {
          'is_admin': false,
          'is_teacher': false,
          'can_mark_attendance': false,
          'can_evaluate_students': false,
          'can_manage_circles': false,
          'can_manage_users': false,
        };
    }
  }
} 