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
import 'package:phone/generated/models/student_response.dart';
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
  createdAt: DateTime(2025),
  free: false,
  statuses: const [],
);

final GroupStudentSummaryResponse _anna = GroupStudentSummaryResponse(
  id: 'student-2',
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025),
  free: false,
  statuses: const [],
);

final StudentResponse _heroLeft = StudentResponse(
  id: 'student-3',
  fullName: 'Hero Left',
  createdAt: DateTime(2025),
  free: false,
);

StudentResponse _student(GroupStudentSummaryResponse groupStudent) =>
    StudentResponse(
      id: groupStudent.id,
      fullName: groupStudent.fullName,
      createdAt: groupStudent.createdAt,
      free: groupStudent.free,
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

class _FakeLessonClient implements LessonControllerClient {
  final List<VisitResponse> visits;

  final List<StudentResponse> students;

  final List<CreateLessonRequest> createBodies = [];
  final List<UpdateLessonRequest> updateBodies = [];
  final List<String> updatedLessonIds = [];
  final List<String> deletedLessonIds = [];

  new({this.visits = const [], this.students = const []});

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
    students: students,
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
}

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

Finder _rowOf(String fullName) =>
    find.ancestor(of: find.text(fullName), matching: find.byType(ListTile));

Finder _checkboxOf(String fullName) =>
    find.descendant(of: _rowOf(fullName), matching: find.byType(Checkbox));

Finder _markOf(String fullName) =>
    find.descendant(of: _rowOf(fullName), matching: find.byType(Icon));

bool _isChecked(WidgetTester tester, String fullName) =>
    _checkboxOf(fullName).evaluate().isNotEmpty
    ? tester.widget<Checkbox>(_checkboxOf(fullName)).value!
    : tester.widget<Icon>(_markOf(fullName)).icon == Icons.check_box;

bool _isEnabled(WidgetTester tester, String fullName) =>
    tester.widget<Checkbox>(_checkboxOf(fullName)).onChanged != null;

Future<void> _toggle(WidgetTester tester, String fullName) async {
  await tester.tap(_checkboxOf(fullName));
  await tester.pumpAndSettle();
}

Future<void> _openAttendanceSheet(WidgetTester tester, String fullName) async {
  await tester.longPress(find.text(fullName));
  await tester.pumpAndSettle();
}

bool _isActionEnabled(WidgetTester tester, String label) =>
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, label))
        .onPressed !=
    null;

Future<void> _startEditing(WidgetTester tester) =>
    _pickMenuItem(tester, t.edit);

Future<void> _pickMenuItem(WidgetTester tester, String label) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();

  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _pressAction(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();

  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) => _pressAction(tester, t.create);

