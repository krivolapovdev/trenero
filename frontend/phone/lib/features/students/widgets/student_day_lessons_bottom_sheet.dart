import 'package:flutter/material.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

/// The lesson page the day bottom sheet asks the calendar to open.
enum StudentDayLessonAction {
  /// An individual lesson of the student.
  individual,

  /// A group lesson of the group the student belongs to.
  group,
}

/// The lesson the user picked in [StudentDayLessonsBottomSheet].
class StudentDayLessonSelection {
  /// Whether an individual lesson or a group lesson is opened.
  final StudentDayLessonAction action;

  /// The stored lesson to edit, or `null` to create a new lesson.
  final LessonResponse? lesson;

  const new(this.action, {this.lesson});
}

/// A lesson of a day together with the attendance of the student.
class StudentDayLesson {
  final LessonResponse lesson;

  /// The attendance the student has recorded for [lesson].
  final VisitStatus visitStatus;

  const new({required this.lesson, required this.visitStatus});

  /// Whether the student attended the lesson.
  bool get isPresent => visitStatus == VisitStatus.present;
}

/// The lessons of a day of a student.
///
/// Both the individual lessons and the group lessons of the day are listed the
/// same way, each with the attendance of the student at the right: a lesson is
/// stored together with a visit per student, so the row tells whether the
/// student was present or missed it. Below the listed lessons the sheet always
/// offers creating another one, the group lessons only when the student has a
/// group.
///
/// Pops with the [StudentDayLessonSelection] the user picked, or `null` when
/// the sheet is dismissed.
class StudentDayLessonsBottomSheet extends StatelessWidget {
  /// The student the individual lessons are stored for, shown by their rows.
  final String studentName;

  /// The individual lessons of the day.
  final List<StudentDayLesson> individualLessons;

  /// The group lessons of the day.
  final List<StudentDayLesson> groupLessons;

  /// The group of the student, `null` when the student has no group.
  final GroupResponse? studentGroup;

  const new({
    super.key,
    required this.studentName,
    this.individualLessons = const [],
    this.groupLessons = const [],
    this.studentGroup,
  });

  void _select(BuildContext context, StudentDayLessonSelection selection) =>
      Navigator.of(context).pop(selection);

  /// The individual lessons of the day, followed by the row that always offers
  /// creating another individual lesson for the student.
  List<Widget> _buildIndividualSection(BuildContext context) => [
    if (individualLessons.isNotEmpty) ...[
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

  /// The group lessons of the day, followed by the row that always offers
  /// creating another group lesson. Empty when the student has no group.
  List<Widget> _buildGroupSection(BuildContext context) {
    final group = studentGroup;
    if (group == null) return const [];

    return [
      if (groupLessons.isNotEmpty) ...[
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

  /// `Present` for an attended lesson, `Missed` for every other status.
  Widget _buildAttendanceBadge(BuildContext context, bool isPresent) =>
      CardBadge(
        icon: Icon(isPresent ? Icons.check : Icons.close),
        label: isPresent ? context.t.lessons.present : context.t.lessons.missed,
        backgroundColor: isPresent
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFFEDD5),
        foregroundColor: isPresent
            ? const Color(0xFF166534)
            : const Color(0xFF9A3412),
      );

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._buildIndividualSection(context),
          if (studentGroup != null) SizedBox(height: 10),
          ..._buildGroupSection(context),
        ],
      ),
    ),
  );
}
