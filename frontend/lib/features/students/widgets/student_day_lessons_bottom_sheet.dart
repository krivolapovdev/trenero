import 'package:flutter/material.dart';
import 'package:phone/features/students/widgets/day_section_title.dart';
import 'package:phone/features/students/widgets/student_day_create_tile.dart';
import 'package:phone/features/students/widgets/student_day_lesson_tile.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

enum StudentDayLessonAction { individual, group }

class StudentDayLessonSelection {
  final StudentDayLessonAction action;

  final LessonResponse? lesson;

  const new(this.action, {this.lesson});
}

class StudentDayLesson {
  final LessonResponse lesson;

  final VisitStatus visitStatus;

  const new({required this.lesson, required this.visitStatus});

  bool get isPresent => visitStatus == VisitStatus.present;
}

class StudentDayLessonsBottomSheet extends StatelessWidget {
  final String studentName;

  final List<StudentDayLesson> individualLessons;

  final List<StudentDayLesson> groupLessons;

  final GroupResponse? studentGroup;

  final bool showIndividualSection;

  const new({
    super.key,
    required this.studentName,
    this.individualLessons = const [],
    this.groupLessons = const [],
    this.studentGroup,
    this.showIndividualSection = true,
  });

  @override
  Widget build(BuildContext context) {
    final group = studentGroup;

    final hasIndividualSection = showIndividualSection;
    final hasIndividualLessons =
        hasIndividualSection && individualLessons.isNotEmpty;
    final hasGroupSection = group != null;
    final hasGroupLessons = hasGroupSection && groupLessons.isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasIndividualLessons) ...[
              DaySectionTitle(title: context.t.lessons.individualLessons),
              for (final lesson in individualLessons)
                StudentDayLessonTile(
                  key: ValueKey(lesson.lesson.id),
                  lesson: lesson,
                  icon: Icons.person_outline,
                  title: studentName,
                  onTap: () => Navigator.of(context).pop(
                    StudentDayLessonSelection(
                      StudentDayLessonAction.individual,
                      lesson: lesson.lesson,
                    ),
                  ),
                ),
            ],

            if (hasIndividualSection)
              StudentDayCreateTile(
                icon: Icons.person_outline,
                title: context.t.lessons.individualLesson,
                onTap: () => Navigator.of(context).pop(
                  const StudentDayLessonSelection(
                    StudentDayLessonAction.individual,
                  ),
                ),
              ),

            if (hasIndividualSection && hasGroupSection)
              const SizedBox(height: 10),

            if (hasGroupLessons) ...[
              DaySectionTitle(title: context.t.lessons.groupLessons),
              for (final lesson in groupLessons)
                StudentDayLessonTile(
                  key: ValueKey(lesson.lesson.id),
                  lesson: lesson,
                  icon: Icons.groups_outlined,
                  title: group.name,
                  onTap: () => Navigator.of(context).pop(
                    StudentDayLessonSelection(
                      StudentDayLessonAction.group,
                      lesson: lesson.lesson,
                    ),
                  ),
                ),
            ],

            if (hasGroupSection)
              StudentDayCreateTile(
                icon: Icons.group_add_outlined,
                title: context.t.lessons.groupLesson,
                onTap: () => Navigator.of(context).pop(
                  const StudentDayLessonSelection(StudentDayLessonAction.group),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
