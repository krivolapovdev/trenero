import 'package:phone/generated/models/roster_response.dart';

final rosterListDummyRosters = List.generate(
  6,
  (index) => RosterResponse(
    id: 'dummy-$index',
    name: 'Temporary Roster ${index + 1}',
    note: 'Sample temporary notes for group ${index + 1}',
    date: DateTime.now(),
    countOfStudents: 8,
    createdAt: DateTime.now(),
  ),
);
