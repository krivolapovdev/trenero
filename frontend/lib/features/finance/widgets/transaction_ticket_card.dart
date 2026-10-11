import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/features/finance/models/transaction_tile_info.dart';
import 'package:phone/features/finance/widgets/dashed_line_painter.dart';
import 'package:phone/features/finance/widgets/ticket_detail.dart';
import 'package:phone/features/finance/widgets/ticket_painter.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_constants.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

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
      TicketDetail(
        label: context.t.finance.transactionId,
        value: transaction.id,
      ),
      TicketDetail(
        label: context.t.finance.date,
        value: _formatDate(transaction.date, languageCode),
      ),
      TicketDetail(
        label: context.t.finance.amount,
        value: amount,
        valueColor: isIncome ? AppColors.income : Colors.black,
      ),
      TicketDetail(
        label: context.t.finance.type,
        value: isIncome
            ? context.t.finance.typeIncome
            : context.t.finance.typeExpense,
      ),
      if (paymentDetails?.studentName != null)
        TicketDetail(
          label: context.t.finance.student,
          value: paymentDetails!.studentName!,
        ),
      if (paidUntil != null)
        TicketDetail(
          label: context.t.finance.paidUntil,
          value: _formatDate(paidUntil, languageCode),
        ),
      TicketDetail(
        label: context.t.finance.createdAt,
        value: _formatDateTime(transaction.createdAt, languageCode),
      ),
    ];

    return CustomPaint(
      painter: const TicketPainter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: ticketHeaderHeight,
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
                    child: Icon(
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
            height: ticketDividerHeight,
            child: CustomPaint(painter: DashedLinePainter()),
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
