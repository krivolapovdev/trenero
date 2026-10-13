import 'package:flutter/material.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/i18n/strings.g.dart';

/// The row that names a failed report and offers to ask for it again.
class ReportError extends StatelessWidget {
  final Object? error;
  final VoidCallback onRepeat;

  const new({super.key, required this.error, required this.onRepeat});

  @override
  Widget build(BuildContext context) => Row(
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

      TextButton(onPressed: onRepeat, child: Text(context.t.repeat)),
    ],
  );
}
