import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/controllers/assign_group_students_controller.dart';
import 'package:phone/features/groups/pages/group_students_page.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

final _group = GroupSummaryResponse(
  id: 'group-1',
  name: 'Group A',
  createdAt: DateTime(2026, 1, 15),
);

final _students = [
  StudentSummaryResponse(
    id: 'student-1',
    fullName: 'Anna Smirnova',
    createdAt: DateTime(2026, 1, 15),
    free: false,
    statuses: const [],
  ),
  StudentSummaryResponse(
    id: 'student-2',
    fullName: 'Ivan Petrov',
    createdAt: DateTime(2026, 1, 15),
    free: false,
    statuses: const [],
  ),
];

GroupStudentSummaryResponse _groupStudent(String id, String fullName) =>
    GroupStudentSummaryResponse(
      id: id,
      fullName: fullName,
      createdAt: DateTime(2026, 1, 15),
      free: false,
      statuses: const [],
    );

/// Serves the students the group currently holds, plus the answers the group
/// page itself never asks for.
class _FakeGroupClient implements GroupControllerClient {
  final List<GroupStudentSummaryResponse> groupStudents;

  new({this.groupStudents = const []});

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) async => groupStudents;

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() async => [_group];

  @override
  Future<GroupResponse> createGroup({required CreateGroupRequest body}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteGroup({required String groupId}) =>
      throw UnimplementedError();

  @override
  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) => throw UnimplementedError();

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError();
}

class _FakeStudentListController extends StudentListController {
  @override
  Future<List<StudentSummaryResponse>> build() async => _students;
}

class _FakeAssignGroupStudentsController extends AssignGroupStudentsController {
  String? assignedGroupId;
  Set<String>? assignedStudentIds;

  @override
  Future<bool> assignStudents({
    required String groupId,
    required Set<String> studentIds,
  }) async {
    assignedGroupId = groupId;
    assignedStudentIds = studentIds;

    return true;
  }
}

CheckboxListTile _tile(WidgetTester tester, String label) =>
    tester.widget<CheckboxListTile>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(CheckboxListTile),
      ),
    );

void main() {
  late _FakeAssignGroupStudentsController assignController;

  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  setUp(() {
    assignController = _FakeAssignGroupStudentsController();
  });

  ProviderContainer container({
    List<GroupStudentSummaryResponse> groupStudents = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        studentListControllerProvider.overrideWith(
          _FakeStudentListController.new,
        ),
        groupServiceProvider.overrideWithValue(
          _FakeGroupClient(groupStudents: groupStudents),
        ),
        assignGroupStudentsControllerProvider.overrideWith(
          () => assignController,
        ),
      ],
    );
    addTearDown(container.dispose);

    return container;
  }

  Future<void> pumpPage(
    WidgetTester tester,
    ProviderContainer providerContainer,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: providerContainer,
        child: TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GroupStudentsPage(group: _group),
                      ),
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists every student with a checkbox', (tester) async {
    await pumpPage(tester, container());

    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    expect(find.text('Anna Smirnova'), findsOneWidget);
    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(_tile(tester, 'Anna Smirnova').value, isFalse);
    expect(_tile(tester, 'Ivan Petrov').value, isFalse);
  });

  testWidgets('preselects the students of the group', (tester) async {
    await pumpPage(
      tester,
      container(groupStudents: [_groupStudent('student-1', 'Anna Smirnova')]),
    );

    expect(_tile(tester, 'Anna Smirnova').value, isTrue);
    expect(_tile(tester, 'Ivan Petrov').value, isFalse);
  });

  testWidgets('picking another student keeps every picked student selected', (
    tester,
  ) async {
    await pumpPage(
      tester,
      container(groupStudents: [_groupStudent('student-1', 'Anna Smirnova')]),
    );

    await tester.tap(find.text('Ivan Petrov'));
    await tester.pumpAndSettle();

    expect(_tile(tester, 'Anna Smirnova').value, isTrue);
    expect(_tile(tester, 'Ivan Petrov').value, isTrue);
  });

  testWidgets('tapping a preselected student drops it', (tester) async {
    await pumpPage(
      tester,
      container(
        groupStudents: [
          _groupStudent('student-1', 'Anna Smirnova'),
          _groupStudent('student-2', 'Ivan Petrov'),
        ],
      ),
    );

    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

    expect(_tile(tester, 'Anna Smirnova').value, isFalse);
    expect(_tile(tester, 'Ivan Petrov').value, isTrue);
  });

  testWidgets('submitting assigns every picked student and closes the page', (
    tester,
  ) async {
    await pumpPage(
      tester,
      container(groupStudents: [_groupStudent('student-1', 'Anna Smirnova')]),
    );

    await tester.tap(find.text('Ivan Petrov'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(assignController.assignedGroupId, 'group-1');
    expect(assignController.assignedStudentIds, {'student-1', 'student-2'});
    expect(find.byType(GroupStudentsPage), findsNothing);
  });

  testWidgets('an empty group still offers clearing every student', (
    tester,
  ) async {
    await pumpPage(tester, container());

    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNotNull,
    );
  });
}
