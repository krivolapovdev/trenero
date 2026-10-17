import 'package:flutter/material.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentHeroCard extends StatelessWidget {
  final StudentSummaryResponse student;
  final Animation<double>? routeAnimation;

  const new({super.key, required this.student, this.routeAnimation});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: routeAnimation ?? const AlwaysStoppedAnimation(0),
    builder: (context, child) => HeroMode(
      enabled: routeAnimation?.status != AnimationStatus.reverse,
      child: child!,
    ),
    child: Hero(
      tag: 'student-card-${student.id}',
      child: Material(
        type: MaterialType.transparency,
        child: StudentCard(student: student, onTap: () {}, showBirthdate: true),
      ),
    ),
  );
}