Future<void> _update(WidgetTester tester) => _pressAction(tester, t.update);

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
    expect(find.text(t.create), findsOneWidget);
  });

  testWidgets('picking students keeps the create action available', (
    tester,
  ) async {
    await _openPage(tester);

    await _toggle(tester, 'Ivan Petrov');

    expect(_isChecked(tester, 'Ivan Petrov'), isFalse);
    expect(_isActionEnabled(tester, t.create), isTrue);
    expect(find.text(t.lessons.selectAll), findsOneWidget);

    await tester.tap(find.text(t.lessons.selectAll));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Anna Smirnova'), isTrue);
    expect(find.text(t.lessons.deselectAll), findsOneWidget);

    await tester.tap(find.text(t.lessons.deselectAll));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Ivan Petrov'), isFalse);
    expect(_isChecked(tester, 'Anna Smirnova'), isFalse);
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

    await _save(tester);

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

  testWidgets('a stored lesson opens read-only with its attendance', (
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

    expect(_checkboxOf('Ivan Petrov'), findsNothing);
    expect(_markOf('Ivan Petrov'), findsOneWidget);

    final colorScheme = Theme.of(tester.element(find.text('Ivan Petrov')))
        .colorScheme;

    expect(
      tester.widget<Icon>(_markOf('Ivan Petrov')).color,
      colorScheme.primary,
    );
    expect(
      tester.widget<Icon>(_markOf('Anna Smirnova')).color,
      colorScheme.onSurfaceVariant,
    );

    final dateText = tester.widget<Text>(find.text('08.10.2026'));
    expect(dateText.style?.color, isNull);

    expect(find.text(t.update), findsNothing);
  });

  testWidgets('picking Edit turns a stored lesson into the form', (
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

    await _startEditing(tester);

    expect(_isEnabled(tester, 'Ivan Petrov'), isTrue);

    expect(_isActionEnabled(tester, t.update), isFalse);
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

    await _startEditing(tester);

    expect(_isActionEnabled(tester, t.update), isFalse);

    await _toggle(tester, 'Anna Smirnova');

    expect(_isActionEnabled(tester, t.update), isTrue);

    await _toggle(tester, 'Anna Smirnova');

    expect(_isActionEnabled(tester, t.update), isFalse);
  });

  testWidgets('a student who left the group keeps the row of the lesson', (
    tester,
  ) async {
    final lessonClient = _FakeLessonClient(
      visits: [
        _visit(studentId: 'student-1', status: VisitStatus.present),
        _visit(studentId: 'student-3', status: VisitStatus.present),
      ],
      students: [_student(_ivan), _heroLeft],
    );

    await _openPage(
      tester,
      students: [_ivan, _anna],
      lesson: _lesson,
      lessonClient: lessonClient,
    );

    expect(find.text('Hero Left'), findsOneWidget);
    expect(_isChecked(tester, 'Hero Left'), isTrue);

    await _startEditing(tester);

    expect(find.text(t.update), findsOneWidget);

    await _toggle(tester, 'Ivan Petrov');

    await _update(tester);

    expect(
      lessonClient.updateBodies.single.students!.map(
        (student) => student.studentId,
      ),
      ['student-1', 'student-3'],
    );
  });

  testWidgets('editing a stored lesson updates it', (tester) async {
    final lessonClient = _FakeLessonClient(
      visits: [
        _visit(studentId: 'student-1', status: VisitStatus.present),
        _visit(studentId: 'student-2', status: VisitStatus.absent),
      ],
    );

    await _openPage(tester, lesson: _lesson, lessonClient: lessonClient);

    await _startEditing(tester);

    expect(_isEnabled(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isActionEnabled(tester, t.update), isFalse);

    await _toggle(tester, 'Anna Smirnova');

    expect(find.text(t.update), findsOneWidget);

    await _update(tester);

    expect(lessonClient.updatedLessonIds, ['lesson-1']);
    expect(lessonClient.updateBodies.single.date, _lessonDate);
    expect(lessonClient.updateBodies.single.students, hasLength(2));

    expect(find.byType(LessonPage), findsNothing);
  });

  testWidgets('the menu of a stored lesson offers editing and deleting', (
    tester,
  ) async {
    await _openPage(tester, lesson: _lesson);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text(t.edit), findsOneWidget);
    expect(find.text(t.delete), findsOneWidget);
  });

  testWidgets('the form of a stored lesson offers no menu', (tester) async {
    await _openPage(tester, lesson: _lesson);

    await _startEditing(tester);

    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('deleting a stored lesson asks for confirmation', (tester) async {
    final lessonClient = _FakeLessonClient();

    await _openPage(tester, lesson: _lesson, lessonClient: lessonClient);

    await _pickMenuItem(tester, t.delete);

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
      find.widgetWithText(TextButton, t.create),
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

    expect(_markOf('Ivan Petrov'), findsOneWidget);
    expect(_checkboxOf('Anna Smirnova'), findsNothing);
    expect(find.text(t.lessons.notMarked), findsOneWidget);

    await tester.tap(find.text(t.lessons.notMarked));
    await tester.pumpAndSettle();

    expect(find.text('Anna Smirnova'), findsOneWidget);
    expect(_checkboxOf('Anna Smirnova'), findsNothing);
    expect(_markOf('Anna Smirnova'), findsNothing);
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

    await _startEditing(tester);

    await tester.tap(find.text(t.lessons.notMarked));
    await tester.pumpAndSettle();

    await _openAttendanceSheet(tester, 'Anna Smirnova');

    expect(find.text(t.lessons.regular), findsNothing);

    await tester.tap(find.text(t.lessons.present));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Anna Smirnova'), isTrue);
    expect(_isActionEnabled(tester, t.update), isTrue);
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

    await _startEditing(tester);

    await _openAttendanceSheet(tester, 'Ivan Petrov');

    expect(find.text(t.lessons.regular), findsOneWidget);
    expect(find.text(t.lessons.free), findsOneWidget);

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
      createdAt: DateTime(2025),
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

    expect(find.text(t.lessons.regular), findsNothing);

    await tester.tap(find.text(t.lessons.absent));
    await tester.pumpAndSettle();

    await _save(tester);

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
