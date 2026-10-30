import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/widgets/group_students_section.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_group_page.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

const _groupId = 'group-a';
const _studentId = 'student-1';

final _group = GroupResponse(
  id: _groupId,
  name: 'Group A',
  createdAt: DateTime(2025, 8, 22),
);

final _groups = [
  GroupSummaryResponse(
    id: _groupId,
    name: 'Group A',
    createdAt: DateTime(2025, 8, 22),
  ),
  GroupSummaryResponse(
    id: 'group-b',
    name: 'Group B',
    createdAt: DateTime(2025, 8, 22),
  ),
];

final _groupStudents = [
  GroupStudentSummaryResponse(
    id: _studentId,
    fullName: 'Anna Smirnova',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.paid],
  ),
];

final _listedStudents = [
  StudentSummaryResponse(
    id: _studentId,
    fullName: 'Anna Smirnova',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.paid],
    studentGroups: [_group],
  ),
];

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => _groups;
}

class _FakeGroupStudentsController extends GroupStudentsController {
  new(super.groupId);

  @override
  Future<List<GroupStudentSummaryResponse>> build() async => _groupStudents;
}

class _FakeEmptyGroupStudentsController extends GroupStudentsController {
  new(super.groupId);

  @override
  Future<List<GroupStudentSummaryResponse>> build() async => const [];
}

class _FakeStudentListController extends StudentListController {
  new(this.students);

  final List<StudentSummaryResponse> students;

  @override
  Future<List<StudentSummaryResponse>> build() async => students;
}

class _FakeStudentLessonsController extends StudentLessonsController {
  new(super.studentId);

  @override
  Future<List<VisitWithLessonResponse>> build() async => const [];
}

class _FakeStudentPaymentsController extends StudentPaymentsController {
  new(super.studentId);

  @override
  Future<List<TransactionResponse>> build() async => const [];
}

CheckboxListTile _tile(WidgetTester tester, String label) =>
    tester.widget<CheckboxListTile>(
      find.descendant(
        of: find.byType(StudentGroupPage),
        matching: find.ancestor(
          of: find.text(label),
          matching: find.byType(CheckboxListTile),
        ),
      ),
    );

ProviderContainer _container({
  List<StudentSummaryResponse> students = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      groupListControllerProvider.overrideWith(_FakeGroupListController.new),
      groupStudentsProvider.overrideWith2(_FakeGroupStudentsController.new),
      studentListControllerProvider.overrideWith(
        () => _FakeStudentListController(students),
      ),
      studentLessonsProvider.overrideWith2(_FakeStudentLessonsController.new),
      studentPaymentsControllerProvider.overrideWith2(
        _FakeStudentPaymentsController.new,
      ),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

Future<void> _pumpSection(
  WidgetTester tester,
  ProviderContainer container, {
  VoidCallback? onUpdate,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: GroupStudentsSection(groupId: _groupId, onEdit: onUpdate),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openGroupPage(WidgetTester tester) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(PopupMenuItem<String>, t.groups.title));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the card titles the students and offers to update them', (
    tester,
  ) async {
    var updated = false;

    await _pumpSection(
      tester,
      _container(students: _listedStudents),
      onUpdate: () => updated = true,
    );

    expect(find.text(t.students.title), findsOneWidget);
    expect(find.text('Anna Smirnova'), findsOneWidget);

    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    expect(updated, isTrue);
  });

  testWidgets('a student opened from a group keeps the groups of the student', (
    tester,
  ) async {
    await _pumpSection(tester, _container(students: _listedStudents));

    expect(find.text('Anna Smirnova'), findsOneWidget);

    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

    final page = tester.widget<StudentPage>(find.byType(StudentPage));
    expect(page.student.studentGroups, [_group]);

    await _openGroupPage(tester);

    expect(find.byType(StudentGroupPage), findsOneWidget);

    expect(_tile(tester, 'Group A').value, isTrue);
    expect(_tile(tester, 'Group B').value, isFalse);
  });

  testWidgets(
    'a student the list does not hold opens with the group response',
    (tester) async {
      await _pumpSection(tester, _container());

      await tester.tap(find.text('Anna Smirnova'));
      await tester.pumpAndSettle();

      final page = tester.widget<StudentPage>(find.byType(StudentPage));
      expect(page.student.id, _studentId);
      expect(page.student.studentGroups, isNull);
    },
  );

  testWidgets(
    'displays updated student name and statuses from listed students',
    (tester) async {
      final updatedStudent = StudentSummaryResponse(
        id: _studentId,
        fullName: 'Anna Updated',
        createdAt: DateTime(2025, 8, 22),
        free: false,
        statuses: const [StudentStatus.unpaid],
        studentGroups: [_group],
        note: 'Secret note',
      );

      await _pumpSection(tester, _container(students: [updatedStudent]));

      // StudentCard displays the updated name from listedStudents
      expect(find.text('Anna Updated'), findsOneWidget);
      expect(find.text('Anna Smirnova'), findsNothing);

      // Student groups and notes are hidden in group page
      expect(find.text('Group A'), findsNothing);
      expect(find.text('Secret note'), findsNothing);

      // Opening student page passes the updated student
      await tester.tap(find.text('Anna Updated'));
      await tester.pumpAndSettle();

      final page = tester.widget<StudentPage>(find.byType(StudentPage));
      expect(page.student.fullName, 'Anna Updated');
      expect(page.student.statuses, [StudentStatus.unpaid]);
    },
  );

  testWidgets(
    'shows empty card with title, edit button, and no students text when empty',
    (tester) async {
      var updated = false;

      final container = ProviderContainer(
        overrides: [
          groupListControllerProvider.overrideWith(
            _FakeGroupListController.new,
          ),
          groupStudentsProvider.overrideWith2(
            _FakeEmptyGroupStudentsController.new,
          ),
          studentListControllerProvider.overrideWith(
            () => _FakeStudentListController(const []),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpSection(tester, container, onUpdate: () => updated = true);

      expect(find.text(t.students.title), findsOneWidget);
      expect(find.text(t.edit), findsOneWidget);
      expect(find.text(t.noStudents), findsOneWidget);

      await tester.tap(find.text(t.edit));
      await tester.pumpAndSettle();

      expect(updated, isTrue);
    },
  );
}
