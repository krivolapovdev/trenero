import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupCreateLessonTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.add),
    title: Text(
      context.t.lessons.groupLesson,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => Navigator.of(context).pop(const GroupDayLessonSelection()),
  );
}
