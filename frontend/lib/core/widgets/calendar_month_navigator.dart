import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The shared month header of a set of calendars.
///
/// Draws the arrow that steps a month back, the name of the shown month with
/// its year, and the arrow that steps a month forward. The owner keeps the
/// shown month, so a single header can drive several calendars at once.
class CalendarMonthNavigator extends StatelessWidget {
  /// A day of the month that is shown.
  final DateTime focusedDay;

  /// The locale the month is written in.
  final String? locale;

  /// Called when the arrow that steps a month back is tapped, `null` to disable
  /// the arrow.
  final VoidCallback? onPreviousMonth;

  /// Called when the arrow that steps a month forward is tapped, `null` to
  /// disable the arrow.
  final VoidCallback? onNextMonth;

  const new({
    super.key,
    required this.focusedDay,
    this.locale,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  /// The shown month and year, e.g. `October 2026`.
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
