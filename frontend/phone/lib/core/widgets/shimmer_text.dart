import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const new({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(4),
    child: Shimmer(
      duration: const Duration(milliseconds: 1500),
      color: Colors.white,
      colorOpacity: 0.5,
      child: Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    ),
  );
}
