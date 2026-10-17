import 'package:phone/generated/models/group_summary_response.dart';

final List<GroupSummaryResponse> groupListDummyGroups = List.generate(
  10,
  (index) => GroupSummaryResponse(
    id: 'placeholder-$index',
    name: 'Group Name Placeholder',
    createdAt: DateTime.now(),
    countOfStudents: 99,
  ),
);
