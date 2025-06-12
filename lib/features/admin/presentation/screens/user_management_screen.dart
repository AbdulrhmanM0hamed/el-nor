import 'package:beat_elslam/features/admin/presentation/widgets/user_management/user_list_item.dart';
import 'package:beat_elslam/features/admin/presentation/widgets/user_management/user_role_dialog.dart';
import 'package:beat_elslam/features/admin/presentation/widgets/user_management/user_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/student_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';


class UserManagementScreen extends StatefulWidget {
  static const String routeName = '/user-management';
  
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

// Wrapper to provide the AdminCubit
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
  bool _hasShownInitialSnackbar = false;
  bool _showRecentUsers = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      List<StudentModel> baseList = _showRecentUsers ? _getRecentUsers(_allUsers) : _allUsers;
      if (query.isEmpty) {
        _filteredUsers = baseList;
      } else {
        _filteredUsers = baseList.where((user) {
          final name = user.name.toLowerCase();
          final email = user.email.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();
      }
    });
  }

  List<StudentModel> _getRecentUsers(List<StudentModel> users) {
    final now = DateTime.now();
    return users.where((user) {
      final createdAt = user.createdAt;
      return createdAt.isAfter(now.subtract(const Duration(hours: 72)));
    }).toList();
  }

  void _showEditRoleDialog(BuildContext context, StudentModel user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => UserRoleDialog(
        user: user,
        onRoleChanged: (isAdmin, isTeacher) async {
          try {
            await context.read<AdminCubit>().updateUserRole(
              userId: user.id,
              isAdmin: isAdmin,
              isTeacher: isTeacher,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حدث خطأ أثناء تحديث الدور: ${e.toString()}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
      ),
    );
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
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showRecentUsers = !_showRecentUsers;
                  _filterUsers(_searchController.text);
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: _showRecentUsers ? Colors.green : Colors.white,
                foregroundColor: _showRecentUsers ? Colors.white : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side:const BorderSide(color: Colors.green),
                ),
              ),
              child: const Text('المنضم حديثاً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          UserSearchBar(
            controller: _searchController,
            onChanged: _filterUsers,
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
                  
                  // Only show success message if it's not the initial load
                  if (_hasShownInitialSnackbar) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث دور المستخدم بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    _hasShownInitialSnackbar = true;
                  }
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
                  return _buildErrorState(state.message);
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
        return UserListItem(
          user: user,
          onEditRole: () => _showEditRoleDialog(context, user),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
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
            message,
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
} 