import 'package:flutter/material.dart';
import 'package:phone/features/students/widgets/student_filter_button.dart';
import 'package:phone/features/students/widgets/student_search_results.dart';
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
  Widget buildResults(BuildContext context) => StudentSearchResults(
    students: students,
    query: query,
  );

  @override
  Widget buildSuggestions(BuildContext context) => StudentSearchResults(
    students: students,
    query: query,
  );
}

