// La importación de material.dart es necesaria para los tipos de datos como Color

/// Modelo para representar un estudiante en un círculo de memorización
class MemorizationStudent {
  final int id;
  final String name;
  final String imageUrl;
  final bool isPresent;
  final int evaluation; // Evaluación del 1 al 5

  const MemorizationStudent({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isPresent = true,
    this.evaluation = 0,
  });

  // Crear una copia del estudiante con valores actualizados
  MemorizationStudent copyWith({
    int? id,
    String? name,
    String? imageUrl,
    bool? isPresent,
    int? evaluation,
  }) {
    return MemorizationStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isPresent: isPresent ?? this.isPresent,
      evaluation: evaluation ?? this.evaluation,
    );
  }
}

/// Modelo para representar una asignación de Surah en un círculo de memorización
class SurahAssignment {
  final int id;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final DateTime assignedDate;

  const SurahAssignment({
    required this.id,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    required this.assignedDate,
  });
}

/// Modelo para representar un círculo de memorización del Quran
class MemorizationCircle {
  final int id;
  final String name;
  final String teacherName;
  final String description;
  final DateTime date;
  final List<MemorizationStudent> students;
  final List<SurahAssignment> assignments;
  final bool isExam; // Indica si es un examen o una sesión regular de memorización

  const MemorizationCircle({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.description,
    required this.date,
    required this.students,
    required this.assignments,
    this.isExam = false,
  });

  // Método para generar datos de ejemplo
  static List<MemorizationCircle> getSampleCircles() {
    return [
      MemorizationCircle(
        id: 1,
        name: 'حلقة حفظ جزء عم',
        teacherName: 'الشيخ أحمد محمد',
        description: 'حلقة لحفظ سور جزء عم للمبتدئين',
        date: DateTime.now().add(const Duration(days: 2)),
        isExam: false,
        students: [
          const MemorizationStudent(
            id: 1,
            name: 'محمد أحمد',
            imageUrl: 'assets/images/student1.jpg',
            evaluation: 4,
          ),
          const MemorizationStudent(
            id: 2,
            name: 'عبد الرحمن خالد',
            imageUrl: 'assets/images/student2.jpg',
            evaluation: 5,
          ),
          const MemorizationStudent(
            id: 3,
            name: 'يوسف إبراهيم',
            imageUrl: 'assets/images/student3.jpg',
            evaluation: 3,
          ),
        ],
        assignments: [
          SurahAssignment(
            id: 1,
            surahName: 'النبأ',
            startVerse: 1,
            endVerse: 30,
            assignedDate: DateTime.now(),
          ),
          SurahAssignment(
            id: 2,
            surahName: 'النازعات',
            startVerse: 15,
            endVerse: 48,
            assignedDate: DateTime.now(),
          ),
          SurahAssignment(
            id: 3,
            surahName: 'عبس',
            startVerse: 1,
            endVerse: 42,
            assignedDate: DateTime.now(),
          ),
          SurahAssignment(
            id: 4,
            surahName: 'التكوير',
            startVerse: 1,
            endVerse: 29,
            assignedDate: DateTime.now(),
          ),
        ],
      ),
      MemorizationCircle(
        id: 2,
        name: 'امتحان حفظ سورة البقرة',
        teacherName: 'الشيخ محمود علي',
        description: 'امتحان حفظ للجزء الأول من سورة البقرة',
        date: DateTime.now().add(const Duration(days: 5)),
        isExam: true,
        students: [
          const MemorizationStudent(
            id: 4,
            name: 'أحمد محمد',
            imageUrl: 'assets/images/student4.jpg',
            evaluation: 0,
          ),
          const MemorizationStudent(
            id: 5,
            name: 'عمر خالد',
            imageUrl: 'assets/images/student5.jpg',
            evaluation: 0,
          ),
        ],
        assignments: [
          SurahAssignment(
            id: 5,
            surahName: 'البقرة',
            startVerse: 1,
            endVerse: 75,
            assignedDate: DateTime.now().subtract(const Duration(days: 14)),
          ),
        ],
      ),
      MemorizationCircle(
        id: 3,
        name: 'حلقة حفظ سورة يس',
        teacherName: 'الشيخ عبد الله محمد',
        description: 'حلقة لحفظ سورة يس كاملة',
        date: DateTime.now().add(const Duration(days: 1)),
        isExam: false,
        students: [
          const MemorizationStudent(
            id: 6,
            name: 'خالد محمود',
            imageUrl: 'assets/images/student6.jpg',
            evaluation: 4,
          ),
          const MemorizationStudent(
            id: 7,
            name: 'عبد الله أحمد',
            imageUrl: 'assets/images/student7.jpg',
            evaluation: 3,
          ),
        ],
        assignments: [
          SurahAssignment(
            id: 6,
            surahName: 'يس',
            startVerse: 1,
            endVerse: 83,
            assignedDate: DateTime.now(),
          ),
        ],
      ),
    ];
  }
}
