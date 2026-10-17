import 'package:flutter/material.dart';
import 'package:phone/core/widgets/radial_fab_shadow.dart';

class PrimaryFab extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onPressed;

  const new({super.key, required this.animation, required this.onPressed});

  @override
  Widget build(BuildContext context) => Container(
    decoration: radialFabShadowDecoration,
    child: FloatingActionButton(
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: onPressed,
      child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: animation),
    ),
  );
}
