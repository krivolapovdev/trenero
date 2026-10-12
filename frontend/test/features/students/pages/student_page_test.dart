import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/create_lesson_button.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/widgets/student_lesson_calendar_section.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

const _studentId = 'student-1';

final _group = GroupResponse(
  id: 'group-a',
  name: 'Group A',
  createdAt: DateTime(2025, 8, 22),
);

final _studentWithoutGroup = StudentSummaryResponse(
  id: _studentId,
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
);

final _studentWithGroup = StudentSummaryResponse(
  id: _studentId,
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
  studentGroups: [_group],
);

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

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => const [];
}

Future<void> _pumpPage(
  WidgetTester tester,
  StudentSummaryResponse student,
) async {
  final container = ProviderContainer(
    overrides: [
      studentListControllerProvider.overrideWith(
        () => _FakeStudentListController([student]),
      ),
      studentLessonsProvider.overrideWith2(_FakeStudentLessonsController.new),
      studentPaymentsControllerProvider.overrideWith2(
        _FakeStudentPaymentsController.new,
      ),
      groupListControllerProvider.overrideWith(_FakeGroupListController.new),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(home: StudentPage(student: student)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _appBarAction() => find.descendant(
  of: find.byType(AppBar),
  matching: find.byType(CreateLessonButton),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the app bar creates the individual lesson of the student', (
    tester,
  ) async {
    await _pumpPage(tester, _studentWithoutGroup);

    expect(_appBarAction(), findsOneWidget);

    await tester.tap(_appBarAction());
    await tester.pumpAndSettle();

    final page = tester.widget<StudentLessonPage>(
      find.byType(StudentLessonPage),
    );
    expect(page.studentId, _studentId);
    expect(page.lesson, isNull);
  });

  testWidgets('the calendar of the individual lessons carries no button', (
    tester,
  ) async {
    await _pumpPage(tester, _studentWithoutGroup);

    expect(find.byType(StudentLessonCalendarSection), findsOneWidget);

    expect(find.byType(CreateLessonButton), findsOneWidget);
  });

  testWidgets('the calendar of a group keeps the button of its lessons', (
    tester,
  ) async {
    await _pumpPage(tester, _studentWithGroup);

    expect(find.byType(CreateLessonButton), findsNWidgets(2));
  });
}
