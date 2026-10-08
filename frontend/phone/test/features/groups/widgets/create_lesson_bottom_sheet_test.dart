import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/groups/widgets/create_lesson_bottom_sheet.dart';
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
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

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

/// Serves the students of the group and the lessons of the calendar.
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

/// Records the created lessons.
class _FakeLessonClient implements LessonControllerClient {
  final List<CreateLessonRequest> createBodies = [];

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
  Future<List<LessonResponse>> getLessons() => throw UnimplementedError();

  @override
  Future<LessonResponse> getLesson({required String lessonId}) =>
      throw UnimplementedError();

  @override
  Future<LessonDetailsResponse> getLessonDetails({required String lessonId}) =>
      throw UnimplementedError();

  @override
  Future<LessonResponse> updateLesson({
    required String lessonId,
    required UpdateLessonRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteLesson({required String lessonId}) =>
      throw UnimplementedError();
}

Widget _wrap(
  Widget child, {
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
                AppBottomSheet.show(context: context, child: child),
            child: const Text('open sheet'),
          ),
        ),
      ),
    ),
  ),
);

/// Opens the sheet the same way the group page does.
Future<void> _openSheet(
  WidgetTester tester, {
  List<GroupStudentSummaryResponse>? students,
  _FakeLessonClient? lessonClient,
}) async {
  await tester.pumpWidget(
    _wrap(
      const CreateLessonBottomSheet(groupId: 'group-1'),
      groupClient: _FakeGroupClient(students ?? [_ivan, _anna]),
      lessonClient: lessonClient ?? _FakeLessonClient(),
    ),
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

String _expectedCount(int present, int total) =>
    t.lessons.presentCount(present: present, total: total);

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day.$month.${date.year}';
}

bool _isChecked(WidgetTester tester, String fullName) => tester
    .widget<CheckboxListTile>(
      find.ancestor(
        of: find.text(fullName),
        matching: find.byType(CheckboxListTile),
      ),
    )
    .value!;

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the sheet starts on today without a picked student', (
    tester,
  ) async {
    await _openSheet(tester);

    expect(find.text(t.lessons.createLesson), findsOneWidget);
    expect(find.text(t.lessons.date), findsOneWidget);
    expect(find.text(_formatDate(DateTime.now())), findsOneWidget);

    expect(find.text(t.lessons.selectAll), findsOneWidget);
    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(find.text('Anna Smirnova'), findsOneWidget);

    expect(_isChecked(tester, 'Ivan Petrov'), isFalse);
    expect(_isChecked(tester, 'Anna Smirnova'), isFalse);
    expect(find.text(_expectedCount(0, 2)), findsOneWidget);
  });

  testWidgets('picking a student updates the present counter', (tester) async {
    await _openSheet(tester);

    await tester.tap(find.text('Ivan Petrov'));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(find.text(_expectedCount(1, 2)), findsOneWidget);
    expect(find.text(t.lessons.selectAll), findsOneWidget);

    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

    expect(find.text(_expectedCount(2, 2)), findsOneWidget);
    expect(find.text(t.lessons.deselectAll), findsOneWidget);

    await tester.tap(find.text('Ivan Petrov'));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Ivan Petrov'), isFalse);
    expect(find.text(_expectedCount(1, 2)), findsOneWidget);
  });

  testWidgets('select all picks and clears everybody', (tester) async {
    await _openSheet(tester);

    await tester.tap(find.text(t.lessons.selectAll));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Ivan Petrov'), isTrue);
    expect(_isChecked(tester, 'Anna Smirnova'), isTrue);
    expect(find.text(_expectedCount(2, 2)), findsOneWidget);

    await tester.tap(find.text(t.lessons.deselectAll));
    await tester.pumpAndSettle();

    expect(_isChecked(tester, 'Ivan Petrov'), isFalse);
    expect(_isChecked(tester, 'Anna Smirnova'), isFalse);
    expect(find.text(_expectedCount(0, 2)), findsOneWidget);
  });

  testWidgets('the date field opens the system date picker', (tester) async {
    await _openSheet(tester);

    await tester.tap(find.text(_formatDate(DateTime.now())));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('saving sends the picked students as regular present visits', (
    tester,
  ) async {
    final lessonClient = _FakeLessonClient();

    await _openSheet(tester, lessonClient: lessonClient);

    await tester.tap(find.text('Anna Smirnova'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.create));
    await tester.pump();

    // The lessons of the group are reloaded with a delay.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(lessonClient.createBodies, hasLength(1));

    final body = lessonClient.createBodies.single;
    final now = DateTime.now();

    expect(body.groupId, 'group-1');
    expect(body.date, DateTime(now.year, now.month, now.day));
    expect(body.students, hasLength(1));
    expect(body.students!.single.studentId, 'student-2');
    expect(body.students!.single.status, VisitStatus.present);
    expect(body.students!.single.type, VisitType.regular);

    expect(find.byType(CreateLessonBottomSheet), findsNothing);
  });

  testWidgets('a group without students cannot save a lesson', (tester) async {
    await _openSheet(tester, students: const <GroupStudentSummaryResponse>[]);

    expect(find.text(t.lessons.noStudents), findsOneWidget);
    expect(find.text(t.lessons.selectAll), findsNothing);
    expect(find.text(_expectedCount(0, 0)), findsNothing);

    final saveButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, t.create),
    );

    expect(saveButton.onPressed, isNull);
  });
}
