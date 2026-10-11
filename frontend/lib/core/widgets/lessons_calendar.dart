import 'package:flutter/material.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

class LessonsCalendar extends StatefulWidget {
  final List<LessonResponse> lessons;
  final String? locale;

  final void Function(DateTime selectedDay, List<LessonResponse> dayLessons)?
  onDayTapped;

  final List<VisitStatus> Function(DateTime day)? dayVisitStatuses;

  final DateTime? focusedDay;

  final ValueChanged<DateTime>? onMonthChanged;

  final bool headerVisible;

  final bool surfaceVisible;

  final bool swipeEnabled;

  const new({
    super.key,
    required this.lessons,
    this.locale,
    this.onDayTapped,
    this.dayVisitStatuses,
    this.focusedDay,
    this.onMonthChanged,
    this.headerVisible = true,
    this.surfaceVisible = true,
    this.swipeEnabled = true,
  });

  @override
  State<LessonsCalendar> createState() => _LessonsCalendarState();
}

class _LessonsCalendarState extends State<LessonsCalendar> {
  late DateTime _focusedDay;

  DateTime get _shownDay => widget.focusedDay ?? _focusedDay;

  static const Color _lightGreenAlpha = Color(0x4D4CAF50);
  static const Color _darkForestGreen = Color(0xFF1B5E20);

  static const Color _lightBlueAlpha = Color(0x4D2196F3);
  static const Color _darkBlue = Color(0xFF0D47A1);

  static const Color _lightRedAlpha = Color(0x4DF44336);
  static const Color _darkRed = Color(0xFFB71C1C);

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

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

  void _onPageChanged(DateTime focusedDay) {
    if (widget.focusedDay == null) {
      setState(() {
        _focusedDay = focusedDay;
      });
    }

    widget.onMonthChanged?.call(focusedDay);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (widget.focusedDay == null) {
      setState(() {
        _focusedDay = focusedDay;
      });
    }

    _onDayTapped(selectedDay);
  }

  void _onDayTapped(DateTime selectedDay) {
    final dayLessons = _lessonsOf(selectedDay);
    final onDayTapped = widget.onDayTapped;

    if (onDayTapped != null) {
      onDayTapped(selectedDay, dayLessons);
      return;
    }

    _showLessonsBottomSheet(selectedDay, dayLessons);
  }

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
              context.t.lessons.forDate(
                date:
                    '${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
              ),
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (dayLessons.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(context.t.lessons.emptyDay),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dayLessons.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text('${context.t.lessons.title} ${index + 1}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendar = TableCalendar<LessonResponse>(
      locale: widget.locale,
      firstDay: DateTime(2000),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _shownDay,
      enabledDayPredicate: _isEnabledDay,
      headerVisible: widget.headerVisible,
      availableGestures: widget.swipeEnabled
          ? AvailableGestures.horizontalSwipe
          : AvailableGestures.none,
      onPageChanged: _onPageChanged,
      selectedDayPredicate: (day) => false,
      onDaySelected: _onDaySelected,
      eventLoader: _lessonsOf,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders<LessonResponse>(
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
    );

    if (!widget.surfaceVisible) return calendar;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: calendar,
    );
  }
}
