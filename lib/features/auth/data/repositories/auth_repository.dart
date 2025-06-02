import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required int age,
    File? profileImage,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUser();

  Future<void> signOut();

  Future<void> resetPassword(String email);
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required int age,
    File? profileImage,
    bool isTeacher = false, // إضافة معلمة لتحديد ما إذا كان المستخدم معلمًا
  }) async {
    try {
      // التسجيل باستخدام Supabase Auth
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('حدث خطأ أثناء إنشاء الحساب');
      }

      String? profileImageUrl;

      // إذا كانت هناك صورة شخصية، قم برفعها إلى Supabase Storage
      if (profileImage != null) {
        try {
          final String path = 'profile_images/${response.user!.id}';
          await _supabaseClient.storage.from('students').upload(
                path,
                profileImage,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
              );

          // الحصول على عنوان URL العام للصورة
          profileImageUrl = _supabaseClient.storage
              .from('students')
              .getPublicUrl(path);
        } catch (storageError) {
          print('خطأ في رفع الصورة الشخصية: ${storageError.toString()}');
          // نستمر في إنشاء الحساب حتى لو فشل رفع الصورة
        }
      }

      // إنشاء سجل في جدول الطلاب
      final userData = {
        'id': response.user!.id,
        'email': email,
        'name': name,
        'phone': phone,
        'age': age,
        'profile_image_url': profileImageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'is_admin': false,
        'is_teacher': isTeacher, // إضافة حقل is_teacher إلى البيانات
      };

      try {
        await _supabaseClient.from('students').insert(userData);
        return UserModel.fromJson(userData);
      } catch (dbError) {
        // إذا فشل إدراج البيانات في الجدول، نحاول التعامل مع الخطأ
        if (dbError.toString().contains('infinite recursion')) {
          // مشكلة في سياسات الأمان، نحاول مرة أخرى بطريقة مختلفة
          print('حدث خطأ في سياسات الأمان، محاولة إصلاح...');
          
          // محاولة إدراج البيانات بطريقة مختلفة (باستخدام RPC إذا كان متاحًا)
          try {
            await _supabaseClient.rpc('insert_student', params: userData);
            return UserModel.fromJson(userData);
          } catch (rpcError) {
            throw Exception('فشل في إنشاء بيانات المستخدم: ${rpcError.toString()}');
          }
        } else {
          throw Exception('خطأ في إنشاء سجل المستخدم: ${dbError.toString()}');
        }
      }
    } catch (e) {
      if (e.toString().contains('User already registered')) {
        throw Exception('البريد الإلكتروني مسجل بالفعل، يرجى استخدام بريد إلكتروني آخر');
      } else if (e.toString().contains('Password should be at least')) {
        throw Exception('كلمة المرور يجب أن تكون على الأقل 6 أحرف');
      } else if (e.toString().contains('network')) {
        throw Exception('خطأ في الاتصال بالإنترنت، تأكد من اتصالك بالشبكة وحاول مرة أخرى');
      } else {
        throw Exception('خطأ في التسجيل: ${e.toString()}');
      }
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('بيانات الدخول غير صحيحة');
      }

      try {
        // Obtener datos del usuario desde la tabla de estudiantes
        final userData = await _supabaseClient
            .from('students')
            .select()
            .eq('id', response.user!.id)
            .single();

        return UserModel.fromJson(userData);
      } catch (dbError) {
        // إذا كان هناك خطأ في الوصول إلى البيانات، نحاول إنشاء سجل جديد
        if (dbError.toString().contains('infinite recursion') || 
            dbError.toString().contains('not found')) {
          // إنشاء بيانات المستخدم الافتراضية
          final defaultUserData = {
            'id': response.user!.id,
            'email': email,
            'name': email.split('@')[0],
            'phone': '',
            'age': 0,
            'profile_image_url': null,
            'created_at': DateTime.now().toIso8601String(),
            'is_admin': false,
          };
          
          // محاولة إدراج البيانات
          try {
            await _supabaseClient.from('students').insert(defaultUserData);
            return UserModel.fromJson(defaultUserData);
          } catch (insertError) {
            throw Exception('خطأ في إنشاء بيانات المستخدم: ${insertError.toString()}');
          }
        } else {
          throw Exception('خطأ في الوصول إلى بيانات المستخدم: ${dbError.toString()}');
        }
      }
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('بيانات الدخول غير صحيحة، تأكد من البريد الإلكتروني وكلمة المرور');
      } else if (e.toString().contains('network')) {
        throw Exception('خطأ في الاتصال بالإنترنت، تأكد من اتصالك بالشبكة وحاول مرة أخرى');
      } else {
        throw Exception('خطأ في تسجيل الدخول: ${e.toString()}');
      }
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return null;
      }

      try {
        // Obtener datos del usuario desde la tabla de estudiantes
        final userData = await _supabaseClient
            .from('students')
            .select()
            .eq('id', user.id)
            .single();

        return UserModel.fromJson(userData);
      } catch (dbError) {
        // إذا كان هناك خطأ في الوصول إلى البيانات، نحاول إنشاء سجل جديد
        if (dbError.toString().contains('infinite recursion') || 
            dbError.toString().contains('not found')) {
          // إنشاء بيانات المستخدم الافتراضية
          final defaultUserData = {
            'id': user.id,
            'email': user.email ?? '',
            'name': user.email?.split('@')[0] ?? 'مستخدم',
            'phone': '',
            'age': 0,
            'profile_image_url': null,
            'created_at': DateTime.now().toIso8601String(),
            'is_admin': false,
            'is_teacher': false, // إضافة حقل is_teacher بقيمة افتراضية false (طالب)
          };
          
          // محاولة إدراج البيانات
          try {
            await _supabaseClient.from('students').insert(defaultUserData);
            return UserModel.fromJson(defaultUserData);
          } catch (insertError) {
            print('خطأ في إنشاء بيانات المستخدم: ${insertError.toString()}');
            return null;
          }
        } else {
          print('خطأ في الوصول إلى بيانات المستخدم: ${dbError.toString()}');
          return null;
        }
      }
    } catch (e) {
      print('خطأ في التحقق من المستخدم الحالي: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }
}
