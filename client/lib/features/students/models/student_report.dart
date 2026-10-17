import 'package:phone/generated/models/group_report_response.dart';

/// One individual lesson of the reported month, as the student attended it.
class StudentReportLesson {
  final DateTime date;
  final bool present;

  const new({required this.date, required this.present});
}

/// Monthly report of a single student.
///
/// It holds the attendance table of every group the student belongs to, each
/// already narrowed down to this student, and the individual lessons of the
/// month. Together with the name and the period they are everything the report
/// document needs to be rendered.
class StudentReport {
  final String studentId;
  final String fullName;
  final int year;
  final int month;

  /// One report per group the student belongs to; each of them holds a single
  /// student row, so that no other student shows up in the tables.
  final List<GroupReportResponse> groups;

  /// The individual lessons of the month, ordered by date.
  final List<StudentReportLesson> individualLessons;

  const new({
    required this.studentId,
    required this.fullName,
    required this.year,
    required this.month,
    required this.groups,
    required this.individualLessons,
  });

  int get individualPresentCount =>
      individualLessons.where((lesson) => lesson.present).length;

  int get individualLessonCount => individualLessons.length;
}
