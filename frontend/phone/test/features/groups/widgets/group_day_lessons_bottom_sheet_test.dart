import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/lesson_controller/lesson_controller_client.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

final DateTime _day = DateTime(2026, 10, 8);

LessonResponse _lesson({String id = 'lesson-1'}) =>
    LessonResponse(id: id, date: _day, createdAt: _day, groupId: 'group-1');

VisitResponse _visit({
  required String studentId,
  required VisitStatus status,
}) => VisitResponse(
  id: 'visit-$studentId',
  status: status,
  type: VisitType.regular,
  lessonId: 'lesson-1',
  studentId: studentId,
  createdAt: _day,
);

/// Serves the attendance the sheet shows next to a lesson.
class _FakeLessonClient implements LessonControllerClient {
  final List<VisitResponse> visits;

  new({this.visits = const []});

  @override
  Future<LessonDetailsResponse> getLessonDetails({
    required String lessonId,
  }) async => LessonDetailsResponse(
    id: lessonId,
    date: _day,
    createdAt: _day,
    groupId: 'group-1',
    studentVisits: visits,
  );

  @override
  Future<LessonResponse> createLesson({required CreateLessonRequest body}) =>
      throw UnimplementedError();

  @override
  Future<LessonResponse> updateLesson({
    required String lessonId,
    required UpdateLessonRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteLesson({required String lessonId}) =>
      throw UnimplementedError();

  @override
  Future<List<LessonResponse>> getLessons() => throw UnimplementedError();

  @override
  Future<LessonResponse> getLesson({required String lessonId}) =>
      throw UnimplementedError();
}

/// What the sheet popped, filled in once a tile is tapped.
final List<GroupDayLessonSelection?> _results = [];

/// Shows the sheet the way the group page does.
Future<void> _openSheet(
  WidgetTester tester,
  GroupDayLessonsBottomSheet sheet, {
  _FakeLessonClient? lessonClient,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        lessonServiceProvider.overrideWithValue(
          lessonClient ?? _FakeLessonClient(),
        ),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result =
                      await AppBottomSheet.show<GroupDayLessonSelection>(
                        context: context,
                        child: sheet,
                      );

                  _results.add(result);
                },
                child: const Text('open sheet'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  setUp(_results.clear);

  testWidgets('a day without lessons offers creating one', (tester) async {
    await _openSheet(tester, const GroupDayLessonsBottomSheet());

    expect(find.text(t.lessons.groupLesson), findsOneWidget);
    expect(find.text(t.lessons.groupLessons), findsNothing);
  });

  testWidgets('every lesson of the day is listed on its own', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(
        groupLessons: [
          _lesson(),
          _lesson(id: 'lesson-2'),
        ],
      ),
    );

    expect(find.text(t.lessons.groupLessons), findsOneWidget);
    expect(find.text('${t.lessons.groupLesson} 1'), findsOneWidget);
    expect(find.text('${t.lessons.groupLesson} 2'), findsOneWidget);

    // The row that creates another lesson of the day stays available.
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
  });

  testWidgets('a stored lesson opens the lesson for editing', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(groupLessons: [_lesson(id: 'lesson-2')]),
    );

    await tester.tap(find.text('${t.lessons.groupLesson} 1'));
    await tester.pumpAndSettle();

    expect(_results.single?.lesson?.id, 'lesson-2');
  });

  testWidgets('the create row opens a new lesson of the day', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(groupLessons: [_lesson()]),
    );

    await tester.tap(find.text(t.lessons.groupLesson));
    await tester.pumpAndSettle();

    expect(_results.single, isNotNull);
    expect(_results.single?.lesson, isNull);
  });

  testWidgets('a lesson shows the attendance it has recorded', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(groupLessons: [_lesson()]),
      lessonClient: _FakeLessonClient(
        visits: [
          _visit(studentId: 'student-1', status: VisitStatus.present),
          _visit(studentId: 'student-2', status: VisitStatus.present),
          _visit(studentId: 'student-3', status: VisitStatus.absent),
        ],
      ),
    );

    expect(find.text('2/3'), findsOneWidget);
  });
}
