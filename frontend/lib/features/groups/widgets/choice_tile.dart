import 'package:flutter/material.dart';

class ChoiceTile<T> extends StatelessWidget {
  final T value;
  final String label;

  const new({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => RadioListTile<T>(
    value: value,
    title: Text(label, style: const TextStyle(fontSize: 16)),
    contentPadding: EdgeInsets.zero,
    dense: true,
    visualDensity: VisualDensity.compact,
  );
}
