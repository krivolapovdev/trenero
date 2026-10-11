import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_list_page.dart';
import 'package:phone/features/students/widgets/student_list_view.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

final _groups = [
  GroupSummaryResponse(
    id: 'group-a',
    name: 'Group A',
    createdAt: DateTime(2025, 8, 22),
  ),
];

final _students = [
  StudentSummaryResponse(
    id: 'student-1',
    fullName: 'Ivan Petrov',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.paid],
    studentGroup: GroupResponse(
      id: 'group-a',
      name: 'Group A',
      createdAt: DateTime(2025, 8, 22),
    ),
  ),
  StudentSummaryResponse(
    id: 'student-2',
    fullName: 'Petr Sidorov',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.unpaid],
  ),
];

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => _groups;
}

class _FakeStudentListController extends StudentListController {
  @override
  Future<List<StudentSummaryResponse>> build() async => _students;

  @override
  Future<void> getAllStudents({bool forceRefresh = false}) async {
    state = AsyncData(_students);
  }
}

/// Records every build of a student page family, so a test can tell whether
/// the cached data of the student pages was dropped.
class _FakeStudentLessonsController extends StudentLessonsController {
  new(super.studentId, this.builds);

  final List<String> builds;

  @override
  Future<List<VisitWithLessonResponse>> build() async {
    builds.add(studentId);

    return const [];
  }
}

class _FakeStudentPaymentsController extends StudentPaymentsController {
  new(super.studentId, this.builds);

  final List<String> builds;

  @override
  Future<List<TransactionResponse>> build() async {
    builds.add(studentId);

    return const [];
  }
}

Finder _optionTile(String label) => find.descendant(
  of: find.byType(CheckboxListTile),
  matching: find.text(label),
);

Future<void> _pumpStudentListPage(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final page = StudentListPage(title: 'Students');

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Students'),
                actions: page.actions(context),
              ),
              body: page,
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _openFilterSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(FluentIcons.filter_28_regular));
  await tester.pumpAndSettle();
}

void main() {
  late ProviderContainer container;
  late List<String> lessonsBuilds;
  late List<String> paymentsBuilds;

  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  setUp(() {
    lessonsBuilds = [];
    paymentsBuilds = [];

    container = ProviderContainer(
      overrides: [
        groupListControllerProvider.overrideWith(_FakeGroupListController.new),
        studentListControllerProvider.overrideWith(
          _FakeStudentListController.new,
        ),
        studentLessonsProvider.overrideWith2(
          (studentId) =>
              _FakeStudentLessonsController(studentId, lessonsBuilds),
        ),
        studentPaymentsControllerProvider.overrideWith2(
          (studentId) =>
              _FakeStudentPaymentsController(studentId, paymentsBuilds),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('filter button opens a sheet with group and status checkboxes', (
    tester,
  ) async {
    await _pumpStudentListPage(tester, container);

    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(find.text('Petr Sidorov'), findsOneWidget);

    await _openFilterSheet(tester);

    expect(find.text('Filters'), findsOneWidget);
    expect(_optionTile('No group'), findsOneWidget);
    expect(_optionTile('Group A'), findsOneWidget);

    for (final label in [
      'Inactive',
      'Present',
      'Missing',
      'Paid',
      'Unpaid',
      'Free',
    ]) {
      expect(_optionTile(label), findsOneWidget);
    }
  });

  testWidgets('selected group filters the student list and marks the button', (
    tester,
  ) async {
    await _pumpStudentListPage(tester, container);
    await _openFilterSheet(tester);

    await tester.tap(_optionTile('Group A'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(find.text('Petr Sidorov'), findsNothing);

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );
  });

  testWidgets('reset clears the filter from the empty result state', (
    tester,
  ) async {
    await _pumpStudentListPage(tester, container);
    await _openFilterSheet(tester);

    await tester.tap(_optionTile('Group A'));
    await tester.pumpAndSettle();
    await tester.tap(_optionTile('Unpaid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('No students found'), findsOneWidget);
    expect(find.text('Ivan Petrov'), findsNothing);

    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();

    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(find.text('Petr Sidorov'), findsOneWidget);
  });

  testWidgets('a pull to refresh drops the caches of the student pages', (
    tester,
  ) async {
    // Warm the caches the way opening a student page does.
    await container.read(studentLessonsProvider('student-1').future);
    await container.read(studentPaymentsControllerProvider('student-1').future);

    expect(lessonsBuilds, ['student-1']);
    expect(paymentsBuilds, ['student-1']);

    await _pumpStudentListPage(tester, container);

    await tester.fling(
      find.byType(StudentListView),
      const Offset(0.0, 300.0),
      1000.0,
    );
    await tester.pumpAndSettle();

    // The caches are gone, so reading again builds the family once more.
    await container.read(studentLessonsProvider('student-1').future);
    await container.read(studentPaymentsControllerProvider('student-1').future);

    expect(lessonsBuilds, ['student-1', 'student-1']);
    expect(paymentsBuilds, ['student-1', 'student-1']);
  });
}
