import 'package:flutter/material.dart';
import 'package:phone/features/students/widgets/day_attendance_badge.dart';
import 'package:phone/features/students/widgets/student_day_lessons_bottom_sheet.dart';

class StudentDayLessonTile extends StatelessWidget {
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
    trailing: DayAttendanceBadge(isPresent: lesson.isPresent),
    onTap: onTap,
  );
}
