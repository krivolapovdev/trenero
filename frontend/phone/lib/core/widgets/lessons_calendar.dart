import 'package:flutter/material.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:table_calendar/table_calendar.dart';

class LessonsCalendar extends StatefulWidget {
  final List<LessonResponse> lessons;
  final String? locale;

  /// Called when a day is tapped, with the lessons that take place on it.
  ///
  /// When set, the owner of the calendar takes over the tap (for example by
  /// opening the lesson page) and the bundled list of the day is not shown.
  final void Function(DateTime selectedDay, List<LessonResponse> dayLessons)?
  onDayTapped;

  /// The statuses of the visits that take place on a day, used to colour a
  /// student's day by the attendance recorded for it.
  ///
  /// When set, a day whose visits were all present is drawn green and a day
  /// that was entirely missed is drawn red. The days that are neither (an
  /// unmarked visit, or a mix of present and absent) keep the colour of the
  /// lesson. The group calendar leaves it null, so its days keep telling the
  /// kind of lesson only.
  final List<VisitStatus> Function(DateTime day)? dayVisitStatuses;

  const new({
    super.key,
    required this.lessons,
    this.locale,
    this.onDayTapped,
    this.dayVisitStatuses,
  });

  @override
  State<LessonsCalendar> createState() => _LessonsCalendarState();
}

class _LessonsCalendarState extends State<LessonsCalendar> {
  late DateTime _focusedDay;

  static const Color _lightGreenAlpha = Color(0x4D4CAF50);
  static const Color _darkForestGreen = Color(0xFF1B5E20);

  /// An individual lesson belongs to one student, so its day is drawn with a
  /// colour of its own to tell it from a day of a group lesson.
  static const Color _lightBlueAlpha = Color(0x4D2196F3);
  static const Color _darkBlue = Color(0xFF0D47A1);

  /// The day of a student is drawn with these when the attendance of every
  /// lesson of the day is known and the same.
  static const Color _lightRedAlpha = Color(0x4DF44336);
  static const Color _darkRed = Color(0xFFB71C1C);

  /// Lessons are only ever recorded for the past, so the days after today
  /// cannot be picked.
  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  /// table_calendar builds the days of its grid in UTC, so the instants cannot
  /// be compared with a local [DateTime]. Only the date part is compared.
  bool _isEnabledDay(DateTime day) {
    final today = DateTime.now();

    return !DateTime(
      day.year,
      day.month,
      day.day,
    ).isAfter(DateTime(today.year, today.month, today.day));
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = _today;
  }

  List<LessonResponse> _lessonsOf(DateTime day) =>
      widget.lessons.where((lesson) => isSameDay(lesson.date, day)).toList();

  void _onDayTapped(DateTime selectedDay) {
    final dayLessons = _lessonsOf(selectedDay);
    final onDayTapped = widget.onDayTapped;

    if (onDayTapped != null) {
      onDayTapped(selectedDay, dayLessons);
      return;
    }

    _showLessonsBottomSheet(selectedDay, dayLessons);
  }

  /// The colours a day of lessons is drawn with.
  ///
  /// A student's day is coloured by the attendance recorded for it: green when
  /// the whole day was attended and red when it was entirely missed. The days
  /// that are neither (an unmarked visit, or a mix of present and absent) fall
  /// back to the colour of the lesson, which tells an individual lesson from a
  /// group one.
  ({Color background, Color foreground}) _dayColors(
    DateTime day,
    List<LessonResponse> dayLessons,
  ) {
    final statuses =
        widget.dayVisitStatuses?.call(day) ?? const <VisitStatus>[];
    final isAttended =
        statuses.isNotEmpty &&
        statuses.every((status) => status == VisitStatus.present);
    final isMissed =
        statuses.isNotEmpty &&
        statuses.every((status) => status == VisitStatus.absent);

    if (isAttended) {
      return (background: _lightGreenAlpha, foreground: _darkForestGreen);
    }

    if (isMissed) {
      return (background: _lightRedAlpha, foreground: _darkRed);
    }

    final hasIndividualLesson = dayLessons.any(
      (lesson) => lesson.groupId == null,
    );

    return hasIndividualLesson
        ? (background: _lightBlueAlpha, foreground: _darkBlue)
        : (background: _lightGreenAlpha, foreground: _darkForestGreen);
  }

  /// The marker of a day with at least one lesson, `null` for the other days so
  /// that table_calendar falls back to its own style.
  Widget? _buildLessonDay(DateTime day) {
    final dayLessons = _lessonsOf(day);
    if (dayLessons.isEmpty) return null;

    final color = _dayColors(day, dayLessons);
    final backgroundColor = color.background;
    final foregroundColor = color.foreground;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: foregroundColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLessonsBottomSheet(
    DateTime selectedDay,
    List<LessonResponse> dayLessons,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lessons for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (dayLessons.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No lessons scheduled for this day.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dayLessons.length,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text('Lesson ${index + 1}')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(8),
    child: TableCalendar<LessonResponse>(
      locale: widget.locale,
      firstDay: DateTime(2000, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      // The days after today are shown greyed out and cannot be tapped.
      enabledDayPredicate: _isEnabledDay,
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      selectedDayPredicate: (day) => false,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });

        _onDayTapped(selectedDay);
      },
      eventLoader: _lessonsOf,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders<LessonResponse>(
        // table_calendar asks the today builder before the default one, so a
        // lesson that takes place today has to be drawn here as well.
        todayBuilder: (context, day, focusedDay) => _buildLessonDay(day),
        defaultBuilder: (context, day, focusedDay) => _buildLessonDay(day),
        singleMarkerBuilder: (context, day, event) => const SizedBox.shrink(),
        markerBuilder: (context, day, events) => const SizedBox.shrink(),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        todayTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
