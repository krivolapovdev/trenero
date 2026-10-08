import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
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
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

final DateTime _lessonDate = DateTime(2026, 10, 8);

final GroupStudentSummaryResponse _ivan = GroupStudentSummaryResponse(
  id: 'student-1',
  fullName: 'Ivan Petrov',
  createdAt: DateTime(2025, 1, 1),
  statuses: const [],
);

final GroupStudentSummaryResponse _anna = GroupStudentSummaryResponse(
  id: 'student-2',
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 1, 1),
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

String _label(String action, int present, int total) =>
    '$action $present/$total';

bool _isChecked(WidgetTester tester, String fullName) => tester
    .widget<CheckboxListTile>(
      find.ancestor(
        of: find.text(fullName),
        matching: find.byType(CheckboxListTile),
      ),
    )
    .value!;

bool _isEnabled(WidgetTester tester, String fullName) =>
    tester
        .widget<CheckboxListTile>(
          find.ancestor(
            of: find.text(fullName),
            matching: find.byType(CheckboxListTile),
          ),
        )
        .onChanged !=
    null;

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
}) => _pressAction(tester, _label(t.create, present, total));

Future<void> _update(
  WidgetTester tester, {
  required int present,
  required int total,
}) => _pressAction(tester, _label(t.update, present, total));

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('a new lesson starts on the day with everybody present', (
    tester,
  ) async {
    await _openPage(tester);

    expect(find.text(t.lessons.createLesson), findsOneWidget);
    expect(find.text('08.10.2026'), findsOneWidget);
    expect(find.text(t.lessons.deselectAll), findsOneWidget);

    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Anna Smirnova'), isTrue);
    expect(find.text(_label(t.create, 2, 2)), findsOneWidget);
  });

  testWidgets('picking students updates the action label', (tester) async {
    await _openPage(tester);

    await tester.tap(find.text('Ivan Petrov'));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Ivan Petrov'), isFalse);
    expect(find.text(_label(t.create, 1, 2)), findsOneWidget);
    expect(find.text(t.lessons.selectAll), findsOneWidget);

    await tester.tap(find.text(t.lessons.selectAll));
    await tester.pumpAndSettle();

    expect(find.text(_label(t.create, 2, 2)), findsOneWidget);

    await tester.tap(find.text(t.lessons.deselectAll));
    await tester.pumpAndSettle();

    expect(find.text(_label(t.create, 0, 2)), findsOneWidget);
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

    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

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
    expect(body.students![1].status, VisitStatus.unmarked);

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
          _visit(studentId: 'student-2', status: VisitStatus.unmarked),
        ],
      ),
    );

    expect(find.text(t.lessons.title), findsOneWidget);
    expect(find.text('08.10.2026'), findsOneWidget);

    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Anna Smirnova'), isFalse);
    expect(_isEnabled(tester, 'Ivan Petrov'), isTrue);

    // Nothing changed yet, so there is nothing to update.
    expect(_isActionEnabled(tester, _label(t.update, 1, 2)), isFalse);
  });

  testWidgets('the update button waits for the attendance to change', (
    tester,
  ) async {
    await _openPage(
      tester,
      lesson: _lesson,
      lessonClient: _FakeLessonClient(
        visits: [_visit(studentId: 'student-1', status: VisitStatus.present)],
      ),
    );

    expect(_isActionEnabled(tester, _label(t.update, 1, 2)), isFalse);

    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

    expect(_isActionEnabled(tester, _label(t.update, 2, 2)), isTrue);

    // Picking the same students again leaves nothing to update.
    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

    expect(_isActionEnabled(tester, _label(t.update, 1, 2)), isFalse);
  });

  testWidgets('editing a stored lesson updates it', (tester) async {
    final lessonClient = _FakeLessonClient(
      visits: [_visit(studentId: 'student-1', status: VisitStatus.present)],
    );

    await _openPage(tester, lesson: _lesson, lessonClient: lessonClient);

    expect(_isEnabled(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isActionEnabled(tester, _label(t.update, 1, 2)), isFalse);

    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

    expect(find.text(_label(t.update, 2, 2)), findsOneWidget);

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
      find.widgetWithText(TextButton, _label(t.create, 0, 0)),
    );

    expect(saveButton.onPressed, isNull);
  });
}
