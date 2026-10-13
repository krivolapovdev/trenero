import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/models/group_report_period.dart';
import 'package:phone/i18n/strings.g.dart';

class ReportError extends ConsumerWidget {
  final GroupReportPeriod period;
  final Object? error;

  const new({super.key, required this.period, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    children: [
      Expanded(
        child: Text(
          '${context.t.error}: ${error.userMessage(context.t)}',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),

      TextButton(
        onPressed: () =>
            ref.read(groupReportProvider(period).notifier).refresh(),
        child: Text(context.t.repeat),
      ),
    ],
  );
}
