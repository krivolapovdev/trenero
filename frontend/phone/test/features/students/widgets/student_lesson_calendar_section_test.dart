import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/create_lesson_button.dart';
import 'package:phone/features/students/widgets/student_lesson_calendar_section.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

final DateTime _focusedDay = DateTime(2026, 10, 8);

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

StudentLessonCalendarSection _section({
  List<LessonResponse> lessons = const [],
  VoidCallback? onCreate,
}) => StudentLessonCalendarSection(
  title: 'Group A',
  lessons: lessons,
  focusedDay: _focusedDay,
  onDayTapped: (selectedDay, dayLessons) {},
  onCreate: onCreate,
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the block titles the calendar and draws its lessons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _section(
          lessons: [
            LessonResponse(
              id: 'lesson-1',
              date: _focusedDay,
              createdAt: _focusedDay,
              groupId: 'group-1',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Group A'), findsOneWidget);
    expect(find.byType(TableCalendar<LessonResponse>), findsOneWidget);
  });

  testWidgets('the block offers to create a lesson of its calendar', (
    tester,
  ) async {
    var created = false;

    await tester.pumpWidget(_wrap(_section(onCreate: () => created = true)));
    await tester.pumpAndSettle();

    expect(find.text(t.create), findsOneWidget);

    await tester.tap(find.byType(CreateLessonButton));
    await tester.pumpAndSettle();

    expect(created, isTrue);
  });

  testWidgets('the block draws the action beside the title', (tester) async {
    await tester.pumpWidget(_wrap(_section(onCreate: () {})));
    await tester.pumpAndSettle();

    final headerRow = find.ancestor(
      of: find.byType(CreateLessonButton),
      matching: find.widgetWithText(Row, 'Group A'),
    );

    expect(headerRow, findsOneWidget);
    expect(
      tester.widget<Row>(headerRow).mainAxisAlignment,
      MainAxisAlignment.spaceBetween,
    );
  });

  testWidgets('a block without an action draws the calendar alone', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_section()));
    await tester.pumpAndSettle();

    expect(find.byType(CreateLessonButton), findsNothing);
    expect(find.byType(TableCalendar<LessonResponse>), findsOneWidget);
  });
}
