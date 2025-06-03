import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/data/models/user_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/user_role_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  static const String routeName = '/user-management';
  
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

// Wrapper para proporcionar el AdminCubit
class UserManagementScreenWrapper extends StatelessWidget {
  static const String routeName = '/user-management';

  const UserManagementScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCubit>(
      create: (context) => sl<AdminCubit>(),
      child: const UserManagementScreen(),
    );
  }
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar la lista de usuarios al iniciar la pantalla
    context.read<AdminCubit>().loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة المستخدمين',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.logoTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AdminUserRoleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث دور المستخدم بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.logoTeal,
              ),
            );
          } else if (state is AdminUsersLoaded) {
            return _buildUsersList(state.users);
          } else if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminCubit>().loadAllUsers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoTeal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          
          // Si no hay un estado específico, cargar los usuarios
          if (state is AdminInitial) {
            context.read<AdminCubit>().loadAllUsers();
          }
          
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.logoTeal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersList(List<UserModel> users) {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.r),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.r),
            leading: CircleAvatar(
              backgroundColor: AppColors.logoTeal,
              child: Text(
                _getInitial(user.name),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            title: Text(
              user.name ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(user.email),
                SizedBox(height: 4.h),
                Text(
                  'الدور: ${_getUserRoleText(user)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    if (user.isAdmin)
                      Chip(
                        label: const Text('مشرف'),
                        backgroundColor: Colors.red[100],
                        labelStyle: TextStyle(
                          color: Colors.red[800],
                          fontSize: 12.sp,
                        ),
                      ),
                    if (user.isTeacher)
                      Chip(
                        label: const Text('معلم'),
                        backgroundColor: Colors.blue[100],
                        labelStyle: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 12.sp,
                        ),
                      ),
                    if (!user.isAdmin && !user.isTeacher)
                      Chip(
                        label: const Text('طالب'),
                        backgroundColor: Colors.green[100],
                        labelStyle: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              color: AppColors.logoTeal,
              onPressed: () {
                _showEditRoleDialog(context, user);
              },
            ),
          ),
        );
      },
    );
  }

  void _showEditRoleDialog(BuildContext context, UserModel user) {
    final adminCubit = context.read<AdminCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => UserRoleDialog(
        user: user,
        onRoleChanged: (isAdmin, isTeacher) async {
          // Store original role status for logging
          final wasAdmin = user.isAdmin;
          final wasTeacher = user.isTeacher;
          
          final roleChangeText = _getRoleChangeText(wasAdmin, wasTeacher, isAdmin, isTeacher);
          
          print('Role change requested for ${user.name}');
          print('Role change: $roleChangeText');
          print('Original role: Admin=${wasAdmin}, Teacher=${wasTeacher}');
          print('New role: Admin=${isAdmin}, Teacher=${isTeacher}');
          
          // Update user role in database
          adminCubit.updateUserRole(
            userId: user.id,
            isAdmin: isAdmin,
            isTeacher: isTeacher,
          );
          
          // Handle teacher record management
          if (isTeacher && !user.isTeacher) {
            print('Adding teacher record for ${user.name}');
            adminCubit.addTeacher(user);
          } else if (!isTeacher && user.isTeacher) {
            print('Removing teacher record for ${user.name}');
            adminCubit.removeTeacher(user.id);
          }
          
          // Show success message with role change details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تغيير دور ${user.name} $roleChangeText'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }
  
  String _getInitial(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }
    return name[0].toUpperCase();
  }
  
  // Helper method to get the text representation of a user's role
  String _getUserRoleText(UserModel user) {
    if (user.isAdmin) {
      return 'مشرف';
    } else if (user.isTeacher) {
      return 'معلم';
    } else {
      return 'طالب';
    }
  }
  
  // Helper method to get the text representation of a role based on isAdmin and isTeacher flags
  String _getRoleText(bool isAdmin, bool isTeacher) {
    if (isAdmin) {
      return 'مشرف';
    } else if (isTeacher) {
      return 'معلم';
    } else {
      return 'طالب';
    }
  }
  
  // Helper method to describe the role change
  String _getRoleChangeText(bool oldIsAdmin, bool oldIsTeacher, bool newIsAdmin, bool newIsTeacher) {
    final oldRole = _getRoleText(oldIsAdmin, oldIsTeacher);
    final newRole = _getRoleText(newIsAdmin, newIsTeacher);
    return 'من $oldRole إلى $newRole';
  }
}
