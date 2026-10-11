import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/widgets/create_group_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/group_list_body.dart';
import 'package:phone/features/groups/widgets/group_search_button.dart';

class GroupListPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  @override
  List<Widget> actions(BuildContext context) => [
    const GroupSearchButton(),
    IconButton(
      icon: const Icon(FluentIcons.folder_add_24_regular),
      onPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateGroupBottomSheet(),
      ),
    ),
    const SizedBox(width: 8),
  ];

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, child) => CustomMaterialIndicator(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      onRefresh: () async {
        await ref
            .read(groupListControllerProvider.notifier)
            .getAllGroups(forceRefresh: true);

        ref
          ..invalidate(groupLessonsProvider)
          ..invalidate(groupStudentsProvider);
      },
      child: const GroupListBody(),
    ),
  );
}

