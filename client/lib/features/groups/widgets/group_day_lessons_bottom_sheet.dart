import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_create_lesson_tile.dart';
import 'package:phone/features/groups/widgets/group_lesson_tile.dart';
import 'package:phone/generated/models/lesson_response.dart';

class GroupDayLessonSelection {
  final LessonResponse? lesson;

  const new({this.lesson});
}

class GroupDayLessonsBottomSheet extends StatelessWidget {
  final List<LessonResponse> groupLessons;

  const new({super.key, this.groupLessons = const []});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, lesson) in groupLessons.indexed)
            GroupLessonTile(
              key: ValueKey(lesson.id),
              number: index + 1,
              lesson: lesson,
            ),
          const GroupCreateLessonTile(),
        ],
      ),
    ),
  );
}
