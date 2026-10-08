import 'package:flutter/material.dart';
import 'package:phone/generated/models/lesson_response.dart';
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

  const new({super.key, required this.lessons, this.locale, this.onDayTapped});

  @override
  State<LessonsCalendar> createState() => _LessonsCalendarState();
}

class _LessonsCalendarState extends State<LessonsCalendar> {
  late DateTime _focusedDay;

  static const Color _lightGreenAlpha = Color(0x4D4CAF50);
  static const Color _darkForestGreen = Color(0xFF1B5E20);

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

  /// The green marker of a day with at least one lesson, `null` for the other
  /// days so that table_calendar falls back to its own style.
  Widget? _buildLessonDay(DateTime day) {
    if (_lessonsOf(day).isEmpty) return null;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: const BoxDecoration(
          color: _lightGreenAlpha,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: const TextStyle(
                  color: _darkForestGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: _darkForestGreen,
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
