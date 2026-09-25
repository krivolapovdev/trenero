import 'package:flutter/material.dart';
import 'package:phone/core/widgets/entity_card.dart';
import 'package:phone/core/widgets/status_badges.dart';
import 'package:phone/features/groups/models/group_overview.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupCard extends StatelessWidget {
  final GroupOverview group;
  final VoidCallback? onTap;

  const new({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final badges = [
      StatusBadgeData(
        label: '${context.t.students.title}: ${group.groupStudents.length}',
      ),
    ];

    final subtitleLines = <String>[];

    if (group.defaultPrice != null) {
      subtitleLines.add('Default price: ${group.defaultPrice}');
    }

    if (group.note != null && group.note!.isNotEmpty) {
      subtitleLines.add('Note: ${group.note}');
    }

    return EntityCard(
      title: group.name,
      subtitle: subtitleLines.join('\n'),
      onTap: onTap,
      badges: badges,
    );
  }
}
