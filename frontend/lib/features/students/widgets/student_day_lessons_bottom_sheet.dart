import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/widgets/card_badge.dart';
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
              _SectionTitle(title: context.t.lessons.individualLessons),
              for (final lesson in individualLessons)
                _StudentDayLessonTile(
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
              _StudentDayCreateTile(
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
              _SectionTitle(title: context.t.lessons.groupLessons),
              for (final lesson in groupLessons)
                _StudentDayLessonTile(
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
              _StudentDayCreateTile(
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const new({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  );
}

class _StudentDayLessonTile extends StatelessWidget {
  final StudentDayLesson lesson;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.lesson,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: _DayAttendanceBadge(isPresent: lesson.isPresent),
    onTap: onTap,
  );
}

class _StudentDayCreateTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const new({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _DayAttendanceBadge extends StatelessWidget {
  final bool isPresent;

  const new({required this.isPresent});

  @override
  Widget build(BuildContext context) => CardBadge(
    icon: Icon(isPresent ? Icons.check : Icons.close),
    label: isPresent ? context.t.lessons.present : context.t.lessons.missed,
    backgroundColor: isPresent
        ? AppColors.successSurface
        : AppColors.warningSurface,
    foregroundColor: isPresent ? AppColors.successOn : AppColors.warningOn,
  );
}
