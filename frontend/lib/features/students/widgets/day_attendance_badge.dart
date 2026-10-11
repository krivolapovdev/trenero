import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/i18n/strings.g.dart';

class DayAttendanceBadge extends StatelessWidget {
  final bool isPresent;

  const new({super.key, required this.isPresent});

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
