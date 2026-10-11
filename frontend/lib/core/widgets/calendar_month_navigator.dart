import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarMonthNavigator extends StatelessWidget {
  final DateTime focusedDay;

  final String? locale;

  final VoidCallback? onPreviousMonth;

  final VoidCallback? onNextMonth;

  const new({
    super.key,
    required this.focusedDay,
    this.locale,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  String get _label => DateFormat.yMMMM(locale).format(focusedDay);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onPreviousMonth,
        icon: const Icon(Icons.chevron_left),
      ),
      Expanded(
        child: Text(
          _label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      IconButton(onPressed: onNextMonth, icon: const Icon(Icons.chevron_right)),
    ],
  );
}
