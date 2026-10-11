import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/pages/group_students_page.dart';
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

  /// Opens the page that picks the students of the group.
  ///
  /// The page drops the cached students of the group once it saved them, so the
  /// section follows the new pick on its own.
  Future<void> _openGroupStudentsPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupStudentsPage(group: _group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;
    final isGroupRefreshing = ref.watch(groupListControllerProvider).isLoading;

    // The group list is reloaded in the background after the group was edited
    // or a student joined or left it; keep the header in sync with it.
    ref.listen(groupListControllerProvider, (previous, next) {
      final updated = (next.value ?? const <GroupSummaryResponse>[])
          .where((group) => group.id == _group.id)
          .firstOrNull;

      if (updated != null) {
        setState(() => _group = updated);
      }
    });

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
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
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
                onEdit: _openGroupStudentsPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
