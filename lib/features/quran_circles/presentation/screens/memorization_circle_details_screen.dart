import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';
import '../widgets/circle_students_tab.dart';
import '../widgets/circle_assignments_tab.dart';
import '../widgets/circle_reports_tab.dart';

class MemorizationCircleDetailsScreen extends StatefulWidget {
  final MemorizationCircle circle;
  final bool isAdmin;

  const MemorizationCircleDetailsScreen({
    Key? key,
    required this.circle,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<MemorizationCircleDetailsScreen> createState() => _MemorizationCircleDetailsScreenState();
}

class _MemorizationCircleDetailsScreenState extends State<MemorizationCircleDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MemorizationCircle _circle;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _circle = widget.circle;

    // Cargar detalles del círculo usando el Cubit
    // context.read<MemorizationCirclesCubit>().loadCircleDetails(_circle.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_circle.name),
        backgroundColor: AppColors.logoTeal,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(text: 'السور المقررة'),
            Tab(text: 'الطلاب'),
            Tab(text: 'التقارير'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de suras asignadas
          CircleAssignmentsTab(
            assignments: _circle.assignments,
            isAdmin: widget.isAdmin,
            onAddSurah: widget.isAdmin ? _showAddSurahDialog : null,
          ),
          // Pestaña de estudiantes
          CircleStudentsTab(
            students: _circle.students,
            isAdmin: widget.isAdmin,
            onEvaluationChanged: widget.isAdmin ? _onEvaluationChanged : null,
            onAttendanceChanged: widget.isAdmin ? _onAttendanceChanged : null,
            onAddStudent: widget.isAdmin ? _showAddStudentDialog : null,
          ),
          // Pestaña de reportes
          CircleReportsTab(
            isAdmin: widget.isAdmin,
            onAddReport: widget.isAdmin ? _showAddReportDialog : null,
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.logoTeal,
              child: const Icon(Icons.add),
              onPressed: () {
                // Mostrar opciones para agregar sura o estudiante según la pestaña activa
                _showAddOptions();
              },
            )
          : null,
    );
  }

  void _showAddOptions() {
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      _showAddSurahDialog();
    } else if (currentTab == 1) {
      _showAddStudentDialog();
    } else if (currentTab == 2) {
      _showAddReportDialog();
    }
  }

  void _onEvaluationChanged(int studentId, int evaluation) {
    // Actualizar solo el estado local sin usar el Cubit
    setState(() {
      final studentIndex = _circle.students.indexWhere((s) => s.id == studentId);
      if (studentIndex != -1) {
        final updatedStudent = _circle.students[studentIndex].copyWith(evaluation: evaluation);
        final updatedStudents = List<MemorizationStudent>.from(_circle.students);
        updatedStudents[studentIndex] = updatedStudent;

        _circle = MemorizationCircle(
          id: _circle.id,
          name: _circle.name,
          teacherName: _circle.teacherName,
          description: _circle.description,
          date: _circle.date,
          students: updatedStudents,
          assignments: _circle.assignments,
          isExam: _circle.isExam,
        );
      }
    });
  }

  void _onAttendanceChanged(int studentId, bool isPresent) {
    // Actualizar solo el estado local sin usar el Cubit
    setState(() {
      final studentIndex = _circle.students.indexWhere((s) => s.id == studentId);
      if (studentIndex != -1) {
        final updatedStudent = _circle.students[studentIndex].copyWith(isPresent: isPresent);
        final updatedStudents = List<MemorizationStudent>.from(_circle.students);
        updatedStudents[studentIndex] = updatedStudent;

        _circle = MemorizationCircle(
          id: _circle.id,
          name: _circle.name,
          teacherName: _circle.teacherName,
          description: _circle.description,
          date: _circle.date,
          students: updatedStudents,
          assignments: _circle.assignments,
          isExam: _circle.isExam,
        );
      }
    });
  }

  void _showAddSurahDialog() {
    // En una aplicación real, esto mostraría un formulario para agregar una nueva surah
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('سيتم إضافة ميزة إضافة سورة قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }

  void _showAddStudentDialog() {
    // En una aplicación real, esto mostraría un formulario para agregar un nuevo estudiante
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة إضافة طالب قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }

  void _showAddReportDialog() {
    // En una aplicación real, esto mostraría un formulario para crear un nuevo reporte
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة إنشاء تقارير قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }
}
