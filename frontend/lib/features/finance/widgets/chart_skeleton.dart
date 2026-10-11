import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const _boneColor = Color(0xFFE3E3E9);
const _boneHighlightColor = Color(0xFFF5F5F8);

class ChartSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 380,
    padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    child: Shimmer.fromColors(
      baseColor: _boneColor,
      highlightColor: _boneHighlightColor,
      child: Column(
        children: [
          const Expanded(
            child: CustomPaint(
              painter: _ChartSkeletonPainter(),
              child: SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              6,
              (index) =>
                  const Expanded(child: Center(child: _MonthLabelBone())),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MonthLabelBone extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 12,
    decoration: const BoxDecoration(
      color: _boneColor,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
  );
}

class _ChartSkeletonPainter extends CustomPainter {
  const new();

  static const _pointFractions = [0.68, 0.42, 0.55, 0.3, 0.38, 0.18];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _boneColor.withValues(alpha: 0.55)
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
      ..color = _boneColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = _boneColor;
    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartSkeletonPainter oldDelegate) => false;
}
