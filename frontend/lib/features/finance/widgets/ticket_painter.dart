import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_constants.dart';

class TicketPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final card = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(ticketCornerRadius),
        ),
      );

    final cutouts = Path()
      ..addOval(
        Rect.fromCircle(
          center: const Offset(0, ticketHeaderHeight + ticketDividerHeight / 2),
          radius: ticketNotchRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(
            size.width,
            ticketHeaderHeight + ticketDividerHeight / 2,
          ),
          radius: ticketNotchRadius,
        ),
      );

    final scallopDiameter = ticketScallopRadius * 2;
    final scallopCount = math.max(1, (size.width / scallopDiameter).round());
    final step = size.width / scallopCount;

    for (var i = 0; i < scallopCount; i++) {
      cutouts.addOval(
        Rect.fromCircle(
          center: Offset(step * (i + 0.5), size.height),
          radius: ticketScallopRadius,
        ),
      );
    }

    final shape = Path.combine(PathOperation.difference, card, cutouts);

    canvas
      ..drawPath(
        shape,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawPath(shape, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant TicketPainter oldDelegate) => false;
}
