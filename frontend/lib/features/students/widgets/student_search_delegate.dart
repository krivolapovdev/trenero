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
  Widget buildResults(BuildContext context) => _StudentSearchResults(
    students: students,
    query: query,
  );

  @override
  Widget buildSuggestions(BuildContext context) => _StudentSearchResults(
    students: students,
    query: query,
  );
}

class _StudentSearchResults extends ConsumerWidget {
  final List<StudentSummaryResponse> students;
  final String query;

  const new({required this.students, required this.query});

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

    if (filteredStudents.isEmpty) return const _StudentSearchEmpty();

    return StudentListView(students: filteredStudents);
  }

  bool _matchesQuery(StudentSummaryResponse student, String searchQuery) {
    final nameMatches = student.fullName.toLowerCase().contains(searchQuery);
    final phone = student.phone;

    return nameMatches ||
        (phone != null && phone.toLowerCase().contains(searchQuery));
  }
}

class _StudentSearchEmpty extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.t.students.filter.empty),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () =>
              ref.read(studentFilterControllerProvider.notifier).clear(),
          child: Text(context.t.students.filter.reset),
        ),
      ],
    ),
  );
}
