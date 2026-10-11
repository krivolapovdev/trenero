import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_spacing.dart';

class ErrorDetails extends StatelessWidget {
  static const double _contentPadding = AppSpacing.xxl;

  final Object error;

  const new({super.key, required this.error});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      _contentPadding,
      AppSpacing.sm,
      _contentPadding,
      _contentPadding,
    ),
    child: Text(
      '$error',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
