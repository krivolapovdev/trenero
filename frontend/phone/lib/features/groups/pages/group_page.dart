import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/radial_expandable_fab.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/features/groups/widgets/lessons_calendar.dart'; // Import extracted widget
import 'package:phone/generated/models/group_summary.dart';

class GroupPage extends ConsumerStatefulWidget {
  final GroupSummary group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends ConsumerState<GroupPage> {
  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;
    final lessonsAsync = ref.watch(groupLessonsProvider(widget.group.id));
    final localeAsync = ref.watch(languageProvider);

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
                child: const Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 12),
                    Text('Lesson'),
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
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

            lessonsAsync.when(
              data: (lessons) => LessonsCalendar(
                lessons: lessons,
                locale: localeAsync.value?.languageTag,
                onDaySelected: (selectedDay, focusedDay) {
                  // Handle day tap here if needed
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error loading lessons: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
