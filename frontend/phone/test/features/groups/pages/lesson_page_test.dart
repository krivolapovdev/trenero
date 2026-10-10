import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/groups/controllers/lesson_mutation_controller.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/lesson_controller/lesson_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

final DateTime _lessonDate = DateTime(2026, 10, 8);

final GroupStudentSummaryResponse _ivan = GroupStudentSummaryResponse(
  id: 'student-1',
  fullName: 'Ivan Petrov',
  createdAt: DateTime(2025, 1, 1),
  free: false,
  statuses: const [],
);

final GroupStudentSummaryResponse _anna = GroupStudentSummaryResponse(
  id: 'student-2',
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 1, 1),
  free: false,
  statuses: const [],
);

final LessonResponse _lesson = LessonResponse(
  id: 'lesson-1',
  date: _lessonDate,
  createdAt: DateTime(2026, 10, 8),
  groupId: 'group-1',
);

VisitResponse _visit({
  required String studentId,
  required VisitStatus status,
}) => VisitResponse(
  id: 'visit-$studentId',
  status: status,
  type: VisitType.regular,
  lessonId: _lesson.id,
  studentId: studentId,
  createdAt: DateTime(2026, 10, 8),
);

/// Serves the students of the group.
class _FakeGroupClient implements GroupControllerClient {
  final List<GroupStudentSummaryResponse> students;

  new(this.students);

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) async => students;

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) async => const [];

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() =>
      throw UnimplementedError();

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
}

/// Records the lessons that are created, updated and deleted.
class _FakeLessonClient implements LessonControllerClient {
  final List<VisitResponse> visits;
  final List<CreateLessonRequest> createBodies = [];
  final List<UpdateLessonRequest> updateBodies = [];
  final List<String> updatedLessonIds = [];
  final List<String> deletedLessonIds = [];

  new({this.visits = const []});

  @override
  Future<LessonResponse> createLesson({
    required CreateLessonRequest body,
  }) async {
    createBodies.add(body);

    return LessonResponse(
      id: 'lesson-1',
      date: body.date,
      createdAt: DateTime(2026, 10, 8),
      groupId: body.groupId,
    );
  }

  @override
  Future<LessonDetailsResponse> getLessonDetails({
    required String lessonId,
  }) async => LessonDetailsResponse(
    id: lessonId,
    date: _lessonDate,
    createdAt: DateTime(2026, 10, 8),
    groupId: 'group-1',
    studentVisits: visits,
  );

  @override
  Future<LessonResponse> updateLesson({
    required String lessonId,
    required UpdateLessonRequest body,
  }) async {
    updatedLessonIds.add(lessonId);
    updateBodies.add(body);

    return LessonResponse(
      id: lessonId,
      date: body.date ?? _lessonDate,
      createdAt: DateTime(2026, 10, 8),
      groupId: 'group-1',
    );
  }

  @override
  Future<void> deleteLesson({required String lessonId}) async {
    deletedLessonIds.add(lessonId);
  }

  @override
  Future<List<LessonResponse>> getLessons() => throw UnimplementedError();

  @override
  Future<LessonResponse> getLesson({required String lessonId}) =>
      throw UnimplementedError();
}

/// Counts the visits that are fetched for a student, so a background refresh of
/// a page can be told from a page that was never opened.
class _FakeStudentClient implements StudentControllerClient {
  final Map<String, int> visitCalls = {};

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    DateTime? from,
    DateTime? to,
  }) async {
    visitCalls[studentId] = (visitCalls[studentId] ?? 0) + 1;
    return const [];
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(
  Widget page, {
  required _FakeGroupClient groupClient,
  required _FakeLessonClient lessonClient,
}) => ProviderScope(
  overrides: [
    groupServiceProvider.overrideWithValue(groupClient),
    lessonServiceProvider.overrideWithValue(lessonClient),
  ],
  child: TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => page)),
            child: const Text('open page'),
          ),
        ),
      ),
    ),
  ),
);

