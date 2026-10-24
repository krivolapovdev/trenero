import 'package:phone/generated/models/student_response.dart';

final rosterStudentListDummyStudents = List.generate(
  5,
  (i) => StudentResponse(
    id: 'dummy-$i',
    fullName: 'Student Full Name Placeholder',
    createdAt: DateTime.now(),
    free: false,
    phone: '+1 234 567 8900',
  ),
);
