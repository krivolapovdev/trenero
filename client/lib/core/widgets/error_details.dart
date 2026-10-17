import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/i18n/strings.g.dart';

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
      error.userMessage(context.t),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