/// Opens the page the same way the group page and the calendar do.
Future<void> _openPage(
  WidgetTester tester, {
  List<GroupStudentSummaryResponse>? students,
  _FakeLessonClient? lessonClient,
  LessonResponse? lesson,
  DateTime? date,
}) async {
  await tester.pumpWidget(
    _wrap(
      LessonPage(groupId: 'group-1', date: date ?? _lessonDate, lesson: lesson),
      groupClient: _FakeGroupClient(students ?? [_ivan, _anna]),
      lessonClient: lessonClient ?? _FakeLessonClient(),
    ),
  );

  await tester.tap(find.text('open page'));
  await tester.pumpAndSettle();
}

/// The label of the app bar action: `[2/2]`, the students that attended over
/// the students of the lesson.
String _label(int present, int total) => '[$present/$total]';

/// The checkbox of the row of [fullName]. A student that is left unmarked has
/// no checkbox, so this throws for them.
Finder _checkboxOf(String fullName) => find.descendant(
  of: find.ancestor(of: find.text(fullName), matching: find.byType(ListTile)),
  matching: find.byType(Checkbox),
);

bool _isChecked(WidgetTester tester, String fullName) =>
    tester.widget<Checkbox>(_checkboxOf(fullName)).value!;

bool _isEnabled(WidgetTester tester, String fullName) =>
    tester.widget<Checkbox>(_checkboxOf(fullName)).onChanged != null;

/// Taps the checkbox of the row of [fullName], the way a user marks a student
/// present or absent.
Future<void> _toggle(WidgetTester tester, String fullName) async {
  await tester.tap(_checkboxOf(fullName));
  await tester.pumpAndSettle();
}

/// Opens the attendance sheet of the row of [fullName] the way a user does,
/// with a long press.
Future<void> _openAttendanceSheet(WidgetTester tester, String fullName) async {
  await tester.longPress(find.text(fullName));
  await tester.pumpAndSettle();
}

bool _isActionEnabled(WidgetTester tester, String label) =>
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, label))
        .onPressed !=
    null;

