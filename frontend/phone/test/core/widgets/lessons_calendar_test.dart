import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

/// The background of the circle that marks a day with a lesson.
const Color _lessonColor = Color(0x4D4CAF50);

LessonResponse _lesson(DateTime date) =>
    LessonResponse(id: 'lesson-1', date: date, createdAt: date);

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

/// The circle drawn around [dayText] when the day has a lesson.
Finder _lessonMarker(String dayText) => find.ancestor(
  of: find.text(dayText),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration! as BoxDecoration).color == _lessonColor,
  ),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('a lesson that takes place today keeps the lesson style', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(_wrap(LessonsCalendar(lessons: [_lesson(today)])));
    await tester.pumpAndSettle();

    expect(_lessonMarker('${today.day}'), findsOneWidget);
  });

  testWidgets('the other days keep the plain style', (tester) async {
    final today = DateTime.now();

    await tester.pumpWidget(_wrap(const LessonsCalendar(lessons: [])));
    await tester.pumpAndSettle();

    expect(find.text('${today.day}'), findsOneWidget);
    expect(_lessonMarker('${today.day}'), findsNothing);
  });

  testWidgets('tapping a day reports the lessons of that day', (tester) async {
    final today = DateTime.now();
    DateTime? tappedDay;
    List<LessonResponse>? tappedLessons;

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: [_lesson(today)],
          onDayTapped: (day, lessons) {
            tappedDay = day;
            tappedLessons = lessons;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('${today.day}'));
    await tester.pumpAndSettle();

    expect(isSameDay(tappedDay!, today), isTrue);
    expect(tappedLessons, hasLength(1));
    expect(tappedLessons!.single.id, 'lesson-1');
  });

  testWidgets('tapping a day without a lesson reports an empty list', (
    tester,
  ) async {
    final today = DateTime.now();
    List<LessonResponse>? tappedLessons;

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: const [],
          onDayTapped: (day, lessons) => tappedLessons = lessons,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('${today.day}'));
    await tester.pumpAndSettle();

    expect(tappedLessons, isEmpty);
  });

  testWidgets('the days after today cannot be picked', (tester) async {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    await tester.pumpWidget(_wrap(const LessonsCalendar(lessons: [])));
    await tester.pumpAndSettle();

    final calendar = tester
        .widget<TableCalendar<LessonResponse>>(
          find.byType(TableCalendar<LessonResponse>),
        )
        .enabledDayPredicate!;

    // The grid of table_calendar is built in UTC.
    expect(calendar(DateTime.utc(today.year, today.month, today.day)), isTrue);
    expect(
      calendar(DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day)),
      isFalse,
    );
  });

  testWidgets('the days of a future month cannot be tapped', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: const [],
          onDayTapped: (day, lessons) => taps++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Every day of the next month lies in the future.
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    await tester.tap(find.text('15'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(taps, 0);
  });
}
