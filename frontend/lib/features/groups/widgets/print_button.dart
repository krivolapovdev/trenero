import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class PrintButton extends StatelessWidget {
  final bool isPrinting;
  final bool enabled;
  final VoidCallback onPressed;

  const new({
    super.key,
    required this.isPrinting,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: enabled ? onPressed : null,
    icon: isPrinting
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
    label: Text(context.t.print, style: const TextStyle(fontSize: 18)),
  );
}
