import 'package:flutter/material.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/features/students/models/student_badge_data.dart';

class StudentBadges extends StatelessWidget {
  static const double _spacing = 8.0;

  final List<StudentBadgeData> badges;

  const new({super.key, required this.badges});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: _spacing,
    runSpacing: _spacing,
    children: [
      for (final badge in badges)
        CardBadge(
          key: ValueKey(badge.id),
          icon: badge.icon,
          label: badge.label,
          backgroundColor: badge.backgroundColor,
          foregroundColor: badge.foregroundColor,
        ),
    ],
  );
}
