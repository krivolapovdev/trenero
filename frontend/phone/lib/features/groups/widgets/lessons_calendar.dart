import 'package:flutter/material.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:table_calendar/table_calendar.dart';

class LessonsCalendar extends StatefulWidget {
  final List<LessonResponse> lessons;
  final String? locale;
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;

  const new({
    super.key,
    required this.lessons,
    this.locale,
    this.onDaySelected,
  });

  @override
  State<LessonsCalendar> createState() => _LessonsCalendarState();
}

class _LessonsCalendarState extends State<LessonsCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  static const Color _lightGreenAlpha = Color(0x4D4CAF50);
  static const Color _darkForestGreen = Color(0xFF1B5E20);

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
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
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDaySelected?.call(selectedDay, focusedDay);
      },
      eventLoader: (day) => widget.lessons
          .where((lesson) => isSameDay(lesson.date, day))
          .toList(),
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders<LessonResponse>(
        defaultBuilder: (context, day, focusedDay) {
          final dayEvents = widget.lessons
              .where((lesson) => isSameDay(lesson.date, day))
              .toList();

          if (dayEvents.isNotEmpty) {
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
          return null;
        },
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
