import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/features/groups/widgets/report_form_constants.dart';
import 'package:phone/i18n/strings.g.dart';

class MonthField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const new({super.key, required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(reportMonthDigits),
    ],
    decoration: InputDecoration(
      labelText: context.t.month,
      hintText: 'MM',
      errorText: errorText,
    ),
  );
}
