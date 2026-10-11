import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_constants.dart';

class DashedLinePainter extends CustomPainter {
  const new();

  static const double _dashWidth = 6;
  static const double _dashGap = 5;
  static const double _sideInset = ticketNotchRadius + 12;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ticketDividerColor
      ..strokeWidth = ticketDividerHeight
      ..strokeCap = StrokeCap.round;

    final end = size.width - _sideInset;
    final y = size.height / 2;

    var x = _sideInset;
    while (x < end) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + _dashWidth, end), y),
        paint,
      );
      x += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) => false;
}
