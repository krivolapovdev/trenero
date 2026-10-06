import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/radial_expandable_fab.dart';
import 'package:phone/features/groups/widgets/group_hero_card.dart';
import 'package:phone/features/groups/widgets/group_lessons_section.dart';
import 'package:phone/features/groups/widgets/group_popup_menu.dart';
import 'package:phone/features/groups/widgets/group_students_section.dart';
import 'package:phone/generated/export.dart';

class GroupPage extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends ConsumerState<GroupPage> {
  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: const [GroupPopupMenu(), SizedBox(width: 8)],
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
            onPressed: () {},
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.edit),
          ),
          FloatingActionButton(
            heroTag: 'lesson-group',
            onPressed: () {},
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          spacing: 16,
          children: [
            GroupHeroCard(group: widget.group, routeAnimation: routeAnimation),
            GroupLessonsSection(groupId: widget.group.id),
            GroupStudentsSection(groupId: widget.group.id),
          ],
        ),
      ),
    );
  }
}
