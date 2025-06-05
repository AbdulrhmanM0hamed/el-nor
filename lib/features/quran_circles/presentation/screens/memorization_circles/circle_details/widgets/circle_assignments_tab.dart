import 'package:flutter/material.dart';
import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../../data/models/surah_assignment.dart';

class CircleAssignmentsTab extends StatelessWidget {
  final List<SurahAssignment> assignments;
  final bool isEditable;
  final VoidCallback? onAddSurah;

  const CircleAssignmentsTab({
    Key? key,
    required this.assignments,
    required this.isEditable,
    this.onAddSurah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد سور مقررة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isEditable) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAddSurah,
                icon: const Icon(Icons.add),
                label: const Text('إضافة سورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoTeal,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(
              assignment.surahName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'من الآية ${assignment.startVerse} إلى الآية ${assignment.endVerse}',
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.logoTeal,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: isEditable
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Implement edit functionality
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
} 