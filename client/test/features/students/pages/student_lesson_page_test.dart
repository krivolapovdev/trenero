import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/groups/pages/lesson_ui.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/groups/widgets/lesson_attendance_bottom_sheet.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/lesson_controller/lesson_controller_client.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
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
const String _studentId = 'student-1';
const String _studentName = 'Ivan Petrov';

class _FakeLessonClient implements LessonControllerClient {
  final List<VisitResponse> visits;
  final List<CreateLessonRequest> createBodies = [];
  final List<UpdateLessonRequest> updateBodies = [];

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
    students: const [],
  );

  @override
  Future<LessonResponse> updateLesson({
    required String lessonId,
    required UpdateLessonRequest body,
  }) async {
    updateBodies.add(body);
    return LessonResponse(
      id: lessonId,
      date: body.date ?? _lessonDate,
      createdAt: DateTime(2026, 10, 8),
    );
  }

  @override
  Future<void> deleteLesson({required String lessonId}) async {}
}

class _FakeStudentClient implements StudentControllerClient {
  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    DateTime? from,
    DateTime? to,
  }) async => const [];

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap({
  required Widget child,
  required _FakeLessonClient lessonClient,
  _FakeStudentClient? studentClient,
}) => ProviderScope(
  overrides: [
    lessonServiceProvider.overrideWithValue(lessonClient),
    studentServiceProvider.overrideWithValue(
      studentClient ?? _FakeStudentClient(),
    ),
  ],
  child: TranslationProvider(child: MaterialApp(home: child)),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('starts with student marked present by default', (tester) async {
    final client = _FakeLessonClient();
    await tester.pumpWidget(
      _wrap(
        child: StudentLessonPage(
          studentId: _studentId,
          studentName: _studentName,
          date: _lessonDate,
        ),
        lessonClient: client,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(_studentName), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
  });

  testWidgets('long pressing the student opens the attendance bottom sheet', (
    tester,
  ) async {
    final client = _FakeLessonClient();
    await tester.pumpWidget(
      _wrap(
        child: StudentLessonPage(
          studentId: _studentId,
          studentName: _studentName,
          date: _lessonDate,
        ),
        lessonClient: client,
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text(_studentName));
    await tester.pumpAndSettle();

    expect(find.byType(LessonAttendanceBottomSheet), findsOneWidget);
    expect(find.text(t.lessons.present), findsOneWidget);
    expect(find.text(t.lessons.absent), findsOneWidget);
    expect(find.text(t.lessons.excused), findsOneWidget);
    expect(find.text(t.lessons.unmarked), findsOneWidget);
    expect(find.text(t.lessons.regular), findsOneWidget);
    expect(find.text(t.lessons.free), findsOneWidget);
  });

  testWidgets('picking free from the sheet updates the tile and modifier', (
    tester,
  ) async {
    final client = _FakeLessonClient();
    await tester.pumpWidget(
      _wrap(
        child: StudentLessonPage(
          studentId: _studentId,
          studentName: _studentName,
          date: _lessonDate,
        ),
        lessonClient: client,
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text(_studentName));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.lessons.free));
    await tester.pumpAndSettle();

    expect(find.text(t.lessons.freeLesson), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.activeColor, freeCheckColor);

    await tester.tap(find.text(t.create));
    await tester.pumpAndSettle();

    expect(client.createBodies, hasLength(1));
    final body = client.createBodies.single;
    expect(body.students, hasLength(1));
    expect(body.students!.single.status, VisitStatus.present);
    expect(body.students!.single.type, VisitType.free);
  });

  testWidgets(
    'picking excused from the sheet marks student excused and unchecked',
    (tester) async {
      final client = _FakeLessonClient();
      await tester.pumpWidget(
        _wrap(
          child: StudentLessonPage(
            studentId: _studentId,
            studentName: _studentName,
            date: _lessonDate,
          ),
          lessonClient: client,
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text(_studentName));
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.lessons.excused));
      await tester.pumpAndSettle();

      expect(find.text(t.lessons.excused), findsOneWidget);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      await tester.tap(find.text(t.create));
      await tester.pumpAndSettle();

      expect(client.createBodies, hasLength(1));
      final body = client.createBodies.single;
      expect(body.students, hasLength(1));
      expect(body.students!.single.status, VisitStatus.excused);
    },
  );

  testWidgets(
    'picking unmarked from the sheet removes checkbox and strikes through name',
    (tester) async {
      final client = _FakeLessonClient();
      await tester.pumpWidget(
        _wrap(
          child: StudentLessonPage(
            studentId: _studentId,
            studentName: _studentName,
            date: _lessonDate,
          ),
          lessonClient: client,
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text(_studentName));
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.lessons.unmarked));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsNothing);
      final textWidget = tester.widget<Text>(find.text(_studentName));
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);

      await tester.tap(find.text(t.create));
      await tester.pumpAndSettle();

      expect(client.createBodies, hasLength(1));
      final body = client.createBodies.single;
      expect(body.students, isEmpty);
    },
  );

  testWidgets(
    'editing an existing stored lesson starts with stored attendance',
    (tester) async {
      final client = _FakeLessonClient(
        visits: [
          VisitResponse(
            id: 'visit-1',
            lessonId: 'lesson-1',
            studentId: _studentId,
            status: VisitStatus.present,
            type: VisitType.free,
            createdAt: DateTime(2026, 10, 8),
          ),
        ],
      );
      await tester.pumpWidget(
        _wrap(
          child: StudentLessonPage(
            studentId: _studentId,
            studentName: _studentName,
            date: _lessonDate,
            lesson: LessonResponse(
              id: 'lesson-1',
              date: _lessonDate,
              createdAt: DateTime(2026, 10, 8),
            ),
          ),
          lessonClient: client,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(t.lessons.freeLesson), findsOneWidget);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
      expect(checkbox.activeColor, freeCheckColor);
    },
  );
}
