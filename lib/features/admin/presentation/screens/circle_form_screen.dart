import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/surah_assignment.dart';
import '../../data/models/student_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/shared/profile_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/service_locator.dart';

// Wrapper to provide AdminCubit
class CircleFormScreenWrapper extends StatelessWidget {
  static const String routeName = '/circle-form';
  final MemorizationCircleModel? circle;

  const CircleFormScreenWrapper({Key? key, this.circle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminCubit>()..loadTeachers()..loadStudents(),
      child: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          // تحميل المعلمين والطلاب
          final List<StudentModel> teachers = state is AdminTeachersLoaded ? state.teachers : [];
          final List<StudentModel> students = context.read<AdminCubit>().state is AdminStudentsLoaded
              ? (context.read<AdminCubit>().state as AdminStudentsLoaded).students
              : [];

          return CircleFormScreen(
            title: circle != null ? 'تعديل حلقة ${circle!.name}' : 'إضافة حلقة جديدة',
            initialName: circle?.name,
            initialDescription: circle?.description,
            initialDate: circle?.startDate,
            initialTeacherId: circle?.teacherId,
            initialTeacherName: circle?.teacherName,
            availableTeachers: teachers,
            initialSurahAssignments: circle?.surahAssignments,
            availableStudents: students,
            initialStudentIds: circle?.studentIds,
            initialIsExam: circle?.isExam,
            onSave: (name, description, startDate, teacherId, teacherName, surahAssignments, studentIds, isExam) {
              final adminCubit = context.read<AdminCubit>();
              if (circle != null) {
                // تحديث حلقة موجودة
                adminCubit.updateCircle(
                  id: circle!.id,
                  name: name,
                  description: description,
                  startDate: startDate,
                  teacherId: teacherId,
                  teacherName: teacherName,
                  surahs: surahAssignments,
                  studentIds: studentIds,
                );
              } else {
                // إنشاء حلقة جديدة
                adminCubit.createCircle(
                  name: name,
                  description: description,
                  startDate: startDate,
                  teacherId: teacherId,
                  teacherName: teacherName,
                  surahs: surahAssignments,
                  studentIds: studentIds,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class CircleFormScreen extends StatefulWidget {
  static const String routeName = '/circle-form';
  
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
  final Function(
    String name,
    String description,
    DateTime startDate,
    String? teacherId,
    String? teacherName,
    List<SurahAssignment> surahAssignments,
    List<String> studentIds,
    bool isExam,
  ) onSave;

  const CircleFormScreen({
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
    required this.onSave,
  }) : super(key: key);

  @override
  State<CircleFormScreen> createState() => _CircleFormScreenState();
}

class _CircleFormScreenState extends State<CircleFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String? _selectedTeacherId;
  String? _selectedTeacherName;
  final List<SurahAssignment> _selectedSurahs = [];
  final List<String> _selectedStudentIds = [];
  bool _isExam = false;
  
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
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
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
    if (widget.initialTeacherId != null && widget.initialTeacherId!.isNotEmpty) {
      _selectedTeacherId = widget.initialTeacherId;
      _selectedTeacherName = widget.initialTeacherName;
      print('CircleFormScreen: Initialized selected teacher: $_selectedTeacherName (ID: $_selectedTeacherId)');
    }
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.logoTeal,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveCircle,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'معلومات أساسية', icon: Icon(Icons.info_outline)),
              Tab(text: 'المعلم', icon: Icon(Icons.person)),
              Tab(text: 'السور', icon: Icon(Icons.menu_book)),
              Tab(text: 'الطلاب', icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildTeacherTab(),
            _buildSurahsTab(),
            _buildStudentsTab(),
          ],
        ),
      ),
    );
  }

  // دالة حفظ الحلقة
  void _saveCircle() {
    bool isValid = true;
    String errorMessage = '';

    // التحقق من صحة النموذج الأساسي
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      isValid = false;
      errorMessage = 'يرجى التأكد من إدخال المعلومات الأساسية بشكل صحيح';
    }
    // التحقق من اختيار معلم
    else if (_selectedTeacherId == null || _selectedTeacherId!.isEmpty) {
      isValid = false;
      errorMessage = 'يرجى اختيار معلم للحلقة';
      _tabController.animateTo(1); // الانتقال إلى تبويب المعلم
    }
    // التحقق من إضافة سور (إلا إذا كانت حلقة امتحان)
    else if (!_isExam && _selectedSurahs.isEmpty) {
      isValid = false;
      errorMessage = 'يرجى إضافة سورة واحدة على الأقل';
      _tabController.animateTo(2); // الانتقال إلى تبويب السور
    }
    // التحقق من اختيار طلاب
    else if (_selectedStudentIds.isEmpty) {
      isValid = false;
      errorMessage = 'يرجى اختيار طالب واحد على الأقل';
      _tabController.animateTo(3); // الانتقال إلى تبويب الطلاب
    }

    if (isValid) {
      widget.onSave(
        _nameController.text,
        _descriptionController.text,
        _selectedDate,
        _selectedTeacherId,
        _selectedTeacherName,
        _selectedSurahs,
        _selectedStudentIds,
        _isExam,
      );
      
      Navigator.of(context).pop(true); // إرجاع true للإشارة إلى نجاح الحفظ
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                        colorScheme: ColorScheme.light(
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
                    Icon(Icons.calendar_today, color: AppColors.logoTeal),
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
            // إضافة خيار الامتحان
            SwitchListTile(
              title: Text(
                'حلقة امتحان',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'حدد إذا كانت هذه الحلقة مخصصة للامتحانات',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
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
    );
  }

  // تبويب المعلم
  Widget _buildTeacherTab() {
    return Padding(
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 48.r,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا يوجد معلمين متاحين',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'يرجى إضافة معلمين من صفحة إدارة المستخدمين',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.availableTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = widget.availableTeachers[index];
                      final isSelected = _selectedTeacherId == teacher.id;
                      return _buildTeacherCard(teacher, isSelected);
                    },
                  ),
          ),
        ],
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

  // تبويب اختيار الطلاب
  Widget _buildStudentsTab() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 48.r,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا يوجد طلاب متاحين',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'يرجى إضافة طلاب من صفحة إدارة المستخدمين',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.availableStudents?.length ?? 0,
                    itemBuilder: (context, index) {
                      final student = widget.availableStudents![index];
                      final isSelected = _selectedStudentIds.contains(student.id);
                      return _buildStudentCard(student, isSelected);
                    },
                  ),
          ),
        ],
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
                final startVerse = int.tryParse(_startVerseController.text) ?? 1;
                final endVerse = int.tryParse(_endVerseController.text) ?? startVerse;
                
                setState(() {
                  _selectedSurahs.add(
                    SurahAssignment(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      surahName: _surahNameController.text,
                      startVerse: startVerse,
                      endVerse: endVerse,
                      assignedDate: DateTime.now(),
                      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
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