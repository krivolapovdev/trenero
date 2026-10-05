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

  static const Color _lightGreenAlpha = Color(0x4D4CAF50);
  static const Color _darkForestGreen = Color(0xFF1B5E20);

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
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
                  itemBuilder: (context, index) => ListTile(
                    title: Text('Lesson ${index + 1}'),
                    // Replace with your lesson fields (e.g., lesson.title, lesson.time)
                  ),
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
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      // Prevents any day from visually maintaining a selected state
      selectedDayPredicate: (day) => false,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });

        final dayLessons = widget.lessons
            .where((lesson) => isSameDay(lesson.date, selectedDay))
            .toList();

        _showLessonsBottomSheet(selectedDay, dayLessons);

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
