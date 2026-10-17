import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/calendar_month_header.dart';
import 'package:phone/core/widgets/day_lessons_sheet.dart';
import 'package:phone/core/widgets/lesson_day_marker.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
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

  void _shiftMonth(int months) {
    final next = DateTime(_shownDay.year, _shownDay.month + months);

    if (widget.focusedDay == null) {
      setState(() {
        _focusedDay = next;
      });
    }

    widget.onMonthChanged?.call(next);
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

  void _showLessonsBottomSheet(
    DateTime selectedDay,
    List<LessonResponse> dayLessons,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.topRounded),
      builder: (context) =>
          DayLessonsSheet(selectedDay: selectedDay, dayLessons: dayLessons),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? marker(DateTime day) {
      final dayLessons = _lessonsOf(day);
      if (dayLessons.isEmpty) return null;

      return LessonDayMarker(
        day: day,
        lessons: dayLessons,
        visitStatuses: widget.dayVisitStatuses?.call(day),
      );
    }

    final calendar = TableCalendar<LessonResponse>(
      locale: widget.locale,
      firstDay: DateTime(2000),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _shownDay,
      enabledDayPredicate: _isEnabledDay,
      headerVisible: false,
      availableGestures: widget.swipeEnabled
          ? AvailableGestures.horizontalSwipe
          : AvailableGestures.none,
      onPageChanged: _onPageChanged,
      selectedDayPredicate: (day) => false,
      onDaySelected: _onDaySelected,
      eventLoader: _lessonsOf,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarBuilders: CalendarBuilders<LessonResponse>(
        todayBuilder: (context, day, focusedDay) => marker(day),
        defaultBuilder: (context, day, focusedDay) => marker(day),
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

    if (!widget.surfaceVisible) return _withHeader(calendar);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: _withHeader(calendar),
    );
  }

  Widget _withHeader(Widget calendar) {
    if (!widget.headerVisible) return calendar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: CalendarMonthHeader(
            focusedDay: _shownDay,
            locale: widget.locale,
            onPreviousMonth: () => _shiftMonth(-1),
            onNextMonth: () => _shiftMonth(1),
          ),
        ),
        calendar,
      ],
    );
  }
}
