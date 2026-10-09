import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/lesson_controller/lesson_controller_client.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

const String _studentId = 'student-1';
const String _studentName = 'Ivan Petrov';

final DateTime _lessonDate = DateTime(2026, 10, 8);

/// An individual lesson has no group, only the student it is stored for.
final LessonResponse _lesson = LessonResponse(
  id: 'lesson-1',
  date: _lessonDate,
  createdAt: DateTime(2026, 10, 8),
);

VisitResponse _visit({VisitStatus status = VisitStatus.present}) =>
    VisitResponse(
      id: 'visit-$_studentId',
      status: status,
      type: VisitType.regular,
      lessonId: _lesson.id,
      studentId: _studentId,
      createdAt: DateTime(2026, 10, 8),
    );

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

/// Serves the student data the mutation controller reloads after a lesson.
class _FakeStudentClient implements StudentControllerClient {
  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
  }) async => const [];

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => [
    StudentSummaryResponse(
      id: _studentId,
      fullName: _studentName,
      createdAt: DateTime(2025, 1, 1),
      statuses: const [],
    ),
  ];

  @override
  Future<List<StudentResponse>> getStudents() => throw UnimplementedError();

  @override
  Future<StudentResponse> createStudent({required CreateStudentRequest body}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> getStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) => throw UnimplementedError();
}

Widget _wrap(
  Widget page, {
  required _FakeStudentClient studentClient,
  required _FakeLessonClient lessonClient,
}) => ProviderScope(
  overrides: [
    studentServiceProvider.overrideWithValue(studentClient),
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

/// Opens the page the same way the student page and the calendar do.
Future<void> _openPage(
  WidgetTester tester, {
  _FakeLessonClient? lessonClient,
  LessonResponse? lesson,
  DateTime? date,
}) async {
  await tester.pumpWidget(
    _wrap(
      StudentLessonPage(
        studentId: _studentId,
        studentName: _studentName,
        date: date ?? _lessonDate,
        lesson: lesson,
      ),
      studentClient: _FakeStudentClient(),
      lessonClient: lessonClient ?? _FakeLessonClient(),
    ),
  );

  await tester.tap(find.text('open page'));
  await tester.pumpAndSettle();
}

bool _isChecked(WidgetTester tester) =>
    tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value!;

bool _isAttendanceEnabled(WidgetTester tester) =>
    tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged !=
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
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('a new lesson starts on the day with the student present', (
    tester,
  ) async {
    await _openPage(tester);

    expect(find.text(t.lessons.individualLesson), findsOneWidget);
    expect(find.text('08.10.2026'), findsOneWidget);
    expect(find.text(_studentName), findsOneWidget);

    expect(_isChecked(tester), isTrue);
    expect(_isAttendanceEnabled(tester), isTrue);
    expect(_isActionEnabled(tester, t.create), isTrue);

    // A new lesson has nothing to delete yet.
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets('picking the attendance updates the checkbox', (tester) async {
    await _openPage(tester);

    await tester.tap(find.text(_studentName));
    await tester.pumpAndSettle();

    expect(_isChecked(tester), isFalse);
    expect(_isActionEnabled(tester, t.create), isTrue);
  });

  testWidgets('saving creates an individual lesson for the student', (
    tester,
  ) async {
    final lessonClient = _FakeLessonClient();

    await _openPage(tester, lessonClient: lessonClient);
    await _pressAction(tester, t.create);

    final body = lessonClient.createBodies.single;

    // The lesson belongs to no group, it only holds the single student.
    expect(body.groupId, isNull);
    expect(body.date, _lessonDate);
    expect(body.students, hasLength(1));
    expect(body.students!.single.studentId, _studentId);
    expect(body.students!.single.status, VisitStatus.present);
    expect(body.students!.single.type, VisitType.regular);

    expect(find.byType(StudentLessonPage), findsNothing);
  });

  testWidgets('an attendance that is unchecked is stored as unmarked', (
    tester,
  ) async {
    final lessonClient = _FakeLessonClient();

    await _openPage(tester, lessonClient: lessonClient);

    await tester.tap(find.text(_studentName));
    await tester.pumpAndSettle();

    await _pressAction(tester, t.create);

    final visit = lessonClient.createBodies.single.students!.single;

    expect(visit.status, VisitStatus.unmarked);
    expect(visit.type, VisitType.unmarked);
  });

  testWidgets('editing a stored lesson updates it', (tester) async {
    final lessonClient = _FakeLessonClient(visits: [_visit()]);

    await _openPage(tester, lesson: _lesson, lessonClient: lessonClient);

    expect(_isChecked(tester), isTrue);

    // Nothing changed yet, so there is nothing to update.
    expect(_isActionEnabled(tester, t.update), isFalse);

    await tester.tap(find.text(_studentName));
    await tester.pumpAndSettle();

    expect(_isActionEnabled(tester, t.update), isTrue);

    await _pressAction(tester, t.update);

    expect(lessonClient.updatedLessonIds, ['lesson-1']);

    final visit = lessonClient.updateBodies.single.students!.single;

    expect(lessonClient.updateBodies.single.date, _lessonDate);
    expect(visit.studentId, _studentId);
    expect(visit.status, VisitStatus.unmarked);

    expect(find.byType(StudentLessonPage), findsNothing);
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
    await tester.pumpAndSettle();

    expect(lessonClient.deletedLessonIds, ['lesson-1']);
    expect(find.byType(StudentLessonPage), findsNothing);
  });
}
