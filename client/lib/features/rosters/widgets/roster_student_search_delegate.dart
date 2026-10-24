import 'package:flutter/material.dart';
import 'package:phone/features/rosters/widgets/roster_student_list_view.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class RosterStudentSearchDelegate extends SearchDelegate {
  final List<StudentResponse> students;
  final List<StudentSummaryResponse> fullSummaries;
  final ValueChanged<String>? onRemoveStudent;
  final ValueChanged<StudentResponse>? onEditStudent;

  new(
    this.students,
    this.fullSummaries,
    this.onRemoveStudent,
    String searchLabel, {
    this.onEditStudent,
  }) : super(searchFieldLabel: searchLabel, keyboardType: TextInputType.text);

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
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final searchLower = query.toLowerCase();
    final filtered = students
        .where(
          (student) =>
              student.fullName.toLowerCase().contains(searchLower) ||
              (student.phone != null &&
                  student.phone!.toLowerCase().contains(searchLower)),
        )
        .toList();

    if (filtered.isEmpty) {
      return Center(child: Text(context.t.students.filter.empty));
    }

    return RosterStudentListView(
      students: filtered,
      fullSummaries: fullSummaries,
      onRemoveStudent: onRemoveStudent,
      onEditStudent: onEditStudent,
    );
  }
}
