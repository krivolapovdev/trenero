import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/generated/models/group_response.dart';

class GroupPage extends StatelessWidget {
  final GroupResponse group;

  const new({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: routeAnimation ?? const AlwaysStoppedAnimation(0),
              builder: (context, child) => HeroMode(
                enabled: routeAnimation?.status != AnimationStatus.reverse,
                child: child!,
              ),
              child: Hero(
                tag: 'group-card-${group.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: GroupCard(group: group, onTap: null),
                ),
              ),
            ),
            const Expanded(
              child: Center(child: Text('Group details will go here')),
            ),
          ],
        ),
      ),
    );
  }
}
