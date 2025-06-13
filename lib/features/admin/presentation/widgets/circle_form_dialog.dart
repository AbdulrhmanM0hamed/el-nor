import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/student_model.dart';
import '../../data/models/surah_assignment.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/shared/profile_image.dart';

class CircleFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialDescription;
  final DateTime? initialDate;
  final String? initialTeacherId;
  final String? initialTeacherName;
  final List<StudentModel> availableTeachers;
  final List<SurahAssignment>? initialSurahAssignments;
  final List<StudentModel>? availableStudents;
  final List<String>? initialStudentIds;
  final bool? initialIsExam;
  final String? initialLearningPlanUrl;
  final Function(
      String name,
      String description,
      DateTime startDate,
      String? teacherId,
      String? teacherName,
      List<SurahAssignment> surahAssignments,
      List<String> studentIds,
      bool isExam,
      String? learningPlanUrl) onSave;

  const CircleFormDialog({
    Key? key,
    required this.title,
    this.initialName,
    this.initialDescription,
    this.initialDate,
    this.initialTeacherId,
    this.initialTeacherName,
    required this.availableTeachers,
    this.initialSurahAssignments,
    this.availableStudents,
    this.initialStudentIds,
    this.initialIsExam,
    this.initialLearningPlanUrl = '',
    required this.onSave,
  }) : super(key: key);

  @override
  State<CircleFormDialog> createState() => _CircleFormDialogState();
}

