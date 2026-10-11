import 'package:phone/generated/models/group_summary_response.dart';

final List<GroupSummaryResponse> studentGroupPlaceholderGroups = List.generate(
  3,
  (index) => GroupSummaryResponse(
    id: 'placeholder-$index',
    name: 'Group Name Placeholder',
    createdAt: DateTime.now(),
  ),
);
