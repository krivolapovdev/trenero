import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/pages/group_students_page.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/widgets/delete_group_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/edit_group_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/group_report_bottom_sheet.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupPopupMenu extends StatelessWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  void _openReportSheet(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      child: GroupReportBottomSheet(group: group),
    );
  }

  void _openStudentsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupStudentsPage(group: group)),
    );
  }

  void _openCreateLessonPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonPage(
          groupId: group.id,
          groupName: group.name,
          date: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final navigator = Navigator.of(context);

    final deleted = await AppBottomSheet.show<bool>(
      context: context,
      child: DeleteGroupBottomSheet(group: group),
    );

    if (deleted == true) navigator.pop();
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: '',
    offset: const Offset(-8, 0),
    color: Theme.of(context).colorScheme.surface,
    itemBuilder: (menuContext) => [
      PopupMenuItem<String>(
        onTap: () => AppBottomSheet.show(
          context: context,
          child: EditGroupBottomSheet(group: group),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.text_cursor, size: 20),
            const SizedBox(width: 12),
            Text(context.t.edit),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _openStudentsPage(context),
        child: Row(
          children: [
            const Icon(CupertinoIcons.rectangle_stack_person_crop, size: 20),
            const SizedBox(width: 12),
            Text(context.t.students.title),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _openReportSheet(context),
        child: Row(
          children: [
            const Icon(CupertinoIcons.printer, size: 20),
            const SizedBox(width: 12),
            Text(context.t.groups.report),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _openCreateLessonPage(context),
        child: Row(
          children: [
            const Icon(CupertinoIcons.calendar, size: 20),
            const SizedBox(width: 12),
            Text(context.t.lessons.title),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _confirmDelete(context),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.trash,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Text(
              context.t.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    ],
  );
}
