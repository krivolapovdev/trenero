import 'package:flutter/material.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/pages/group_report_page.dart';
import 'package:phone/features/groups/pages/group_students_page.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/widgets/edit_group_bottom_sheet.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupPopupMenu extends StatelessWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  void _openReportPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupReportPage(group: group)),
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
        builder: (context) =>
            LessonPage(groupId: group.id, date: DateTime.now()),
      ),
    );
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
        child: const Row(
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 12),
            Text('Edit'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _openStudentsPage(context),
        child: Row(
          children: [
            const Icon(Icons.groups, size: 20),
            const SizedBox(width: 12),
            Text(context.t.students.title),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _openReportPage(context),
        child: Row(
          children: [
            const Icon(Icons.print, size: 20),
            const SizedBox(width: 12),
            Text(context.t.groups.report),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _openCreateLessonPage(context),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 20),
            const SizedBox(width: 12),
            Text(context.t.lessons.title),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () {},
        child: const Row(
          children: [
            Icon(Icons.inventory, size: 20),
            SizedBox(width: 12),
            Text('Archive'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () {},
        child: Row(
          children: [
            Icon(
              Icons.delete,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    ],
  );
}
