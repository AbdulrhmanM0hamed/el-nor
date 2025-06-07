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
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
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
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
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
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                } else if (state is AdminUsersLoaded) {
                  setState(() {
                    _allUsers = state.users;
                    _filteredUsers = state.users;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم تحديث دور المستخدم بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
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
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AdminCubit>().loadAllUsers();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
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
                
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
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
              color: Theme.of(context).disabledColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا يوجد مستخدمين مطابقين للبحث',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
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
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4.w,
                    color: _getRoleColor(user),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              backgroundImage: user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              child: user.profileImageUrl == null
                                  ? Text(
                                      _getInitial(user.name),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24.sp,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: 16.w),
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
                                          color: Theme.of(context).textTheme.titleLarge?.color,
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _showEditRoleDialog(context, user),
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: Container(
                                          padding: EdgeInsets.all(8.r),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            color: Theme.of(context).primaryColor,
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
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
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
          backgroundColor: Theme.of(context).dialogBackgroundColor,
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
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                if (isUpdating)
                  Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                else
                  Column(
                    children: [
                      _buildRoleOption(
                        context,
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
                      _buildRoleOption(
                        context,
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
                      _buildRoleOption(
                        context,
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
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isUpdating ? null : () async {
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
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          }
                        } else {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
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

  Widget _buildRoleOption(
    BuildContext context, {
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
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
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
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Theme.of(context).primaryColor,
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
