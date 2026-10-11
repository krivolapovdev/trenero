import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

const String _studentName = 'Ivan Petrov';

final GroupResponse _group = GroupResponse(
  id: 'group-1',
  name: 'Group A',
  createdAt: DateTime(2026, 1, 15),
);

final DateTime _day = DateTime(2026, 10, 8);

LessonResponse _lesson({required String id, String? groupId}) =>
    LessonResponse(id: id, date: _day, createdAt: _day, groupId: groupId);

StudentDayLesson _individualLesson({
  String id = 'individual-lesson',
  VisitStatus status = VisitStatus.present,
}) => StudentDayLesson(
  lesson: _lesson(id: id),
  visitStatus: status,
);

StudentDayLesson _groupLesson({
  String id = 'group-lesson',
  VisitStatus status = VisitStatus.present,
}) => StudentDayLesson(
  lesson: _lesson(id: id, groupId: _group.id),
  visitStatus: status,
);

/// What the sheet popped, filled in once a tile is tapped.
final List<StudentDayLessonSelection?> _results = [];

/// Shows the sheet the way the student page does.
Future<void> _openSheet(
  WidgetTester tester,
  StudentDayLessonsBottomSheet sheet,
) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result =
                    await AppBottomSheet.show<StudentDayLessonSelection>(
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
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  setUp(_results.clear);

  testWidgets('a day without lessons offers both lessons', (tester) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
      ),
    );

    expect(find.text(t.lessons.individualLesson), findsOneWidget);
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
    expect(find.text(t.lessons.individualLessons), findsNothing);
    expect(find.text(t.lessons.groupLessons), findsNothing);
  });

  testWidgets('the individual row creates a lesson when the day has none', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
      ),
    );

    await tester.tap(find.text(t.lessons.individualLesson));
    await tester.pumpAndSettle();

    expect(_results.single?.action, StudentDayLessonAction.individual);
    expect(_results.single?.lesson, isNull);
  });

  testWidgets('the individual lessons are listed like the group lessons', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
        individualLessons: [
          _individualLesson(),
          _individualLesson(
            id: 'individual-lesson-2',
            status: VisitStatus.absent,
          ),
        ],
      ),
    );

    expect(find.text(t.lessons.individualLessons), findsOneWidget);
    expect(find.text(_studentName), findsNWidgets(2));
    expect(find.text(t.lessons.present), findsOneWidget);
    expect(find.text(t.lessons.missed), findsOneWidget);

    // The day keeps offering another individual lesson, and the group lesson of
    // the day can still be created.
    expect(find.text(t.lessons.individualLesson), findsOneWidget);
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
  });

  testWidgets('a stored individual lesson opens the lesson for editing', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
        individualLessons: [_individualLesson(status: VisitStatus.absent)],
      ),
    );

    await tester.tap(find.text(_studentName));
    await tester.pumpAndSettle();

    expect(_results.single?.action, StudentDayLessonAction.individual);
    expect(_results.single?.lesson?.id, 'individual-lesson');
  });

  testWidgets('the group lessons show the attendance of the student', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
        groupLessons: [
          _groupLesson(),
          _groupLesson(id: 'group-lesson-2', status: VisitStatus.absent),
        ],
      ),
    );

    expect(find.text(t.lessons.groupLessons), findsOneWidget);
    expect(find.text('Group A'), findsNWidgets(2));
    expect(find.text(t.lessons.present), findsOneWidget);
    expect(find.text(t.lessons.missed), findsOneWidget);

    // The day keeps offering another group lesson.
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
  });

  testWidgets('both create rows stay available on a day with lessons', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
        individualLessons: [_individualLesson()],
        groupLessons: [_groupLesson()],
      ),
    );

    // The stored lessons are listed, and another lesson of each kind can still
    // be created.
    expect(find.text(t.lessons.individualLessons), findsOneWidget);
    expect(find.text(t.lessons.groupLessons), findsOneWidget);
    expect(find.text(t.lessons.individualLesson), findsOneWidget);
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
  });

  testWidgets('a stored group lesson opens the lesson for editing', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
        groupLessons: [_groupLesson()],
      ),
    );

    await tester.tap(find.text('Group A'));
    await tester.pumpAndSettle();

    expect(_results.single?.action, StudentDayLessonAction.group);
    expect(_results.single?.lesson?.id, 'group-lesson');
  });

  testWidgets('the group row creates a lesson when the day has none', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        studentGroup: _group,
      ),
    );

    await tester.tap(find.text(t.lessons.groupLesson));
    await tester.pumpAndSettle();

    expect(_results.single?.action, StudentDayLessonAction.group);
    expect(_results.single?.lesson, isNull);
  });

  testWidgets('a student without a group cannot create a group lesson', (
    tester,
  ) async {
    await _openSheet(
      tester,
      const StudentDayLessonsBottomSheet(studentName: _studentName),
    );

    expect(find.text(t.lessons.individualLesson), findsOneWidget);
    expect(find.text(t.lessons.groupLesson), findsNothing);
  });

  testWidgets('a day with many lessons scrolls to the create row', (
    tester,
  ) async {
    await _openSheet(
      tester,
      StudentDayLessonsBottomSheet(
        studentName: _studentName,
        individualLessons: List.generate(
          20,
          (index) => _individualLesson(id: 'individual-lesson-$index'),
        ),
      ),
    );

    final createRow = find.text(t.lessons.individualLesson);
    final before = tester.getTopLeft(createRow).dy;

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(createRow).dy, lessThan(before));
  });
}
