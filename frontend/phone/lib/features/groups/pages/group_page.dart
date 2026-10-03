import 'package:flutter/material.dart';
import 'package:phone/core/widgets/radial_expandable_fab.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/generated/models/group_summary.dart';

class GroupPage extends StatefulWidget {
  final GroupSummary group;

  const new({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          PopupMenuButton<String>(
            tooltip: '',
            offset: const Offset(-8, 0),
            color: Theme.of(context).colorScheme.surface,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),

              PopupMenuItem<String>(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 12),
                    Text('Lesson'),
                  ],
                ),
              ),

              PopupMenuItem<String>(
                onTap: () {},
                child: Row(
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
                    SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(width: 8),
        ],
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
                tag: 'group-card-${widget.group.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: GroupCard(group: widget.group, onTap: () {}),
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
