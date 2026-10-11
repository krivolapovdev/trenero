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

/// The student as the response of the group holds them, carrying no group.
final _groupStudents = [
  GroupStudentSummaryResponse(
    id: _studentId,
    fullName: 'Anna Smirnova',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.paid],
  ),
];

/// The same student as the student list holds them, with the group they belong
/// to.
final _listedStudents = [
  StudentSummaryResponse(
    id: _studentId,
    fullName: 'Anna Smirnova',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.paid],
    studentGroup: _group,
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

/// Opens the group page of the student the section card points at, the way the
/// student page does: through the menu of the app bar.
Future<void> _openGroupPage(WidgetTester tester) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();

  await tester.tap(find.text(t.students.group));
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
    expect(find.text('1. Anna Smirnova'), findsOneWidget);

    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    expect(updated, isTrue);
  });

  testWidgets('a student opened from a group keeps the groups of the student', (
    tester,
  ) async {
    await _pumpSection(tester, _container(students: _listedStudents));

    expect(find.text('1. Anna Smirnova'), findsOneWidget);

    await tester.tap(find.text('1. Anna Smirnova'));
    await tester.pumpAndSettle();

    final page = tester.widget<StudentPage>(find.byType(StudentPage));
    expect(page.student.studentGroups, [_group]);

    await _openGroupPage(tester);

    expect(find.byType(StudentGroupPage), findsOneWidget);

    // The group the student belongs to is preselected.
    expect(_tile(tester, 'Group A').value, isTrue);
    expect(_tile(tester, 'Group B').value, isFalse);
  });

  testWidgets(
    'a student the list does not hold opens with the group response',
    (tester) async {
      await _pumpSection(tester, _container());

      await tester.tap(find.text('1. Anna Smirnova'));
      await tester.pumpAndSettle();

      final page = tester.widget<StudentPage>(find.byType(StudentPage));
      expect(page.student.id, _studentId);
      expect(page.student.studentGroups, isNull);
    },
  );
}
