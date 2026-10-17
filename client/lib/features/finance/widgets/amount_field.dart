import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/i18n/strings.g.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ],
    decoration: InputDecoration(
      labelText: '${context.t.finance.amount}*',
      hintText: '0.00',
      prefixIcon: const Icon(FluentIcons.money_24_regular),
    ),
    onTap: onTap,
  );
}
