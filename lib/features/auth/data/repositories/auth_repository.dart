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

  Future<UserModel> signIn(String email, String password);

  Future<UserModel?> getCurrentUser();

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<void> clearUserData();

  Future<void> sendResetCode(String email);

  Future<void> verifyResetCode(String email, String code);

  Future<void> resetPasswordWithCode(String email, String newPassword);

  Future<bool> isEmailRegistered(String email);

  Future<UserModel> updateProfile({
    required UserModel user,
    File? profileImage,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

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
        'name': name,
        'email': email,
        'phone': phone,
        'age': age,
        'is_admin': false,
        'is_teacher': isTeacher, // إضافة حقل is_teacher إلى البيانات
        'created_at': DateTime.now().toIso8601String(),
        'profile_image_url': profileImageUrl,
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
  Future<UserModel> signIn(String email, String password) async {
    try {
      print('AuthRepository: بدء عملية تسجيل الدخول');
      
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('بيانات الدخول غير صحيحة');
      }

      try {
        // جلب بيانات المستخدم من جدول الطلاب
        final userData = await _supabaseClient
            .from('students')
            .select()
            .eq('id', response.user!.id)
            .single();

        print('AuthRepository: تم تسجيل الدخول وجلب البيانات بنجاح');
        return UserModel.fromJson(userData);
      } catch (dbError) {
        print('AuthRepository: خطأ في جلب بيانات المستخدم: $dbError');
        throw Exception('حدث خطأ في جلب بيانات المستخدم، الرجاء المحاولة مرة أخرى');
      }
    } catch (e) {
      print('AuthRepository: خطأ في تسجيل الدخول: $e');
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else if (e.toString().contains('network')) {
        throw Exception('خطأ في الاتصال بالإنترنت، الرجاء التحقق من اتصالك بالشبكة');
      } else {
        throw Exception('حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى');
      }
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      print('AuthRepository: Verificando usuario actual en Supabase');
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        print('AuthRepository: No hay usuario autenticado en Supabase');
        return null;
      }
      print('AuthRepository: Usuario encontrado en Supabase con ID: ${user.id}');

      try {
        // Obtener datos del usuario desde la tabla de estudiantes
        print('AuthRepository: Consultando datos del usuario en la tabla students');
        final userData = await _supabaseClient
            .from('students')
            .select()
            .eq('id', user.id)
            .single();

        print('AuthRepository: Datos del usuario obtenidos correctamente');
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
    try {
      print('AuthRepository: بدء عملية تسجيل الخروج');
      await _supabaseClient.auth.signOut();
      print('AuthRepository: تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('AuthRepository: خطأ في تسجيل الخروج: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      print('AuthRepository: بدء عملية مسح بيانات المستخدم');
      // مسح أي بيانات مخزنة محلياً إذا كان هناك
      // يمكنك إضافة المزيد من عمليات المسح هنا إذا كنت تخزن بيانات إضافية
      print('AuthRepository: تم مسح بيانات المستخدم بنجاح');
    } catch (e) {
      print('AuthRepository: خطأ في مسح بيانات المستخدم: $e');
      throw Exception('Failed to clear user data: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: null,
      );
    } catch (e) {
      if (e is AuthException) {
        String message = e.message;
        if (e.message.contains("Email not found")) {
          message = "البريد الإلكتروني غير مسجل";
        } else if (e.message.contains("Too many requests")) {
          message = "محاولات كثيرة، يرجى المحاولة بعد قليل";
        }
        throw Exception(message);
      }
      throw Exception('حدث خطأ في إعادة تعيين كلمة المرور');
    }
  }

  @override
  Future<void> sendResetCode(String email) async {
    try {
      await _supabaseClient.auth.signInWithOtp(
        email: email,
        data: {'template': 'reset-password-ar'},
      );
    } catch (e) {
      if (e is AuthException) {
        String message = e.message;
        if (e.message.contains("For security purposes")) {
          final RegExp regex = RegExp(r'after (\d+) seconds');
          final match = regex.firstMatch(e.message);
          final seconds = match?.group(1) ?? "14";
          message = "لأسباب أمنية، يرجى الانتظار $seconds ثانية قبل إعادة طلب الكود";
        } else if (e.message.contains("Email not found")) {
          message = "البريد الإلكتروني غير مسجل";
        } else if (e.message.contains("Too many requests")) {
          message = "محاولات كثيرة، يرجى المحاولة بعد قليل";
        }
        throw Exception(message);
      }
      throw Exception('حدث خطأ في إرسال كود التحقق');
    }
  }

  @override
  Future<void> verifyResetCode(String email, String code) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.magiclink,
      );
    } catch (e) {
      if (e is AuthException) {
        String message = e.message;
        if (e.message.contains("Invalid otp")) {
          message = "كود التحقق غير صحيح";
        } else if (e.message.contains("Token has expired")) {
          message = "كود التحقق غير صحيح";
        } else if (e.message.contains("Too many attempts")) {
          message = "محاولات كثيرة، يرجى طلب كود جديد";
        }
        throw Exception(message);
      }
      throw Exception('كود التحقق غير صحيح');
    }
  }

  @override
  Future<void> resetPasswordWithCode(String email, String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      if (e is AuthException) {
        String message = e.message;
        if (e.message.contains("New password should be different")) {
          message = "كلمة المرور الجديدة يجب أن تكون مختلفة عن كلمة المرور القديمة";
        } else if (e.message.contains("Password should be at least 6 characters")) {
          message = "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
        } else if (e.message.contains("Token has expired")) {
          message = "انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول";
        }
        throw Exception(message);
      }
      throw Exception('حدث خطأ في تحديث كلمة المرور');
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('id')
          .eq('email', email)
          .single();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> updateProfile({
    required UserModel user,
    File? profileImage,
  }) async {
    try {
      String? imageUrl = user.profileImageUrl;

      if (profileImage != null) {
        final fileExt = profileImage.path.split('.').last;
        final fileName = '${user.id}.$fileExt';
        final filePath = 'profile_images/$fileName';

        // حذف الصورة القديمة إذا كانت موجودة
        try {
          final List<FileObject> files = await _supabaseClient.storage
              .from('students')
              .list(path: 'profile_images');

          // البحث عن أي ملف يبدأ باسم المستخدم (لحذف الملفات بأي امتداد)
          final existingFiles = files.where(
            (file) => file.name.startsWith(user.id + '.'),
          );

          if (existingFiles.isNotEmpty) {
            await Future.wait(
              existingFiles.map((file) => _supabaseClient.storage
                  .from('students')
                  .remove(['profile_images/${file.name}'])),
            );
          }
        } catch (e) {
          // تجاهل أخطاء الحذف - قد لا تكون هناك صورة قديمة
          print('Warning: Failed to delete old profile image: $e');
        }

        // رفع الصورة الجديدة
        await _supabaseClient.storage
            .from('students')
            .upload('profile_images/$fileName', profileImage);

        final imageUrlResponse = _supabaseClient.storage
            .from('students')
            .getPublicUrl('profile_images/$fileName');

        imageUrl = imageUrlResponse;
      }

      // تحديث بيانات المستخدم في الجدول
      final Map<String, dynamic> updateData = {
        'name': user.name,
        'phone': user.phone,
        'age': user.age,
        'profile_image_url': imageUrl,
      };

      await _supabaseClient
          .from('students')
          .update(updateData)
          .eq('id', user.id);

      // جلب البيانات المحدثة
      final updatedData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(updatedData);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير موجود');

      // التحقق من كلمة المرور الحالية
      try {
        print('AuthRepository: محاولة التحقق من كلمة المرور الحالية');
        await _supabaseClient.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
        print('AuthRepository: كلمة المرور الحالية صحيحة');
      } catch (e) {
        print('AuthRepository: خطأ في التحقق من كلمة المرور الحالية');
        print('AuthRepository: نوع الخطأ: ${e.runtimeType}');
        print('AuthRepository: رسالة الخطأ: $e');
        throw Exception('كلمة المرور الحالية غير صحيحة');
      }

      // تحديث كلمة المرور
      print('AuthRepository: محاولة تحديث كلمة المرور');
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      print('AuthRepository: تم تحديث كلمة المرور بنجاح');
    } catch (e) {
      print('AuthRepository: خطأ في تغيير كلمة المرور');
      print('AuthRepository: نوع الخطأ: ${e.runtimeType}');
      print('AuthRepository: رسالة الخطأ: $e');
      
      if (e is AuthException) {
        String message = e.message;
        if (message.contains("New password should be different")) {
          message = "كلمة المرور الجديدة يجب أن تكون مختلفة عن كلمة المرور القديمة";
        } else if (message.contains("Password should be at least 6 characters")) {
          message = "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
        } else if (message.contains("Token has expired")) {
          message = "انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول";
        }
        throw Exception(message);
      }
      rethrow;
    }
  }
}
