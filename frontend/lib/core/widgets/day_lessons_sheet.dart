import 'package:flutter/material.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

class DayLessonsSheet extends StatelessWidget {
  final DateTime selectedDay;
  final List<LessonResponse> dayLessons;

  const new({
    super.key,
    required this.selectedDay,
    required this.dayLessons,
  });

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
