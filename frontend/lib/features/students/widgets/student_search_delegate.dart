import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/widgets/student_filter_button.dart';
import 'package:phone/features/students/widgets/student_list_view.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

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

    const StudentFilterButton(),

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

  Widget _buildSearchResults() => Consumer(
    builder: (context, ref, child) {
      final filter = ref.watch(studentFilterControllerProvider);
      final searchQuery = query.toLowerCase();

      final filteredStudents = students.where((student) {
        final nameMatches = student.fullName.toLowerCase().contains(
          searchQuery,
        );
        final phoneMatches =
            student.phone != null &&
            student.phone!.toLowerCase().contains(searchQuery);

        return (nameMatches || phoneMatches) && filter.matches(student);
      }).toList();

      if (filteredStudents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.t.students.filter.empty),

              if (filter.isNotEmpty) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref
                      .read(studentFilterControllerProvider.notifier)
                      .clear(),
                  child: Text(context.t.students.filter.reset),
                ),
              ],
            ],
          ),
        );
      }

      return StudentListView(students: filteredStudents);
    },
  );
}
