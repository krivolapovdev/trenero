import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/create_lesson_button.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/controllers/student_report_controller.dart';
import 'package:phone/features/students/models/student_report.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/widgets/student_day_lessons_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_header.dart';
import 'package:phone/features/students/widgets/student_report_bottom_sheet.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
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

VisitWithLessonResponse _visit({
  required LessonResponse lesson,
  VisitStatus status = VisitStatus.present,
}) => VisitWithLessonResponse(
  visit: VisitResponse(
    id: 'visit-${lesson.id}',
    status: status,
    type: VisitType.regular,
    lessonId: lesson.id,
    studentId: _studentId,
    createdAt: lesson.date,
  ),
  lesson: lesson,
);

class _FakeStudentListController extends StudentListController {
  new(this.students);

  final List<StudentSummaryResponse> students;

  @override
  Future<List<StudentSummaryResponse>> build() async => students;
}

class _FakeStudentLessonsController extends StudentLessonsController {
  new(super.studentId, [this.visits = const []]);

  final List<VisitWithLessonResponse> visits;

  @override
  Future<List<VisitWithLessonResponse>> build() async => visits;
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

class _FakeStudentReportController extends StudentReportController {
  new(super.period);

  @override
  Future<StudentReport> build() async => StudentReport(
    studentId: period.studentId,
    fullName: 'Anna Smirnova',
    year: period.year,
    month: period.month,
    groups: const [],
    individualLessons: const [],
  );
}

class _FakeGroupStudentsController extends GroupStudentsController {
  new(super.groupId);

  @override
  Future<List<GroupStudentSummaryResponse>> build() async => const [];
}

Future<void> _pumpPage(
  WidgetTester tester,
  StudentSummaryResponse student, {
  List<VisitWithLessonResponse> visits = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      studentListControllerProvider.overrideWith(
        () => _FakeStudentListController([student]),
      ),
      studentLessonsProvider.overrideWith2(
        (id) => _FakeStudentLessonsController(id, visits),
      ),
      studentPaymentsControllerProvider.overrideWith2(
        _FakeStudentPaymentsController.new,
      ),
      groupListControllerProvider.overrideWith(_FakeGroupListController.new),
      groupStudentsProvider.overrideWith2(_FakeGroupStudentsController.new),
      studentReportProvider.overrideWith2(_FakeStudentReportController.new),
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

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets(
    'the create button creates the individual lesson of the student',
    (tester) async {
      await _pumpPage(tester, _studentWithoutGroup);

      expect(find.byType(CreateLessonButton), findsOneWidget);

      await tester.tap(find.byType(CreateLessonButton));
      await tester.pumpAndSettle();

      final page = tester.widget<StudentLessonPage>(
        find.byType(StudentLessonPage),
      );
      expect(page.studentId, _studentId);
      expect(page.lesson, isNull);
    },
  );

  testWidgets(
    'the calendar of a group keeps the button of its lessons and opens the group lesson with the group name in the title',
    (tester) async {
      await _pumpPage(tester, _studentWithGroup);

      expect(find.byType(CreateLessonButton), findsOneWidget);

      await tester.tap(find.byType(CreateLessonButton));
      await tester.pumpAndSettle();

      expect(find.byType(LessonPage), findsOneWidget);
      expect(
        find.text(t.lessons.groupLessonTitle(name: _group.name)),
        findsOneWidget,
      );
    },
  );

  testWidgets('the app bar menu opens the report of the student', (
    tester,
  ) async {
    await _pumpPage(tester, _studentWithGroup);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.groups.report));
    await tester.pumpAndSettle();

    expect(find.byType(StudentReportBottomSheet), findsOneWidget);
    expect(find.widgetWithText(TextField, t.month), findsOneWidget);
  });

  testWidgets('the app bar menu opens the add lesson page', (tester) async {
    await _pumpPage(tester, _studentWithGroup);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.lessons.title));
    await tester.pumpAndSettle();

