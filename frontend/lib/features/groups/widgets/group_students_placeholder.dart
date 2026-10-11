import 'package:phone/generated/models/student_summary_response.dart';

final List<StudentSummaryResponse> groupStudentsPlaceholderStudents = List.generate(
  3,
  (index) => StudentSummaryResponse(
    id: 'placeholder-$index',
    fullName: 'Student Name Placeholder',
    createdAt: DateTime.now(),
    free: false,
    statuses: const [],
  ),
);
