import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/assign_student_group_controller.dart';
import 'package:phone/features/students/pages/student_group_page.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

final _groups = [
  GroupSummaryResponse(
    id: 'group-a',
    name: 'Group A',
    createdAt: DateTime(2025, 8, 22),
  ),
  GroupSummaryResponse(
    id: 'group-b',
    name: 'Group B',
    createdAt: DateTime(2025, 8, 22),
  ),
];

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => _groups;
}

class _FakeAssignStudentGroupController extends AssignStudentGroupController {
  String? assignedStudentId;
  Set<String>? assignedGroupIds;
  Set<String>? previousGroupIds;

  @override
  Future<bool> assignGroups({
    required String studentId,
    required Set<String> groupIds,
    Set<String> previousGroupIds = const <String>{},
  }) async {
    assignedStudentId = studentId;
    assignedGroupIds = groupIds;
    this.previousGroupIds = previousGroupIds;

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

Future<void> _pumpPage(
  WidgetTester tester,
  ProviderContainer container, {
  Set<String> initialGroupIds = const <String>{},
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StudentGroupPage(
                        studentId: 'student-1',
                        initialGroupIds: initialGroupIds,
                      ),
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

void main() {
  late ProviderContainer container;
  late _FakeAssignStudentGroupController assignController;

  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  setUp(() {
    assignController = _FakeAssignStudentGroupController();

    container = ProviderContainer(
      overrides: [
        groupListControllerProvider.overrideWith(_FakeGroupListController.new),
        assignStudentGroupControllerProvider.overrideWith(
          () => assignController,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('lists every group with a checkbox and no join date field', (
    tester,
  ) async {
    await _pumpPage(tester, container, initialGroupIds: {'group-a'});

    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    expect(find.text('Group A'), findsOneWidget);
    expect(find.text('Group B'), findsOneWidget);

    // The join date is no longer part of the page, the student always joins
    // today.
    expect(find.text(t.students.joinedAt), findsNothing);
  });

  testWidgets('preselects the current groups of the student', (tester) async {
    await _pumpPage(tester, container, initialGroupIds: {'group-a'});

    expect(_tile(tester, 'Group A').value, isTrue);
    expect(_tile(tester, 'Group B').value, isFalse);
  });

  testWidgets('picking another group keeps every picked group selected', (
    tester,
  ) async {
    await _pumpPage(tester, container, initialGroupIds: {'group-a'});

    await tester.tap(find.text('Group B'));
    await tester.pumpAndSettle();

    expect(_tile(tester, 'Group A').value, isTrue);
    expect(_tile(tester, 'Group B').value, isTrue);
  });

  testWidgets('tapping a preselected group drops it', (tester) async {
    await _pumpPage(tester, container, initialGroupIds: {'group-a', 'group-b'});

    await tester.tap(find.text('Group A'));
    await tester.pumpAndSettle();

    expect(_tile(tester, 'Group A').value, isFalse);
    expect(_tile(tester, 'Group B').value, isTrue);
  });

  testWidgets('the update stays disabled until a group is picked', (
    tester,
  ) async {
    await _pumpPage(tester, container);

    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );

    await tester.tap(find.text('Group A'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('submitting assigns every picked group and closes the page', (
    tester,
  ) async {
    await _pumpPage(tester, container, initialGroupIds: {'group-a'});

    await tester.tap(find.text('Group B'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(assignController.assignedStudentId, 'student-1');
    expect(assignController.assignedGroupIds, {'group-a', 'group-b'});
    expect(assignController.previousGroupIds, {'group-a'});
    expect(find.byType(StudentGroupPage), findsNothing);
  });
}