    expect(find.byType(StudentLessonPage), findsOneWidget);
    final page = tester.widget<StudentLessonPage>(
      find.byType(StudentLessonPage),
    );
    expect(page.studentId, _studentId);
    expect(page.studentName, _studentWithGroup.fullName);
    expect(page.lesson, isNull);
  });

  testWidgets(
    'merged header displays large name and badges when unscrolled, and collapses when scrolled',
    (tester) async {
      final studentWithStatus = StudentSummaryResponse(
        id: _studentId,
        fullName: 'Anna Smirnova',
        createdAt: DateTime(2025, 8, 22),
        free: false,
        statuses: const [StudentStatus.paid],
      );

      await _pumpPage(tester, studentWithStatus);

      // Unscrolled:
      // Large name is visible
      expect(find.text('Anna Smirnova'), findsOneWidget);
      // Status badge is visible
      expect(find.text(t.students.status.paid), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);

      // Refresh indicator edgeOffset is under the header
      final indicator = tester.widget<CustomMaterialIndicator>(
        find.byType(CustomMaterialIndicator),
      );
      expect(
        indicator.edgeOffset,
        greaterThan(StudentHeaderDelegate.contentHeight),
      );

      // Scroll down to collapse header
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Scrolled:
      expect(find.text('Anna Smirnova'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    },
  );

  testWidgets(
    'allows only two stable versions: snaps to full or short when scroll finishes',
    (tester) async {
      await _pumpPage(tester, _studentWithGroup);

      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );

      // Drag slightly (30px) and release -> should snap back to 0 (Full)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -30));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, equals(0.0));

      // Drag past midpoint (90px) and release -> should snap to short (contentHeight)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -90));
      await tester.pumpAndSettle();
      expect(
        scrollable.position.pixels,
        equals(StudentHeaderDelegate.contentHeight),
      );
    },
  );

  testWidgets(
    'tapping a day with 1 individual lesson opens the lesson directly without bottom sheet',
    (tester) async {
      final today = DateTime.now();
      final lesson = LessonResponse(
        id: 'ind-lesson-1',
        date: today,
        createdAt: today,
      );

      await _pumpPage(
        tester,
        _studentWithoutGroup,
        visits: [_visit(lesson: lesson)],
      );

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();

      expect(find.byType(StudentDayLessonsBottomSheet), findsNothing);
      expect(find.byType(StudentLessonPage), findsOneWidget);
      final page = tester.widget<StudentLessonPage>(
        find.byType(StudentLessonPage),
      );
      expect(page.lesson?.id, 'ind-lesson-1');
    },
  );

  testWidgets(
    'tapping a day with multiple individual lessons opens the bottom sheet',
    (tester) async {
      final today = DateTime.now();
      final lesson1 = LessonResponse(
        id: 'ind-lesson-1',
        date: today,
        createdAt: today,
      );
      final lesson2 = LessonResponse(
        id: 'ind-lesson-2',
        date: today,
        createdAt: today.add(const Duration(hours: 1)),
      );

      await _pumpPage(
        tester,
        _studentWithoutGroup,
        visits: [
          _visit(lesson: lesson1),
          _visit(lesson: lesson2),
        ],
      );

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();

      expect(find.byType(StudentDayLessonsBottomSheet), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ind-lesson-1')));
      await tester.pumpAndSettle();

      expect(find.byType(StudentLessonPage), findsOneWidget);
      final page = tester.widget<StudentLessonPage>(
        find.byType(StudentLessonPage),
      );
      expect(page.lesson?.id, 'ind-lesson-1');
    },
  );

  testWidgets(
    'tapping a day with 1 group lesson opens the lesson directly without bottom sheet',
    (tester) async {
      final today = DateTime.now();
      final lesson = LessonResponse(
        id: 'grp-lesson-1',
        date: today,
        createdAt: today,
        groupId: _group.id,
      );

      await _pumpPage(
        tester,
        _studentWithGroup,
        visits: [_visit(lesson: lesson)],
      );

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();

      expect(find.byType(StudentDayLessonsBottomSheet), findsNothing);
      expect(find.byType(LessonPage), findsOneWidget);
      final page = tester.widget<LessonPage>(find.byType(LessonPage));
      expect(page.lesson?.id, 'grp-lesson-1');
    },
  );

  testWidgets(
    'tapping a day with multiple group lessons opens the bottom sheet',
    (tester) async {
      final today = DateTime.now();
      final lesson1 = LessonResponse(
        id: 'grp-lesson-1',
        date: today,
        createdAt: today,
        groupId: _group.id,
      );
      final lesson2 = LessonResponse(
        id: 'grp-lesson-2',
        date: today,
        createdAt: today.add(const Duration(hours: 1)),
        groupId: _group.id,
      );

      await _pumpPage(
        tester,
        _studentWithGroup,
        visits: [
          _visit(lesson: lesson1),
          _visit(lesson: lesson2),
        ],
      );

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();

      expect(find.byType(StudentDayLessonsBottomSheet), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('grp-lesson-1')));
      await tester.pumpAndSettle();

      expect(find.byType(LessonPage), findsOneWidget);
      final page = tester.widget<LessonPage>(find.byType(LessonPage));
      expect(page.lesson?.id, 'grp-lesson-1');
    },
  );
}
