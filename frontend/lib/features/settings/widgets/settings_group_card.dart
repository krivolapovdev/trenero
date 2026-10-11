import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';

class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;

  const new({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: AppRadius.lgAll,
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}
