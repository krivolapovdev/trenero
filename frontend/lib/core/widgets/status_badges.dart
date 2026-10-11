import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/constants/app_spacing.dart';

class StatusBadgeData {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const new({
    required this.label,
    this.backgroundColor = AppColors.badgeSurface,
    this.textColor = AppColors.badgeOn,
  });
}

class StatusBadges extends StatelessWidget {
  final List<StatusBadgeData> badges;

  const new({super.key, required this.badges});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final badge in badges)
        _StatusBadge(key: ValueKey(badge.label), badge: badge),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final StatusBadgeData badge;

  const new({super.key, required this.badge});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xs + 2,
    ),
    decoration: BoxDecoration(
      color: badge.backgroundColor,
      borderRadius: AppRadius.lgAll,
    ),
    child: Text(
      badge.label,
      style: TextStyle(fontSize: 14, color: badge.textColor),
    ),
  );
}
