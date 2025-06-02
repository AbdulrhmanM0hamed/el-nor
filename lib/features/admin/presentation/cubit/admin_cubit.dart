import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../memorization_circles/data/models/memorization_circle_model.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final SupabaseClient _supabaseClient;
  final _uuid = const Uuid();

  AdminCubit(this._supabaseClient) : super(AdminInitial());

  Future<void> loadAllUsers() async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final isAdmin = userData['is_admin'] ?? false;
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية للوصول إلى هذه الصفحة'));
        return;
      }

      // Obtener todos los usuarios
      final data = await _supabaseClient.from('students').select();
      final users = data.map((user) => UserModel.fromJson(user)).toList();

      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل المستخدمين: ${e.toString()}'));
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required bool isAdmin,
    required bool isTeacher,
  }) async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final currentUserIsAdmin = userData['is_admin'] ?? false;
      if (!currentUserIsAdmin) {
        emit(const AdminError('ليس لديك صلاحية لتعديل أدوار المستخدمين'));
        return;
      }

      // Actualizar el rol del usuario
      await _supabaseClient.from('students').update({
        'is_admin': isAdmin,
        'is_teacher': isTeacher,
      }).eq('id', userId);

      emit(AdminUserRoleUpdated(
        userId: userId,
        isAdmin: isAdmin,
        isTeacher: isTeacher,
      ));

      // Recargar la lista de usuarios para reflejar los cambios
      await loadAllUsers();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحديث دور المستخدم: ${e.toString()}'));
    }
  }
  
  // Métodos para gestión de círculos de memorización
  
  Future<void> loadAllCircles() async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final isAdmin = userData['is_admin'] ?? false;
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية للوصول إلى هذه الصفحة'));
        return;
      }

      // Obtener todos los círculos de memorización
      final data = await _supabaseClient.from('memorization_circles').select('''
        *,
        teacher:teacher_id(name)
      ''');
      
      final circles = data.map((circle) {
        // Extraer el nombre del maestro si existe
        String? teacherName;
        if (circle['teacher'] != null) {
          teacherName = circle['teacher']['name'];
        }
        
        return MemorizationCircle(
          id: circle['id'],
          name: circle['name'],
          description: circle['description'] ?? '',
          teacherId: circle['teacher_id'],
          teacherName: teacherName,
          studentsCount: circle['students_count'],
          createdAt: DateTime.parse(circle['created_at']),
        );
      }).toList();

      emit(AdminCirclesLoaded(circles));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل حلقات الحفظ: ${e.toString()}'));
    }
  }

  Future<void> createCircle({
    required String name,
    required String description,
  }) async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final isAdmin = userData['is_admin'] ?? false;
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية لإنشاء حلقات حفظ جديدة'));
        return;
      }

      // Crear un nuevo círculo de memorización
      final circleId = _uuid.v4();
      final now = DateTime.now();
      
      final circleData = {
        'id': circleId,
        'name': name,
        'description': description,
        'created_at': now.toIso8601String(),
        'created_by': currentUser.id,
      };

      await _supabaseClient.from('memorization_circles').insert(circleData);

      final newCircle = MemorizationCircle(
        id: circleId,
        name: name,
        description: description,
        createdAt: now,
      );

      emit(AdminCircleCreated(newCircle));

      // Recargar la lista de círculos para reflejar los cambios
      await loadAllCircles();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء إنشاء حلقة الحفظ: ${e.toString()}'));
    }
  }

  Future<void> updateCircle({
    required String circleId,
    required String name,
    required String description,
  }) async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final isAdmin = userData['is_admin'] ?? false;
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية لتعديل حلقات الحفظ'));
        return;
      }

      // Actualizar el círculo de memorización
      await _supabaseClient.from('memorization_circles').update({
        'name': name,
        'description': description,
      }).eq('id', circleId);

      // Obtener los datos actualizados del círculo
      final updatedData = await _supabaseClient
          .from('memorization_circles')
          .select('''
            *,
            teacher:teacher_id(name)
          ''')
          .eq('id', circleId)
          .single();

      String? teacherName;
      if (updatedData['teacher'] != null) {
        teacherName = updatedData['teacher']['name'];
      }

      final updatedCircle = MemorizationCircle(
        id: updatedData['id'],
        name: updatedData['name'],
        description: updatedData['description'] ?? '',
        teacherId: updatedData['teacher_id'],
        teacherName: teacherName,
        studentsCount: updatedData['students_count'],
        createdAt: DateTime.parse(updatedData['created_at']),
      );

      emit(AdminCircleUpdated(updatedCircle));

      // Recargar la lista de círculos para reflejar los cambios
      await loadAllCircles();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحديث حلقة الحفظ: ${e.toString()}'));
    }
  }

  Future<void> deleteCircle(String circleId) async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final isAdmin = userData['is_admin'] ?? false;
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية لحذف حلقات الحفظ'));
        return;
      }

      // Eliminar el círculo de memorización
      await _supabaseClient.from('memorization_circles').delete().eq('id', circleId);

      emit(AdminCircleDeleted(circleId));

      // Recargar la lista de círculos para reflejar los cambios
      await loadAllCircles();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء حذف حلقة الحفظ: ${e.toString()}'));
    }
  }

  Future<void> assignTeacherToCircle({
    required String circleId,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final isAdmin = userData['is_admin'] ?? false;
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية لتعيين معلمين للحلقات'));
        return;
      }

      // Asignar el maestro al círculo de memorización
      await _supabaseClient.from('memorization_circles').update({
        'teacher_id': teacherId,
      }).eq('id', circleId);

      emit(AdminTeacherAssigned(
        circleId: circleId,
        teacherId: teacherId,
        teacherName: teacherName,
      ));

      // Recargar la lista de círculos para reflejar los cambios
      await loadAllCircles();
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تعيين المعلم للحلقة: ${e.toString()}'));
    }
  }
  
  // Método para cargar solo los usuarios que son maestros
  Future<void> loadTeachers() async {
    try {
      emit(AdminLoading());

      // Verificar si el usuario actual es administrador
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(const AdminError('لم يتم تسجيل الدخول'));
        return;
      }

      // Obtener información del usuario actual
      final userData = await _supabaseClient
          .from('students')
          .select()
          .eq('id', currentUser.id)
          .single();

      final isAdmin = userData['is_admin'] ?? false;
      if (!isAdmin) {
        emit(const AdminError('ليس لديك صلاحية للوصول إلى هذه الصفحة'));
        return;
      }

      // Obtener todos los usuarios que son maestros
      final data = await _supabaseClient
          .from('students')
          .select()
          .eq('is_teacher', true);
      
      final teachers = data.map((user) => UserModel.fromJson(user)).toList();

      emit(AdminTeachersLoaded(teachers));
    } catch (e) {
      emit(AdminError('حدث خطأ أثناء تحميل المعلمين: ${e.toString()}'));
    }
  }
}
