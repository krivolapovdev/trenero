import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/features/finance/models/transaction_tile_info.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

const double _headerHeight = 160;
const double _dividerHeight = 1;
const double _cornerRadius = 24;
const double _notchRadius = 14;
const double _scallopRadius = 9;
const Color _mutedColor = Color(0xFF8E8E93);
const Color _dividerColor = Color(0xFFD9D9D9);

/// Ticket shaped card with a header (icon + title) and all transaction
/// details below the perforated divider line.
class TransactionTicketCard extends StatelessWidget {
  final TransactionResponse transaction;
  final String? overrideTitle;

  const new({super.key, required this.transaction, this.overrideTitle});

  @override
  Widget build(BuildContext context) {
    final info = TransactionTileInfo.fromTransaction(
      transaction,
      overrideTitle: overrideTitle,
    );
    final languageCode = LocaleSettings.currentLocale.languageCode;
    final paymentDetails = transaction.paymentDetails;
    final isIncome = transaction.type == TransactionType.income;
    final amount = (isIncome ? transaction.amount : -transaction.amount)
        .toFormattedAmount();
    final paidUntil = paymentDetails?.paidUntil;

    final details = <Widget>[
      _TicketDetail(
        label: context.t.finance.transactionId,
        value: transaction.id,
      ),
      _TicketDetail(
        label: context.t.finance.date,
        value: _formatDate(transaction.date, languageCode),
      ),
      _TicketDetail(
        label: context.t.finance.amount,
        value: amount,
        valueColor: isIncome ? TransactionTileInfo.incomeColor : Colors.black,
      ),
      _TicketDetail(
        label: context.t.finance.type,
        value: isIncome
            ? context.t.finance.typeIncome
            : context.t.finance.typeExpense,
      ),
      if (paymentDetails?.studentName != null)
        _TicketDetail(
          label: context.t.finance.student,
          value: paymentDetails!.studentName!,
        ),
      if (paidUntil != null)
        _TicketDetail(
          label: context.t.finance.paidUntil,
          value: _formatDate(paidUntil, languageCode),
        ),
      _TicketDetail(
        label: context.t.finance.createdAt,
        value: _formatDateTime(transaction.createdAt, languageCode),
      ),
    ];

    return CustomPaint(
      painter: const _TicketPainter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _headerHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: info.backgroundColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: info.initials != null
                        ? Text(
                            info.initials!,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: info.backgroundColor,
                            ),
                          )
                        : Icon(
                            info.icon,
                            size: 34,
                            color: info.backgroundColor,
                          ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      info.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: _dividerHeight,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: details,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, String languageCode) =>
      DateFormat('d MMM, yyyy', languageCode).format(date).toUpperCase();

  String _formatDateTime(DateTime date, String languageCode) =>
      DateFormat('d MMM, yyyy HH:mm', languageCode).format(date).toUpperCase();
}

class _TicketDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const new({
    required this.label,
    required this.value,
    this.valueColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
          color: _mutedColor,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        value,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    ],
  );
}

class _TicketPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final card = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_cornerRadius),
        ),
      );

    final cutouts = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(0, _headerHeight + _dividerHeight / 2),
          radius: _notchRadius,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, _headerHeight + _dividerHeight / 2),
          radius: _notchRadius,
        ),
      );

    // Scalloped bottom edge, imitating a torn ticket.
    final scallopDiameter = _scallopRadius * 2;
    final scallopCount = math.max(1, (size.width / scallopDiameter).round());
    final step = size.width / scallopCount;

    for (var i = 0; i < scallopCount; i++) {
      cutouts.addOval(
        Rect.fromCircle(
          center: Offset(step * (i + 0.5), size.height),
          radius: _scallopRadius,
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
  bool shouldRepaint(covariant _TicketPainter oldDelegate) => false;
}

class _DashedLinePainter extends CustomPainter {
  const new();

  static const double _dashWidth = 6;
  static const double _dashGap = 5;
  static const double _sideInset = _notchRadius + 12;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _dividerColor
      ..strokeWidth = _dividerHeight
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
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}
