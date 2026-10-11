import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

const Color _lightGreenAlpha = Color(0x4D4CAF50);
const Color _darkForestGreen = Color(0xFF1B5E20);

const Color _lightBlueAlpha = Color(0x4D2196F3);
const Color _darkBlue = Color(0xFF0D47A1);

const Color _lightRedAlpha = Color(0x4DF44336);
const Color _darkRed = Color(0xFFB71C1C);

({Color background, Color foreground}) _dayColors(
  List<VisitStatus>? statuses,
  List<LessonResponse> dayLessons,
) {
  final hasStatuses = statuses != null && statuses.isNotEmpty;
  final isAttended =
      hasStatuses && statuses.every((status) => status == VisitStatus.present);
  final isMissed =
      hasStatuses && statuses.every((status) => status == VisitStatus.absent);

  if (isAttended) {
    return (background: _lightGreenAlpha, foreground: _darkForestGreen);
  }

  if (isMissed) {
    return (background: _lightRedAlpha, foreground: _darkRed);
  }

  final hasIndividualLesson = dayLessons.any((lesson) => lesson.groupId == null);

  return hasIndividualLesson
      ? (background: _lightBlueAlpha, foreground: _darkBlue)
      : (background: _lightGreenAlpha, foreground: _darkForestGreen);
}

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
          _DayLessonsSheet(selectedDay: selectedDay, dayLessons: dayLessons),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? marker(DateTime day) {
      final dayLessons = _lessonsOf(day);
      if (dayLessons.isEmpty) return null;

      return _LessonDayMarker(
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

class _LessonDayMarker extends StatelessWidget {
  static const double _margin = 4.0;
  static const double _dotSize = 5.0;
  static const double _dotGap = 2;

  final DateTime day;
  final List<LessonResponse> lessons;
  final List<VisitStatus>? visitStatuses;

  const new({
    required this.day,
    required this.lessons,
    this.visitStatuses,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _dayColors(visitStatuses, lessons);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(_margin),
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  color: colors.foreground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: _dotGap),
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: colors.foreground,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayLessonsSheet extends StatelessWidget {
  final DateTime selectedDay;
  final List<LessonResponse> dayLessons;

  const new({required this.selectedDay, required this.dayLessons});

  @override
  Widget build(BuildContext context) => Padding(
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
  );
}
