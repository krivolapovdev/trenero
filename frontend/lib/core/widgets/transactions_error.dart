import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_spacing.dart';

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
        error.toString(),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  );
}
