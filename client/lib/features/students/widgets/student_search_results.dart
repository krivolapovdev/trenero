import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/widgets/student_list_view.dart';
import 'package:phone/features/students/widgets/student_search_empty.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentSearchResults extends ConsumerWidget {
  final List<StudentSummaryResponse> students;
  final String query;

  const new({super.key, required this.students, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(studentFilterControllerProvider);
    final searchQuery = query.toLowerCase();

    final filteredStudents = students
        .where(
          (student) =>
              _matchesQuery(student, searchQuery) && filter.matches(student),
        )
        .toList(growable: false);

    if (filteredStudents.isEmpty) return const StudentSearchEmpty();

    return StudentListView(students: filteredStudents);
  }

  bool _matchesQuery(StudentSummaryResponse student, String searchQuery) {
    final nameMatches = student.fullName.toLowerCase().contains(searchQuery);
    final phone = student.phone;

    return nameMatches ||
        (phone != null && phone.toLowerCase().contains(searchQuery));
  }
}
