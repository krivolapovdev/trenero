import 'package:flutter/material.dart';
import 'package:phone/features/students/widgets/student_list_view.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentSearchDelegate extends SearchDelegate {
  final List<StudentSummaryResponse> students;

  new(this.students, String searchLabel)
    : super(searchFieldLabel: searchLabel, keyboardType: TextInputType.text);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    const SizedBox(width: 8),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      close(context, null);
    },
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final filteredStudents = students.where((student) {
      final nameMatches = student.fullName.toLowerCase().contains(
        query.toLowerCase(),
      );
      final phoneMatches =
          student.phone != null &&
          student.phone!.toLowerCase().contains(query.toLowerCase());

      return nameMatches || phoneMatches;
    }).toList();

    if (filteredStudents.isEmpty) {
      return const Center(child: Text('No students found'));
    }

    return StudentListView(students: filteredStudents);
  }
}
