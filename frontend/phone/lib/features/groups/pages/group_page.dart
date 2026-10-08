import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/radial_expandable_fab.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/pages/group_report_page.dart';
import 'package:phone/features/groups/widgets/create_lesson_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/edit_group_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/group_hero_card.dart';
import 'package:phone/features/groups/widgets/group_lessons_section.dart';
import 'package:phone/features/groups/widgets/group_popup_menu.dart';
import 'package:phone/features/groups/widgets/group_students_section.dart';
import 'package:phone/generated/export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupPage extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends ConsumerState<GroupPage> {
  late GroupSummaryResponse _group = widget.group;

  Future<void> _openEditGroupSheet() async {
    await AppBottomSheet.show(
      context: context,
      child: EditGroupBottomSheet(group: _group),
    );

    if (!mounted) return;

    final listState = ref.read(groupListControllerProvider);
    final updated = (listState.value ?? const <GroupSummaryResponse>[])
        .where((g) => g.id == _group.id)
        .firstOrNull;

    if (updated != null) setState(() => _group = updated);
  }

  Future<void> _openReportPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupReportPage(group: _group)),
    );
  }

  Future<void> _openCreateLessonSheet() async {
    await AppBottomSheet.show(
      context: context,
      child: CreateLessonBottomSheet(groupId: _group.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;
    final isGroupRefreshing = ref.watch(groupListControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name),
        actions: [
          GroupPopupMenu(group: _group),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RadialExpandableFab(
        distance: 120.0,
        children: [
          FloatingActionButton(
            heroTag: 'edit-group',
            onPressed: _openEditGroupSheet,
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.edit),
          ),
          FloatingActionButton(
            heroTag: 'lesson-group',
            onPressed: _openCreateLessonSheet,
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.calendar_month),
          ),
          FloatingActionButton(
            heroTag: 'report-group',
            onPressed: _openReportPage,
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.print),
          ),
        ],
      ),
      body: CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () async {
          await Future.wait([
            ref.read(groupLessonsProvider(_group.id).notifier).refresh(),
            ref.read(groupStudentsProvider(_group.id).notifier).refresh(),
            ref
                .read(groupListControllerProvider.notifier)
                .getAllGroups(forceRefresh: true),
          ]);

          if (!context.mounted) return;

          final listState = ref.read(groupListControllerProvider);
          if (listState.hasError) return;

          final updated = (listState.value ?? const [])
              .where((g) => g.id == _group.id)
              .firstOrNull;

          if (updated == null) {
            Navigator.of(context).pop();
            return;
          }

          setState(() => _group = updated);
        },
        child: SingleChildScrollView(
          padding: kRadialFabContentPadding,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 16,
            children: [
              Skeletonizer(
                enabled: isGroupRefreshing,
                ignorePointers: false,
                child: GroupHeroCard(
                  group: _group,
                  routeAnimation: routeAnimation,
                ),
              ),
              GroupLessonsSection(groupId: _group.id),
              GroupStudentsSection(
                groupId: _group.id,
                studentCount: _group.countOfStudents == 0
                    ? null
                    : _group.countOfStudents,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
