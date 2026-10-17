import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/widgets/day_attendance_badge.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupLessonTile extends ConsumerWidget {
  final int number;
  final LessonResponse lesson;

  const new({super.key, required this.number, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      '${context.t.lessons.groupLesson} $number',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: DayAttendanceBadge(
      detailsState: ref.watch(lessonDetailsProvider(lesson.id)),
    ),
    onTap: () =>
        Navigator.of(context).pop(GroupDayLessonSelection(lesson: lesson)),
  );
}
