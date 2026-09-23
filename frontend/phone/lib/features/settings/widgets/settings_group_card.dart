import 'package:flutter/material.dart';

class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;

  const new({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}
