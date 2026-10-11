import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/i18n/strings.g.dart';

class YearField extends StatelessWidget {
  static const int _yearDigits = 4;

  final TextEditingController controller;
  final String? errorText;

  const new({super.key, required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(_yearDigits),
    ],
    decoration: InputDecoration(
      labelText: context.t.year,
      hintText: 'YYYY',
      errorText: errorText,
    ),
  );
}
