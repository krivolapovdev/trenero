import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/radial_expandable_fab.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentPage extends ConsumerStatefulWidget {
  final StudentSummaryResponse student;

  const new({super.key, required this.student});

  @override
  ConsumerState<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends ConsumerState<StudentPage> {
  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.fullName),
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
            heroTag: 'edit-student',
            onPressed: () {},
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.edit),
          ),
          FloatingActionButton(
            heroTag: 'lesson-student',
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
                tag: 'student-card-${widget.student.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: StudentCard(student: widget.student, onTap: () {}),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
