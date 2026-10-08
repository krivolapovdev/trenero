import 'package:phone/generated/models/student_status.dart';
import 'package:phone/generated/models/student_summary_response.dart';

/// Filters applied to the student list.
///
/// An empty collection means "no restriction" for that dimension, while the
/// dimensions themselves are combined with a logical AND.
class StudentFilter {
  /// Sentinel group id used to match students that are not assigned to any group.
  static const String noGroupId = '__no_group__';

  final Set<String> groupIds;
  final Set<StudentStatus> statuses;

  const new({
    this.groupIds = const <String>{},
    this.statuses = const <StudentStatus>{},
  });

  bool get isEmpty => groupIds.isEmpty && statuses.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Number of selected checkboxes, used to mark the filter button.
  int get activeCount => groupIds.length + statuses.length;

  StudentFilter copyWith({
    Set<String>? groupIds,
    Set<StudentStatus>? statuses,
  }) => StudentFilter(
    groupIds: groupIds ?? this.groupIds,
    statuses: statuses ?? this.statuses,
  );

  StudentFilter toggleGroup(String groupId) =>
      copyWith(groupIds: _toggled(groupIds, groupId));

  StudentFilter toggleStatus(StudentStatus status) =>
      copyWith(statuses: _toggled(statuses, status));

  /// Whether [student] satisfies every selected dimension.
  bool matches(StudentSummaryResponse student) {
    final matchesGroup =
        groupIds.isEmpty ||
        groupIds.contains(student.studentGroup?.id ?? noGroupId);
    final matchesStatus =
        statuses.isEmpty || student.statuses.any(statuses.contains);

    return matchesGroup && matchesStatus;
  }

  static Set<T> _toggled<T>(Set<T> values, T value) {
    final next = values.toSet();

    if (!next.remove(value)) next.add(value);

    return next;
  }
}
