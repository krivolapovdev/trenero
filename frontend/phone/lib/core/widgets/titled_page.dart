import 'package:flutter/material.dart';

abstract class TitledPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const new({
    super.key,
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}
