import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_spacing.dart';

class StatusBadgeData {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const new({
    required this.label,
    this.backgroundColor = const Color(0xFFe8def8),
    this.textColor = const Color(0xFF0e081b),
  });
}

class StatusBadges extends StatelessWidget {
  final List<StatusBadgeData> badges;

  const new({super.key, required this.badges});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: badges
        .map(
          (badge) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: badge.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              badge.label,
              style: TextStyle(fontSize: 14, color: badge.textColor),
            ),
          ),
        )
        .toList(),
  );
}
