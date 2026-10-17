import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/widgets/group_create_lesson_tile.dart';
import 'package:phone/features/groups/widgets/group_lesson_tile.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupDayLessonSelection {
  final LessonResponse? lesson;

  const new({this.lesson});
}

class GroupDayLessonsBottomSheet extends ConsumerWidget {
  final List<LessonResponse> groupLessons;

  const new({super.key, this.groupLessons = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (groupLessons.isNotEmpty) ...[
            Text(
              context.t.lessons.groupLessons,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            for (final (index, lesson) in groupLessons.indexed)
              GroupLessonTile(
                key: ValueKey(lesson.id),
                number: index + 1,
                lesson: lesson,
              ),
          ],
          const GroupCreateLessonTile(),
        ],
      ),
    ),
  );
}
