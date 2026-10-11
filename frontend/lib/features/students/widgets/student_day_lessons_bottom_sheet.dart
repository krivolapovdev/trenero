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

  void _select(BuildContext context, StudentDayLessonSelection selection) =>
      Navigator.of(context).pop(selection);

  List<Widget> _buildIndividualSection(BuildContext context) => [
    if (individualLessons.isNotEmpty) ...[
      _buildSectionTitle(context, context.t.lessons.individualLessons),
      ...individualLessons.map(
        (lesson) => _buildLessonTile(
          context,
          lesson: lesson,
          icon: Icons.person_outline,
          title: studentName,
          onTap: () => _select(
            context,
            StudentDayLessonSelection(
              StudentDayLessonAction.individual,
              lesson: lesson.lesson,
            ),
          ),
        ),
      ),
    ],
    _buildCreateTile(
      context,
      icon: Icons.person_outline,
      title: context.t.lessons.individualLesson,
      selection: const StudentDayLessonSelection(
        StudentDayLessonAction.individual,
      ),
    ),
  ];

  List<Widget> _buildGroupSection(BuildContext context) {
    final group = studentGroup;
    if (group == null) return const [];

    return [
      if (groupLessons.isNotEmpty) ...[
        _buildSectionTitle(context, context.t.lessons.groupLessons),
        ...groupLessons.map(
          (lesson) => _buildLessonTile(
            context,
            lesson: lesson,
            icon: Icons.groups_outlined,
            title: group.name,
            onTap: () => _select(
              context,
              StudentDayLessonSelection(
                StudentDayLessonAction.group,
                lesson: lesson.lesson,
              ),
            ),
          ),
        ),
      ],
      _buildCreateTile(
        context,
        icon: Icons.group_add_outlined,
        title: context.t.lessons.groupLesson,
        selection: const StudentDayLessonSelection(
          StudentDayLessonAction.group,
        ),
      ),
    ];
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  );

  Widget _buildLessonTile(
    BuildContext context, {
    required StudentDayLesson lesson,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: _buildAttendanceBadge(context, lesson.isPresent),
    onTap: onTap,
  );

  Widget _buildCreateTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required StudentDayLessonSelection selection,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => _select(context, selection),
  );

  Widget _buildAttendanceBadge(BuildContext context, bool isPresent) =>
      CardBadge(
        icon: Icon(isPresent ? Icons.check : Icons.close),
        label: isPresent ? context.t.lessons.present : context.t.lessons.missed,
        backgroundColor: isPresent
            ? AppColors.successSurface
            : AppColors.warningSurface,
        foregroundColor: isPresent ? AppColors.successOn : AppColors.warningOn,
      );

  @override
  Widget build(BuildContext context) {
    final individualSection = showIndividualSection
        ? _buildIndividualSection(context)
        : const <Widget>[];
    final groupSection = _buildGroupSection(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...individualSection,
            if (individualSection.isNotEmpty && groupSection.isNotEmpty)
              const SizedBox(height: 10),
            ...groupSection,
          ],
        ),
      ),
    );
  }
}
