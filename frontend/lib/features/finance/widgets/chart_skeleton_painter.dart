import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/chart_skeleton_colors.dart';

class ChartSkeletonPainter extends CustomPainter {
  const new();

  static const _pointFractions = [0.68, 0.42, 0.55, 0.3, 0.38, 0.18];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = chartSkeletonBoneColor.withValues(alpha: 0.55)
      ..strokeWidth = 1;

    const gridLines = 5;
    for (var i = 0; i < gridLines; i++) {
      final y = size.height * i / (gridLines - 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final horizontalInset = 6.0;
    final points = [
      for (var i = 0; i < _pointFractions.length; i++)
        Offset(
          horizontalInset +
              (size.width - horizontalInset * 2) *
                  i /
                  (_pointFractions.length - 1),
          size.height * _pointFractions[i],
        ),
    ];

    final linePaint = Paint()
      ..color = chartSkeletonBoneColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = chartSkeletonBoneColor;
    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChartSkeletonPainter oldDelegate) => false;
}
