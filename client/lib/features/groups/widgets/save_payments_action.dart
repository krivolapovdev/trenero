import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class SavePaymentsAction extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  const new({
    super.key,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: (isLoading || !enabled) ? null : onPressed,
    icon: isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
    label: Text(context.t.create, style: const TextStyle(fontSize: 18)),
  );
}
