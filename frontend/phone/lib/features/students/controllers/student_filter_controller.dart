import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/models/student_filter.dart';
import 'package:phone/generated/models/student_status.dart';

final studentFilterControllerProvider =
    NotifierProvider<StudentFilterController, StudentFilter>(
      StudentFilterController.new,
    );

class StudentFilterController extends Notifier<StudentFilter> {
  @override
  StudentFilter build() => const StudentFilter();

  void toggleGroup(String groupId) => state = state.toggleGroup(groupId);

  void toggleStatus(StudentStatus status) => state = state.toggleStatus(status);

  void setFilter(StudentFilter filter) => state = filter.copyWith(
    groupIds: Set.unmodifiable(filter.groupIds),
    statuses: Set.unmodifiable(filter.statuses),
  );

  void clear() => state = const StudentFilter();
}
