import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/extensions/string_extension.dart';

class CalendarMonthHeader extends StatelessWidget {
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

  String get _label => DateFormat.yMMMM(locale).format(focusedDay).capitalized;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          _label,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
      IconButton(
        icon: const Icon(FluentIcons.chevron_left_24_regular),
        onPressed: onPreviousMonth,
      ),
      IconButton(
        icon: const Icon(FluentIcons.chevron_right_24_regular),
        onPressed: onNextMonth,
      ),
    ],
  );
}
