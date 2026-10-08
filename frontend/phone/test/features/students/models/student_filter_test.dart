import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/students/models/student_filter.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/generated/models/student_summary_response.dart';

StudentSummaryResponse _student({
  String id = 'student-1',
  String? groupId,
  List<StudentStatus> statuses = const [],
}) => StudentSummaryResponse(
  id: id,
  fullName: 'Ivan Petrov',
  createdAt: DateTime(2025, 8, 22),
  statuses: statuses,
  studentGroup: groupId == null
      ? null
      : GroupResponse(
          id: groupId,
          name: 'Group $groupId',
          createdAt: DateTime(2025, 8, 22),
        ),
);

void main() {
  group('StudentFilter.matches', () {
    test('an empty filter matches every student', () {
      const filter = StudentFilter();

      expect(filter.isEmpty, isTrue);
      expect(filter.activeCount, 0);
      expect(filter.matches(_student()), isTrue);
      expect(filter.matches(_student(groupId: 'group-1')), isTrue);
    });

    test('a group filter keeps only the selected group', () {
      const filter = StudentFilter(groupIds: {'group-1'});

      expect(filter.matches(_student(groupId: 'group-1')), isTrue);
      expect(filter.matches(_student(groupId: 'group-2')), isFalse);
      expect(filter.matches(_student()), isFalse);
    });

    test('the noGroup sentinel keeps students without a group', () {
      final filter = StudentFilter(groupIds: {StudentFilter.noGroupId});

      expect(filter.matches(_student()), isTrue);
      expect(filter.matches(_student(groupId: 'group-1')), isFalse);
    });

    test('a status filter keeps students having any of the statuses', () {
      const filter = StudentFilter(statuses: {StudentStatus.paid});

      expect(
        filter.matches(_student(statuses: [StudentStatus.present])),
        isFalse,
      );
      expect(
        filter.matches(
          _student(statuses: [StudentStatus.present, StudentStatus.paid]),
        ),
        isTrue,
      );
    });

    test('group and status filters are combined', () {
      const filter = StudentFilter(
        groupIds: {'group-1'},
        statuses: {StudentStatus.paid},
      );

      expect(filter.activeCount, 2);
      expect(
        filter.matches(
          _student(groupId: 'group-1', statuses: [StudentStatus.paid]),
        ),
        isTrue,
      );
      expect(
        filter.matches(
          _student(groupId: 'group-2', statuses: [StudentStatus.paid]),
        ),
        isFalse,
      );
      expect(
        filter.matches(
          _student(groupId: 'group-1', statuses: [StudentStatus.unpaid]),
        ),
        isFalse,
      );
    });
  });

  group('StudentFilter toggles', () {
    test('toggling a group adds and removes it', () {
      const filter = StudentFilter();

      final withGroup = filter.toggleGroup('group-1');

      expect(withGroup.groupIds, {'group-1'});
      expect(withGroup.activeCount, 1);
      expect(filter.groupIds, isEmpty);

      expect(withGroup.toggleGroup('group-1').groupIds, isEmpty);
    });

    test('toggling a status keeps the selected groups', () {
      const filter = StudentFilter(groupIds: {'group-1'});

      final withStatus = filter.toggleStatus(StudentStatus.unpaid);

      expect(withStatus.groupIds, {'group-1'});
      expect(withStatus.statuses, {StudentStatus.unpaid});
      expect(withStatus.activeCount, 2);

      expect(withStatus.toggleStatus(StudentStatus.unpaid).statuses, isEmpty);
    });

    test('copyWith replaces only the provided dimension', () {
      const filter = StudentFilter(
        groupIds: {'group-1'},
        statuses: {StudentStatus.paid},
      );

      final updated = filter.copyWith(statuses: {StudentStatus.unpaid});

      expect(updated.groupIds, {'group-1'});
      expect(updated.statuses, {StudentStatus.unpaid});
    });
  });
}
