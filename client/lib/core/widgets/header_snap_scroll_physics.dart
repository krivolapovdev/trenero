import 'package:flutter/widgets.dart';

/// Scroll physics that ensures the persistent header has only two stable states:
/// Full (offset = 0) and Short (offset = [snapOffset]).
///
/// If scrolling finishes between 0 and [snapOffset], the ballistic simulation
/// snaps to 0.0 (Full) or [snapOffset] (Short) depending on velocity and position.
class HeaderSnapScrollPhysics extends ScrollPhysics {
  final double snapOffset;

  const new({super.parent, required this.snapOffset});

  @override
  HeaderSnapScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      HeaderSnapScrollPhysics(
        parent: buildParent(ancestor),
        snapOffset: snapOffset,
      );

  double _getTarget(ScrollMetrics position, double velocity) {
    final pixels = position.pixels;
    if (velocity.abs() > 200) {
      return velocity < 0 ? 0.0 : snapOffset;
    }
    return pixels < snapOffset / 2 ? 0.0 : snapOffset;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    final pixels = position.pixels;

    if (pixels > 0.0 && pixels < snapOffset) {
      final target = _getTarget(position, velocity);
      return ScrollSpringSimulation(
        spring,
        pixels,
        target,
        velocity,
        tolerance: toleranceFor(position),
      );
    }

    final simulation = super.createBallisticSimulation(position, velocity);
    if (simulation != null) {
      final endPixels = simulation.x(double.infinity);
      if (endPixels > 0.0 && endPixels < snapOffset) {
        final target = _getTarget(
          position.copyWith(pixels: endPixels),
          velocity,
        );
        return ScrollSpringSimulation(
          spring,
          pixels,
          target,
          velocity,
          tolerance: toleranceFor(position),
        );
      }
    }

    return simulation;
  }
}
