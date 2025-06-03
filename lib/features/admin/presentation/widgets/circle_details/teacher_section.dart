// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../../../core/utils/theme/app_colors.dart';
// import '../../../data/models/memorization_circle_model.dart';
// import '../../../data/models/teacher_model.dart';
// import '../shared/profile_image.dart';

// class TeacherSection extends StatelessWidget {
//   final MemorizationCircleModel circle;
//   final List<TeacherModel> teachers;
//   final Function(String, String) onAssignTeacher;

//   const TeacherSection({
//     Key? key,
//     required this.circle,
//     required this.teachers,
//     required this.onAssignTeacher,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Create a default teacher model with circle data as fallback
//     TeacherModel teacher = TeacherModel(
//       id: circle.teacherId ?? '',
//       name: circle.teacherName ?? 'لم يتم تعيين معلم بعد',
//       email: '',
//       phone: '',
//       profileImageUrl: '',
//       specialization: '',
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );

//     // Debug prints to help diagnose issues
//     print('TeacherSection - Circle teacherId: ${circle.teacherId}');
//     print('TeacherSection - Circle teacherName: ${circle.teacherName}');
//     print('TeacherSection - Available teachers: ${teachers.length}');
    
//     // List teacher IDs for debugging
//     if (teachers.isNotEmpty) {
//       print('TeacherSection - Teacher IDs in list: ${teachers.map((t) => t.id).join(', ')}');
//     }

//     // Try to find the assigned teacher in the teachers list
//     if (circle.teacherId != null && circle.teacherId!.isNotEmpty) {
//       try {
//         final foundTeacher = teachers.firstWhere(
//           (t) => t.id == circle.teacherId,
//           orElse: () => teacher,
//         );
//         teacher = foundTeacher;
//         final hasProfileImage = teacher.profileImageUrl != null && 
//                                (teacher.profileImageUrl?.isNotEmpty ?? false);
//         print('TeacherSection - Found teacher: ${teacher.name}, ID: ${teacher.id}, Has profile image: $hasProfileImage');
//       } catch (e) {
//         print('TeacherSection - Error finding teacher: $e');
//       }
//     }
    
//     print('Selected teacher name: ${teacher.name}');

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16.r),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     if (circle.teacherId != null && circle.teacherId!.isNotEmpty)
//                       ProfileImage(
//                         imageUrl: teacher.profileImageUrl,
//                         name: teacher.name,
//                         color: AppColors.logoTeal,
//                         size: 30,
//                       ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'المعلم المسؤول',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.logoTeal,
//                       ),
//                     ),
//                   ],
//                 ),
//                 TextButton.icon(
//                   onPressed: () => _showAssignTeacherDialog(context),
//                   icon: Icon(
//                     Icons.edit,
//                     size: 16.sp,
//                     color: AppColors.logoTeal,
//                   ),
//                   label: Text(
//                     'تغيير',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: AppColors.logoTeal,
//                     ),
//                   ),
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 4.h,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Divider(height: 16.h),
//             if (circle.teacherId == null || circle.teacherId!.isEmpty)
//               _buildNoTeacherAssigned(context)
//             else
//               _buildTeacherCard(teacher),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoTeacherAssigned(BuildContext context) {
//     return InkWell(
//       onTap: () => _showAssignTeacherDialog(context),
//       borderRadius: BorderRadius.circular(8.r),
//       child: Container(
//         padding: EdgeInsets.all(16.r),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8.r),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.person_add_alt_1,
//               color: AppColors.logoTeal,
//               size: 24.sp,
//             ),
//             SizedBox(width: 16.w),
//             Expanded(
//               child: Text(
//                 'لم يتم تعيين معلم لهذه الحلقة بعد. اضغط هنا لتعيين معلم.',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTeacherCard(TeacherModel teacher) {
//     // Debug print for profile image URL
//     print('TeacherCard - Profile image URL: ${teacher.profileImageUrl}');
    
//     return Container(
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         border: Border.all(color: Colors.grey.shade200),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ProfileImage(
//             imageUrl: teacher.profileImageUrl,
//             name: teacher.name,
//             color: AppColors.logoTeal,
//             size: 70,
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   teacher.name,
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 if (teacher.email != null && teacher.email!.isNotEmpty) ...[
//                   SizedBox(height: 6.h),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.email_outlined,
//                         size: 14.sp,
//                         color: Colors.grey.shade600,
//                       ),
//                       SizedBox(width: 4.w),
//                       Expanded(
//                         child: Text(
//                           teacher.email ?? '',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.grey.shade600,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//                 if (teacher.phone != null && teacher.phone!.isNotEmpty) ...[
//                   SizedBox(height: 6.h),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.phone_outlined,
//                         size: 14.sp,
//                         color: Colors.grey.shade600,
//                       ),
//                       SizedBox(width: 4.w),
//                       Text(
//                         teacher.phone ?? '',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//                 if (teacher.specialization != null && teacher.specialization!.isNotEmpty) ...[
//                   SizedBox(height: 6.h),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.school_outlined,
//                         size: 14.sp,
//                         color: Colors.grey.shade600,
//                       ),
//                       SizedBox(width: 4.w),
//                       Expanded(
//                         child: Text(
//                           teacher.specialization ?? '',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.grey.shade600,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAssignTeacherDialog(BuildContext context) {
//     print('Showing assign teacher dialog for circle: ${circle.id}, ${circle.name}');
//     // Call the onAssignTeacher callback to show the dialog from the parent
//     onAssignTeacher(circle.id, circle.name);
//   }
// }
