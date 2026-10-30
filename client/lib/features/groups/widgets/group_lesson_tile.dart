import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupLessonTile extends StatelessWidget {
  final int number;
  final LessonResponse lesson;

  const new({super.key, required this.number, required this.lesson});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      '${context.t.lessons.groupLesson} $number',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    onTap: () =>
        Navigator.of(context).pop(GroupDayLessonSelection(lesson: lesson)),
  );
}
