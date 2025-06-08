import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/user_role.dart';
import 'session_service.dart';

class PermissionsManager {
  static final PermissionsManager _instance = PermissionsManager._internal();
  factory PermissionsManager() => _instance;
  PermissionsManager._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _useSharedPrefs = false;

  final _sessionService = SessionService();

  static const String _permissionsKey = 'user_permissions';
  static const String _roleKey = 'user_role';

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Try to initialize secure storage
      try {
        await _secureStorage.deleteAll();
        _useSharedPrefs = false;
      } catch (e) {
        // If secure storage fails, fall back to shared preferences
        log('PermissionsManager: التخزين الآمن غير متاح، استخدام SharedPreferences كبديل');
        _prefs = await SharedPreferences.getInstance();
        await _prefs.clear();
        _useSharedPrefs = true;
      }
      
      _isInitialized = true;
      log('PermissionsManager: تم التهيئة بنجاح');
    } catch (e) {
      log('PermissionsManager: خطأ في التهيئة: $e');
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

  Future<void> setPermissions(String userId, UserRole role) async {
    try {
      await initialize();

      final permissions = _getPermissionsForRole(role);
      
      // Store permissions and role
      await Future.wait([
        _writeSecure(_permissionsKey, json.encode(permissions)),
        _writeSecure(_roleKey, role.toString()),
      ]);

      // Create session with new role
      await _sessionService.createSession(userId, role);
      
      log('PermissionsManager: تم تحديث الصلاحيات للمستخدم: $userId مع الدور: ${role.toString()}');
    } catch (e) {
      log('PermissionsManager: خطأ في تحديث الصلاحيات: $e');
      await clearPermissions();
      rethrow;
    }
  }

  Future<Map<String, bool>> getPermissions() async {
    try {
      await initialize();
      
      final permissionsStr = await _readSecure(_permissionsKey);
      if (permissionsStr == null) return {};

      final session = await _sessionService.getCurrentSession();
      if (session == null) {
        await clearPermissions();
        return {};
      }

      return Map<String, bool>.from(
        json.decode(permissionsStr) as Map<String, dynamic>
      );
    } catch (e) {
      log('PermissionsManager: خطأ في قراءة الصلاحيات: $e');
      return {};
    }
  }

  Future<UserRole?> getCurrentRole() async {
    try {
      await initialize();
      
      final roleStr = await _readSecure(_roleKey);
      if (roleStr == null) return null;

      final session = await _sessionService.getCurrentSession();
      if (session == null || session['role'] != roleStr) {
        await clearPermissions();
        return null;
      }

      return UserRole.values.firstWhere(
        (r) => r.toString() == roleStr,
        orElse: () => UserRole.student,
      );
    } catch (e) {
      log('PermissionsManager: خطأ في قراءة الدور: $e');
      return null;
    }
  }

  Future<void> clearPermissions() async {
    try {
      await initialize();
      await Future.wait([
        _deleteAllSecure(),
        _sessionService.clearSession(),
      ]);
      log('PermissionsManager: تم مسح الصلاحيات');
    } catch (e) {
      log('PermissionsManager: خطأ في مسح الصلاحيات: $e');
      // Still try to clear storage
      await _deleteAllSecure();
    }
  }

  Future<bool> hasPermission(String permission) async {
    final permissions = await getPermissions();
    return permissions[permission] ?? false;
  }

  Future<bool> validatePermissions(String userId) async {
    try {
      await initialize();
      
      final roleStr = await _readSecure(_roleKey);
      final permissionsStr = await _readSecure(_permissionsKey);
      
      if (roleStr == null || permissionsStr == null) {
        await clearPermissions();
        return false;
      }

      final isSessionValid = await _sessionService.validateSession(userId);
      if (!isSessionValid) {
        await clearPermissions();
        return false;
      }

      return true;
    } catch (e) {
      log('PermissionsManager: خطأ في التحقق من الصلاحيات: $e');
      await clearPermissions();
      return false;
    }
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