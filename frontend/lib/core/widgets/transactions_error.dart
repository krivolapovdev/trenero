import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionsError extends StatelessWidget {
  final Object error;

  const new({super.key, required this.error});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.xxl,
    ),
    child: Center(
      child: Text(
        error.userMessage(context.t),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  );
}