/// Picks an entry of the page menu.
Future<void> _pickMenuItem(WidgetTester tester, String label) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();

  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _pressAction(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();

  // The lessons of the group are reloaded with a delay.
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> _save(
  WidgetTester tester, {
  required int present,
  required int total,
}) => _pressAction(tester, _label(present, total));

Future<void> _update(
  WidgetTester tester, {
  required int present,
  required int total,
}) => _pressAction(tester, _label(present, total));

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('a new lesson starts on the day with everybody present', (
    tester,
  ) async {
    await _openPage(tester);

    expect(find.text(t.lessons.groupLesson), findsOneWidget);
    expect(find.text('08.10.2026'), findsOneWidget);
    expect(find.text(t.lessons.deselectAll), findsOneWidget);

    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Anna Smirnova'), isTrue);
    expect(find.text(_label(2, 2)), findsOneWidget);
  });

  testWidgets('picking students updates the action label', (tester) async {
    await _openPage(tester);

    await _toggle(tester, 'Ivan Petrov');

    expect(_isChecked(tester, 'Ivan Petrov'), isFalse);
    expect(find.text(_label(1, 2)), findsOneWidget);
    expect(find.text(t.lessons.selectAll), findsOneWidget);

    await tester.tap(find.text(t.lessons.selectAll));
    await tester.pumpAndSettle();

    expect(find.text(_label(2, 2)), findsOneWidget);

    await tester.tap(find.text(t.lessons.deselectAll));
    await tester.pumpAndSettle();

    expect(find.text(_label(0, 2)), findsOneWidget);
    expect(find.text(t.lessons.selectAll), findsOneWidget);
  });

  testWidgets('saving sends a visit for every student of the group', (
    tester,
  ) async {
    final lessonClient = _FakeLessonClient();

    await _openPage(
      tester,
      lessonClient: lessonClient,
      date: DateTime(2026, 10, 8, 19, 24),
    );

    await _toggle(tester, 'Anna Smirnova');

    await _save(tester, present: 1, total: 2);

    expect(lessonClient.createBodies, hasLength(1));

    final body = lessonClient.createBodies.single;

    expect(body.groupId, 'group-1');
    expect(body.date, _lessonDate);
    expect(body.students, hasLength(2));
    expect(body.students![0].studentId, 'student-1');
    expect(body.students![0].status, VisitStatus.present);
    expect(body.students![0].type, VisitType.regular);
    expect(body.students![1].studentId, 'student-2');
    expect(body.students![1].status, VisitStatus.absent);

    expect(find.byType(LessonPage), findsNothing);
  });

  testWidgets('a stored lesson opens for editing with its attendance', (
    tester,
  ) async {
    await _openPage(
      tester,
      lesson: _lesson,
      lessonClient: _FakeLessonClient(
        visits: [
          _visit(studentId: 'student-1', status: VisitStatus.present),
          _visit(studentId: 'student-2', status: VisitStatus.absent),
        ],
      ),
    );

    expect(find.text(t.lessons.groupLesson), findsOneWidget);
    expect(find.text('08.10.2026'), findsOneWidget);

    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Anna Smirnova'), isFalse);
    expect(_isEnabled(tester, 'Ivan Petrov'), isTrue);

    // Nothing changed yet, so there is nothing to update.
    expect(_isActionEnabled(tester, _label(1, 2)), isFalse);
  });

  testWidgets('the update button waits for the attendance to change', (
    tester,
  ) async {
    await _openPage(
      tester,
      lesson: _lesson,
      lessonClient: _FakeLessonClient(
        visits: [
          _visit(studentId: 'student-1', status: VisitStatus.present),
          _visit(studentId: 'student-2', status: VisitStatus.absent),
        ],
      ),
    );

    expect(_isActionEnabled(tester, _label(1, 2)), isFalse);

    await _toggle(tester, 'Anna Smirnova');

    expect(_isActionEnabled(tester, _label(2, 2)), isTrue);

    // Picking the same students again leaves nothing to update.
    await _toggle(tester, 'Anna Smirnova');

    expect(_isActionEnabled(tester, _label(1, 2)), isFalse);
  });

  testWidgets('editing a stored lesson updates it', (tester) async {
    final lessonClient = _FakeLessonClient(
      visits: [
        _visit(studentId: 'student-1', status: VisitStatus.present),
        _visit(studentId: 'student-2', status: VisitStatus.absent),
      ],
    );

    await _openPage(tester, lesson: _lesson, lessonClient: lessonClient);

    expect(_isEnabled(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isActionEnabled(tester, _label(1, 2)), isFalse);

    await _toggle(tester, 'Anna Smirnova');

    expect(find.text(_label(2, 2)), findsOneWidget);

    await _update(tester, present: 2, total: 2);

    expect(lessonClient.updatedLessonIds, ['lesson-1']);
    expect(lessonClient.updateBodies.single.date, _lessonDate);
    expect(lessonClient.updateBodies.single.students, hasLength(2));

    expect(find.byType(LessonPage), findsNothing);
  });

  testWidgets('the menu only offers deleting a stored lesson', (tester) async {
    await _openPage(tester, lesson: _lesson);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
  });

  testWidgets('deleting a stored lesson asks for confirmation', (tester) async {
    final lessonClient = _FakeLessonClient();

    await _openPage(tester, lesson: _lesson, lessonClient: lessonClient);

    await _pickMenuItem(tester, 'Delete');

    expect(find.text(t.lessons.deleteLesson), findsOneWidget);

    await tester.tap(find.text(t.delete));
    await tester.pump();

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(lessonClient.deletedLessonIds, ['lesson-1']);
    expect(find.byType(LessonPage), findsNothing);
  });

  testWidgets('a group without students cannot create a lesson', (
    tester,
  ) async {
    await _openPage(tester, students: const <GroupStudentSummaryResponse>[]);

    expect(find.text(t.lessons.noStudents), findsOneWidget);

    final saveButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, _label(0, 0)),
    );

    expect(saveButton.onPressed, isNull);
  });

  testWidgets('a student without a visit is folded into the not marked list', (
    tester,
  ) async {
    await _openPage(
      tester,
      lesson: _lesson,
      lessonClient: _FakeLessonClient(
        visits: [_visit(studentId: 'student-1', status: VisitStatus.present)],
      ),
    );

    // Anna has no visit for the lesson, so she is not in the main list.
    expect(_checkboxOf('Ivan Petrov'), findsOneWidget);
    expect(_checkboxOf('Anna Smirnova'), findsNothing);
    expect(find.text(t.lessons.notMarked), findsOneWidget);

    // She waits under the accordion, without a checkbox.
    await tester.tap(find.text(t.lessons.notMarked));
    await tester.pumpAndSettle();

    expect(find.text('Anna Smirnova'), findsOneWidget);
    expect(_checkboxOf('Anna Smirnova'), findsNothing);
  });

  testWidgets('a folded student can be marked through the sheet', (
    tester,
  ) async {
    await _openPage(
      tester,
      lesson: _lesson,
      lessonClient: _FakeLessonClient(
        visits: [_visit(studentId: 'student-1', status: VisitStatus.present)],
      ),
    );

    await tester.tap(find.text(t.lessons.notMarked));
    await tester.pumpAndSettle();

    await _openAttendanceSheet(tester, 'Anna Smirnova');

    // She is unmarked, so the type is not offered yet.
    expect(find.text(t.lessons.regular), findsNothing);

    // Picking a status closes the sheet and marks her straight away.
    await tester.tap(find.text(t.lessons.present));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Anna Smirnova'), isTrue);
    expect(_isActionEnabled(tester, _label(2, 2)), isTrue);
  });

  testWidgets('a marked student can pick a type from the sheet', (
    tester,
  ) async {
    await _openPage(
      tester,
      lesson: _lesson,
      lessonClient: _FakeLessonClient(
        visits: [_visit(studentId: 'student-1', status: VisitStatus.present)],
      ),
    );

    await _openAttendanceSheet(tester, 'Ivan Petrov');

    // A marked student picks a type next to the status.
    expect(find.text(t.lessons.regular), findsOneWidget);
    expect(find.text(t.lessons.free), findsOneWidget);

    // Picking a type closes the sheet and applies it straight away.
    await tester.tap(find.text(t.lessons.free));
    await tester.pumpAndSettle();

    expect(find.text(t.lessons.freeLesson), findsOneWidget);
  });

  testWidgets('a free student has no type to pick and stores a free lesson', (
    tester,
  ) async {
    final freeAnna = GroupStudentSummaryResponse(
      id: 'student-2',
      fullName: 'Anna Smirnova',
      createdAt: DateTime(2025, 1, 1),
      free: true,
      statuses: const [],
    );
    final lessonClient = _FakeLessonClient();

    await _openPage(
      tester,
      students: [_ivan, freeAnna],
      lessonClient: lessonClient,
    );

    await _openAttendanceSheet(tester, 'Anna Smirnova');

    // The type of a free student is pinned, so it is not offered.
    expect(find.text(t.lessons.regular), findsNothing);

    // Picking another status closes the sheet, still storing a free lesson.
    await tester.tap(find.text(t.lessons.absent));
    await tester.pumpAndSettle();

    await _save(tester, present: 1, total: 2);

    final body = lessonClient.createBodies.single;

    expect(body.students![1].studentId, 'student-2');
    expect(body.students![1].status, VisitStatus.absent);
    expect(body.students![1].type, VisitType.free);
  });

  test(
    'saving a group lesson refreshes the student pages in the background',
    () async {
      final lessonClient = _FakeLessonClient();
      final studentClient = _FakeStudentClient();

      final container = ProviderContainer(
        overrides: [
          groupServiceProvider.overrideWithValue(
            _FakeGroupClient([_ivan, _anna]),
          ),
          lessonServiceProvider.overrideWithValue(lessonClient),
          studentServiceProvider.overrideWithValue(studentClient),
        ],
      );
      addTearDown(container.dispose);

      // The page of Ivan is loaded, the one of Anna is not.
      await container.read(studentLessonsProvider('student-1').future);
      expect(studentClient.visitCalls['student-1'], 1);

      final isSaved = await container
          .read(lessonMutationControllerProvider.notifier)
          .createLesson(
            groupId: 'group-1',
            date: _lessonDate,
            students: [_ivan, _anna],
            attendance: {
              'student-1': const LessonAttendance(
                status: VisitStatus.present,
                type: VisitType.regular,
              ),
            },
          );

      expect(isSaved, isTrue);

      // The refresh runs in the background, so it is given a moment to finish.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(lessonClient.createBodies, hasLength(1));
      expect(
        studentClient.visitCalls['student-1'],
        greaterThan(1),
        reason: 'the loaded student page is refreshed',
      );
      expect(
        studentClient.visitCalls['student-2'],
        isNull,
        reason: 'a student page that was never opened is not fetched',
      );
    },
  );
}
