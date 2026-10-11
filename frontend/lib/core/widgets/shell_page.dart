import 'package:flutter/material.dart';

abstract class ShellPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const new({
    super.key,
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });

  List<Widget>? actions(BuildContext context) => null;
}