class _CircleFormDialogState extends State<CircleFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String? _selectedTeacherId;
  String? _selectedTeacherName;
  bool _isExam = false;
  final List<SurahAssignment> _selectedSurahs = [];
  final List<String> _selectedStudentIds = [];
  String? _learningPlanUrl;

  // Controladores para el diálogo de asignación de suras
  final TextEditingController _surahNameController = TextEditingController();
  final TextEditingController _startVerseController = TextEditingController();
  final TextEditingController _endVerseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Controlador de pestañas
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de pestañas
    _tabController = TabController(length: 4, vsync: this);

    // Inicializar controladores de texto
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
    _selectedDate = widget.initialDate ?? DateTime.now();
    _isExam = widget.initialIsExam ?? false;

    // Inicializar suras si existen
    if (widget.initialSurahAssignments != null) {
      _selectedSurahs.addAll(widget.initialSurahAssignments!);
    }

    // Inicializar estudiantes si existen
    if (widget.initialStudentIds != null) {
      _selectedStudentIds.addAll(widget.initialStudentIds!);
    }

    // Initialize selected teacher from the initial values
    if (widget.initialTeacherId != null &&
        widget.initialTeacherId!.isNotEmpty) {
      _selectedTeacherId = widget.initialTeacherId;
      _selectedTeacherName = widget.initialTeacherName;
    }

    // Initialize learning plan URL
    _learningPlanUrl = widget.initialLearningPlanUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _surahNameController.dispose();
    _startVerseController.dispose();
    _endVerseController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminCubit>(),
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado del diálogo
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.logoTeal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Pestañas de navegación
              TabBar(
                controller: _tabController,
                labelColor: AppColors.logoTeal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.logoTeal,
                tabs: const [
                  Tab(text: 'معلومات أساسية', icon: Icon(Icons.info_outline)),
                  Tab(text: 'المعلم', icon: Icon(Icons.person)),
                  Tab(text: 'السور', icon: Icon(Icons.menu_book)),
                  Tab(text: 'الطلاب', icon: Icon(Icons.people)),
                ],
              ),

              // Contenido de las pestañas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBasicInfoTab(),
                    _buildTeacherTab(),
                    _buildSurahsTab(),
                    _buildStudentsTab(),
                  ],
                ),
              ),

              // Botones de acción
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: _saveCircle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'حفظ',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para guardar el círculo
  Future<void> _selectPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = path.basename(file.path);

        // First delete the old file if it exists
        if (_learningPlanUrl != null) {
          try {
            // Extract filename from old URL
            final oldFileName = _learningPlanUrl!.split('/').last;
            await Supabase.instance.client.storage
                .from('students')
                .remove(['learning_plans/$oldFileName']);
          } catch (e) {
            print('Error deleting old file: $e');
          }
        }

        // Upload to Supabase in the correct bucket
        final uploadResponse = await Supabase.instance.client.storage
            .from('students')
            .upload('learning_plans/$fileName', file);

        // Get the public URL after upload
        final publicUrl = await Supabase.instance.client.storage
            .from('students')
            .getPublicUrl('learning_plans/$fileName');

        // Update the learning plan URL
        setState(() {
          _learningPlanUrl = publicUrl;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع خطة التعلم بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء اختيار الملف: $e')),
      );
      print(e);
    }
  }

  void _saveCircle() {
    // Primero seleccionar la pestaña de información básica para asegurar que el formulario esté en el árbol
    _tabController
        .animateTo(0); // Cambiar a la primera pestaña donde está el formulario

    // Dar tiempo para que se actualice la UI
    Future.delayed(const Duration(milliseconds: 100), () {
      // Verificar si el estado del formulario existe antes de validar
      if (_formKey.currentState!.validate()) {
        widget.onSave(
          _nameController.text,
          _descriptionController.text,
          _selectedDate,
          _selectedTeacherId,
          _selectedTeacherName,
          _selectedSurahs,
          _selectedStudentIds,
          _isExam,
          _learningPlanUrl,
        );
        Navigator.pop(context);
      } else {
        // Si el formulario no es válido o no existe, mostrar un mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى التأكد من صحة البيانات المدخلة')),
        );
      }
    });
  }

  // Pestaña de información básica
  Widget _buildBasicInfoTab() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم الحلقة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                prefixIcon: const Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال اسم الحلقة';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'وصف الحلقة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال وصف الحلقة';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.logoTeal,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.logoTeal),
                    SizedBox(width: 8.w),
                    Text(
                      'تاريخ البدء: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.quiz, color: AppColors.logoTeal),
                      SizedBox(width: 8.w),
                      Text(
                        'حلقة اختبار',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isExam,
                    onChanged: (value) {
                      setState(() {
                        _isExam = value;
                      });
                    },
                    activeColor: AppColors.logoTeal,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // PDF Learning Plan Section
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description, color: AppColors.logoTeal),
                      SizedBox(width: 8.w),
                      Text(
                        'خطة التعلم',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (_learningPlanUrl != null)
                    Text(
                      path.basename(_learningPlanUrl!),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue,
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectPdfFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('اختيار ملف PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.logoTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pestaña de selección de maestro
  Widget _buildTeacherTab() {
    return BlocProvider(
      create: (context) => sl<AdminCubit>()..loadTeachers(),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر المعلم',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: widget.availableTeachers.isEmpty
                  ? const Center(child: Text('لا يوجد معلمين متاحين'))
                  : BlocBuilder<AdminCubit, AdminState>(
                      builder: (context, state) {
                        if (state is AdminTeachersLoaded) {
                          return ListView.builder(
                            itemCount: state.teachers.length,
                            itemBuilder: (context, index) {
                              final teacher = state.teachers[index];
                              final isSelected =
                                  _selectedTeacherId == teacher.id;
                              return _buildTeacherCard(teacher, isSelected);
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(StudentModel teacher, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: isSelected ? AppColors.logoTeal : Colors.transparent,
          width: 2,
        ),
      ),
      color: isSelected ? AppColors.logoTeal.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTeacherId = teacher.id;
            _selectedTeacherName = teacher.name;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              ProfileImage(
                color: Colors.white,
                imageUrl: teacher.profileImageUrl,
                name: teacher.name,
                size: 48.r,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.logoTeal : null,
                      ),
                    ),
                    if (teacher.email.isNotEmpty)
                      Text(
                        teacher.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.logoTeal,
                  size: 24.r,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Pestaña de asignación de suras
  Widget _buildSurahsTab() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السور المحددة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.logoTeal,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSurahDialog,
                icon: Icon(Icons.add),
                label: Text('إضافة سورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoTeal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _selectedSurahs.isEmpty
                ? Center(
                    child: Text(
                      'لم يتم تحديد أي سور بعد',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = _selectedSurahs[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          title: Text(
                            surah.surahName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          subtitle: Text(
                            'الآيات: ${surah.startVerse} - ${surah.endVerse}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedSurahs.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Pestaña de selección de estudiantes
  Widget _buildStudentsTab() {
    return BlocProvider(
      create: (context) => sl<AdminCubit>()..loadStudents(),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // خطة التعلم
            if (_learningPlanUrl != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خطة التعلم',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () async {
                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                            dialogTitle: 'اختر خطة التعلم',
                          );

                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;
                            if (file.extension == 'pdf') {
                              // التحقق من وجود ملف قديم
                              if (_learningPlanUrl != null) {
                                // عرض رسالة تأكيد لحفظ الملف القديم
                                final shouldSaveOld = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تحديث خطة التعلم'),
                                    content:
                                        const Text('هل تريد حفظ الملف القديم؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('لا'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('نعم'),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldSaveOld == true) {
                                  // حفظ الملف القديم
                                  await context
                                      .read<AdminCubit>()
                                      .saveOldLearningPlan(_learningPlanUrl!);
                                }
                              }

                              // رفع الملف الجديد
                              final uploadResult = await context
                                  .read<AdminCubit>()
                                  .uploadLearningPlan(file);

                              if (uploadResult != null) {
                                setState(() {
                                  _learningPlanUrl = uploadResult;
                                });
                              }
                            }
                          }
                        } catch (e) {
                          print('Error picking file: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ أثناء رفع الملف: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.description, color: AppColors.primary),
                            SizedBox(width: 8.w),
                            Text(
                              _learningPlanUrl != null
                                  ? 'تم تحميل خطة التعلم'
                                  : 'اختر خطة التعلم...',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              'اختر الطلاب',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: widget.availableStudents?.isEmpty ?? true
                  ? Center(child: Text('لا يوجد طلاب متاحين'))
                  : BlocBuilder<AdminCubit, AdminState>(
                      builder: (context, state) {
                        if (state is AdminStudentsLoaded) {
                          final students = state.students
                              .where((s) => !s.isTeacher && !s.isAdmin)
                              .toList();
                          return ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              final isSelected =
                                  _selectedStudentIds.contains(student.id);
                              return _buildStudentCard(student, isSelected);
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentModel student, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: isSelected ? AppColors.logoTeal : Colors.transparent,
          width: 2,
        ),
      ),
      color: isSelected ? AppColors.logoTeal.withOpacity(0.1) : null,
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              if (!_selectedStudentIds.contains(student.id)) {
                _selectedStudentIds.add(student.id);
              }
            } else {
              _selectedStudentIds.remove(student.id);
            }
          });
        },
        title: Text(
          student.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.logoTeal : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (student.email.isNotEmpty)
              Text(
                student.email,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
            if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty)
              Text(
                student.phoneNumber!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        secondary: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ProfileImage(
              color: Colors.white,
              imageUrl: student.profileImageUrl,
              name: student.name,
              size: 48.r,
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.logoTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
          ],
        ),
        activeColor: AppColors.logoTeal,
        checkColor: Colors.white,
      ),
    );
  }

  // Diálogo para añadir una nueva sura
  void _showAddSurahDialog() {
    _surahNameController.clear();
    _startVerseController.clear();
    _endVerseController.clear();
    _notesController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إضافة سورة',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.logoTeal,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _surahNameController,
                decoration: InputDecoration(
                  labelText: 'اسم السورة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startVerseController,
                      decoration: InputDecoration(
                        labelText: 'الآية البداية',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextFormField(
                      controller: _endVerseController,
                      decoration: InputDecoration(
                        labelText: 'الآية النهاية',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_surahNameController.text.isNotEmpty &&
                  _startVerseController.text.isNotEmpty &&
                  _endVerseController.text.isNotEmpty) {
                final startVerse =
                    int.tryParse(_startVerseController.text) ?? 1;
                final endVerse =
                    int.tryParse(_endVerseController.text) ?? startVerse;

                setState(() {
                  _selectedSurahs.add(
                    SurahAssignment(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      surahName: _surahNameController.text,
                      startVerse: startVerse,
                      endVerse: endVerse,
                      assignedDate: DateTime.now(),
                      notes: _notesController.text.isNotEmpty
                          ? _notesController.text
                          : null,
                    ),
                  );
                });

                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoTeal,
              foregroundColor: Colors.white,
            ),
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
