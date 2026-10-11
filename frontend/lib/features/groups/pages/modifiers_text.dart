import 'package:flutter/material.dart';

class ModifiersText extends StatelessWidget {
  final List<String> modifiers;

  const new({super.key, required this.modifiers});

  @override
  Widget build(BuildContext context) => Text(
    modifiers.join(' · '),
    style: TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}
