import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/generated/export.dart';

class GroupHeroCard extends StatelessWidget {
  final GroupSummaryResponse group;
  final Animation<double>? routeAnimation;
  final VoidCallback? onTap;

  const new({super.key, required this.group, this.routeAnimation, this.onTap});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: routeAnimation ?? const AlwaysStoppedAnimation(0),
    builder: (context, child) => HeroMode(
      enabled: routeAnimation?.status != AnimationStatus.reverse,
      child: child!,
    ),
    child: Hero(
      tag: 'group-card-${group.id}',
      child: Material(
        type: MaterialType.transparency,
        child: GroupCard(group: group, onTap: onTap ?? () {}),
      ),
    ),
  );
}
