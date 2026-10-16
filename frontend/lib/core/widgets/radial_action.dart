import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phone/core/widgets/radial_fab_shadow.dart';

class RadialAction extends StatelessWidget {
  final Animation<double> animation;
  final double angle;
  final double distance;
  final VoidCallback onCollapse;
  final Widget child;

  const new({
    super.key,
    required this.animation,
    required this.angle,
    required this.distance,
    required this.onCollapse,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final dx = distance * math.cos(angle);
    final dy = -distance * math.sin(angle);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(dx * animation.value, dy * animation.value),
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
      ),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (_) => onCollapse(),
        child: Container(decoration: radialFabShadowDecoration, child: child),
      ),
    );
  }
}
