import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/i18n/strings.g.dart';

class EmptyStudents extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.xxl,
    ),
    child: Center(
      child: Text(
        context.t.noStudents,
        style: const TextStyle(color: AppColors.mutedText),
      ),
    ),
  );
}
