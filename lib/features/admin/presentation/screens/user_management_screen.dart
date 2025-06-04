import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/student_model.dart';
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
  final TextEditingController _searchController = TextEditingController();
  List<StudentModel> _filteredUsers = [];
  List<StudentModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    // Cargar la lista de usuarios al iniciar la pantalla
    context.read<AdminCubit>().loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = user.name?.toLowerCase() ?? '';
          final email = user.email.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();
      }
    });
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'البحث عن مستخدم...',
                prefixIcon: const Icon(Icons.search, color: AppColors.logoTeal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.logoTeal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.logoTeal, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is AdminUsersLoaded) {
                  setState(() {
                    _allUsers = state.users;
                    _filteredUsers = state.users;
                  });
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
                  return _buildUsersList(_filteredUsers);
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
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<StudentModel> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا يوجد مستخدمين مطابقين للبحث',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                // Role indicator strip
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4.w,
                    color: _getRoleColor(user),
                  ),
                ),
                // Main content
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // User image
                          Container(
                            width: 65.r,
                            height: 65.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getRoleColor(user).withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: AppColors.logoTeal.withOpacity(0.1),
                              backgroundImage: user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              child: user.profileImageUrl == null
                                  ? Text(
                                      _getInitial(user.name),
                                      style: TextStyle(
                                        color: AppColors.logoTeal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24.sp,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // User info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name ?? '',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    // Edit button
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _showEditRoleDialog(context, user),
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: Container(
                                          padding: EdgeInsets.all(8.r),
                                          decoration: BoxDecoration(
                                            color: AppColors.logoTeal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.logoTeal,
                                            size: 20.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Role chips
                      Row(
                        children: [
                          _buildRoleChip(
                            text: _getUserRoleText(user),
                            color: _getRoleColor(user),
                            icon: _getRoleIcon(user),
                          ),
                          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            _buildInfoChip(
                              text: user.phoneNumber!,
                              icon: Icons.phone_outlined,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleChip({
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.r,
            color: color,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.r,
            color: color,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(StudentModel user) {
    if (user.isAdmin) {
      return Colors.red;
    } else if (user.isTeacher) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  IconData _getRoleIcon(StudentModel user) {
    if (user.isAdmin) {
      return Icons.admin_panel_settings_outlined;
    } else if (user.isTeacher) {
      return Icons.school_outlined;
    } else {
      return Icons.person_outline;
    }
  }

  void _showEditRoleDialog(BuildContext context, StudentModel user) {
    final adminCubit = context.read<AdminCubit>();
    bool isUpdating = false;
    bool isAdmin = user.isAdmin;
    bool isTeacher = user.isTeacher;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: 320.w,
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'اختر الدور:',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                if (isUpdating)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.logoTeal,
                    ),
                  )
                else
                  Column(
                    children: [
                      // مشرف
                      _buildRoleOption(
                        title: 'مشرف',
                        subtitle: 'صلاحيات كاملة للنظام وإدارة المنصة',
                        icon: Icons.admin_panel_settings,
                        iconColor: Colors.red,
                        isSelected: isAdmin,
                        onTap: () {
                          if (!isUpdating) {
                            setState(() {
                              isAdmin = true;
                              isTeacher = false;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12.h),
                      // معلم
                      _buildRoleOption(
                        title: 'معلم',
                        subtitle: 'يمكنه إدارة الحلقات وتقييم الطلاب',
                        icon: Icons.school,
                        iconColor: Colors.blue,
                        isSelected: isTeacher && !isAdmin,
                        onTap: () {
                          if (!isUpdating) {
                            setState(() {
                              isAdmin = false;
                              isTeacher = true;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12.h),
                      // طالب
                      _buildRoleOption(
                        title: 'طالب',
                        subtitle: 'مستخدم عادي بدون صلاحيات خاصة',
                        icon: Icons.person,
                        iconColor: Colors.green,
                        isSelected: !isAdmin && !isTeacher,
                        onTap: () {
                          if (!isUpdating) {
                            setState(() {
                              isAdmin = false;
                              isTeacher = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: isUpdating ? null : () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isUpdating ? null : () async {
                        // Only update if there's an actual change
                        if (user.isAdmin != isAdmin || user.isTeacher != isTeacher) {
                          setState(() {
                            isUpdating = true;
                          });

                          try {
                            await adminCubit.updateUserRole(
                              userId: user.id,
                              isAdmin: isAdmin,
                              isTeacher: isTeacher,
                            );

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تحديث دور المستخدم بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isUpdating = false;
                            });
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('حدث خطأ أثناء تحديث الدور: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoTeal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'حفظ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.logoTeal : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected ? AppColors.logoTeal.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.logoTeal,
            ),
          ],
        ),
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
  String _getUserRoleText(StudentModel user) {
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
