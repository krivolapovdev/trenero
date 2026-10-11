import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

const Color _groupLessonColor = Color(0x4D4CAF50);

const Color _individualLessonColor = Color(0x4D2196F3);

const Color _attendedColor = Color(0x4D4CAF50);

const Color _missedColor = Color(0x4DF44336);

LessonResponse _groupLesson(DateTime date) => LessonResponse(
  id: 'group-lesson',
  date: date,
  createdAt: date,
  groupId: 'group-1',
);

LessonResponse _individualLesson(DateTime date) =>
    LessonResponse(id: 'individual-lesson', date: date, createdAt: date);

Widget _studentCalendar(
  List<LessonResponse> lessons,
  List<VisitStatus> statuses,
) => LessonsCalendar(lessons: lessons, dayVisitStatuses: (_) => statuses);

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

Finder _lessonMarker(String dayText, Color color) => find.ancestor(
  of: find.text(dayText),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration! as BoxDecoration).color == color,
  ),
);

Finder _surface() => find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.decoration is BoxDecoration &&
      (widget.decoration! as BoxDecoration).borderRadius != null &&
      (widget.decoration! as BoxDecoration).color == Colors.white,
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('a group lesson that takes place today keeps the lesson style', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(LessonsCalendar(lessons: [_groupLesson(today)])),
    );
    await tester.pumpAndSettle();

    expect(_lessonMarker('${today.day}', _groupLessonColor), findsOneWidget);
    expect(_lessonMarker('${today.day}', _individualLessonColor), findsNothing);
  });

  testWidgets('an individual lesson marks the day with its own colour', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(LessonsCalendar(lessons: [_individualLesson(today)])),
    );
    await tester.pumpAndSettle();

    expect(
      _lessonMarker('${today.day}', _individualLessonColor),
      findsOneWidget,
    );
    expect(_lessonMarker('${today.day}', _groupLessonColor), findsNothing);
  });

  testWidgets('a day with both lessons is marked as an individual day', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: [_groupLesson(today), _individualLesson(today)],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      _lessonMarker('${today.day}', _individualLessonColor),
      findsOneWidget,
    );
  });

  testWidgets('the other days keep the plain style', (tester) async {
    final today = DateTime.now();

    await tester.pumpWidget(_wrap(const LessonsCalendar(lessons: [])));
    await tester.pumpAndSettle();

    expect(find.text('${today.day}'), findsOneWidget);
    expect(_lessonMarker('${today.day}', _groupLessonColor), findsNothing);
    expect(_lessonMarker('${today.day}', _individualLessonColor), findsNothing);
  });

  testWidgets('tapping a day reports the lessons of that day', (tester) async {
    final today = DateTime.now();
    DateTime? tappedDay;
    List<LessonResponse>? tappedLessons;

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: [_groupLesson(today)],
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
    expect(tappedLessons!.single.id, 'group-lesson');
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

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    await tester.tap(find.text('15'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(taps, 0);
  });

  testWidgets('a day attended in full is drawn green', (tester) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(
        _studentCalendar(
          [_individualLesson(today)],
          const [VisitStatus.present, VisitStatus.present],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_lessonMarker('${today.day}', _attendedColor), findsOneWidget);
    expect(_lessonMarker('${today.day}', _individualLessonColor), findsNothing);
    expect(_lessonMarker('${today.day}', _missedColor), findsNothing);
  });

  testWidgets('a day missed in full is drawn red', (tester) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(
        _studentCalendar(
          [_individualLesson(today)],
          const [VisitStatus.absent, VisitStatus.absent],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_lessonMarker('${today.day}', _missedColor), findsOneWidget);
    expect(_lessonMarker('${today.day}', _individualLessonColor), findsNothing);
    expect(_lessonMarker('${today.day}', _attendedColor), findsNothing);
  });

  testWidgets('a day that mixes present and absent keeps the lesson colour', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(
        _studentCalendar(
          [_individualLesson(today)],
          const [VisitStatus.present, VisitStatus.absent],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      _lessonMarker('${today.day}', _individualLessonColor),
      findsOneWidget,
    );
    expect(_lessonMarker('${today.day}', _attendedColor), findsNothing);
    expect(_lessonMarker('${today.day}', _missedColor), findsNothing);
  });

  testWidgets('a day without attendance keeps the lesson colour', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(_studentCalendar([_individualLesson(today)], const [])),
    );
    await tester.pumpAndSettle();

    expect(
      _lessonMarker('${today.day}', _individualLessonColor),
      findsOneWidget,
    );
    expect(_lessonMarker('${today.day}', _missedColor), findsNothing);
  });

  testWidgets('the surface can be hidden by the owner', (tester) async {
    await tester.pumpWidget(
      _wrap(LessonsCalendar(lessons: const [], surfaceVisible: false)),
    );
    await tester.pumpAndSettle();

    expect(_surface(), findsNothing);
  });

  testWidgets('the header can be hidden by the owner', (tester) async {
    await tester.pumpWidget(
      _wrap(LessonsCalendar(lessons: const [], headerVisible: false)),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('an owned month shows the month it is given', (tester) async {
    await tester.pumpWidget(
      _wrap(LessonsCalendar(lessons: const [], focusedDay: DateTime(2026, 5))),
    );
    await tester.pumpAndSettle();

    expect(find.text('May 2026'), findsOneWidget);
  });

  testWidgets('a swipe reports the new month to the owner', (tester) async {
    final changes = <DateTime>[];

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: const [],
          focusedDay: DateTime(2026, 5),
          onMonthChanged: changes.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(changes, hasLength(1));
    expect(changes.single.month, DateTime.june);
  });

  testWidgets('a sideways swipe is ignored when it is turned off', (
    tester,
  ) async {
    final changes = <DateTime>[];

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: const [],
          focusedDay: DateTime(2026, 5),
          swipeEnabled: false,
          onMonthChanged: changes.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(TableCalendar<LessonResponse>),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
    expect(find.text('May 2026'), findsOneWidget);
  });

  testWidgets('a sideways swipe shows the next month', (tester) async {
    final changes = <DateTime>[];

    await tester.pumpWidget(
      _wrap(
        LessonsCalendar(
          lessons: const [],
          focusedDay: DateTime(2026, 5),
          onMonthChanged: changes.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(TableCalendar<LessonResponse>),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();

    expect(changes, isNotEmpty);
    expect(changes.first.month, DateTime.june);
  });

  testWidgets('a vertical drag on the grid scrolls the page it sits in', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      _wrap(
        SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              LessonsCalendar(lessons: const []),
              const SizedBox(height: 1200),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(TableCalendar<LessonResponse>),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(scrollController.offset, greaterThan(0));
  });
}
