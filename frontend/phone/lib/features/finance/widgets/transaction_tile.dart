import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/extensions/number_extensions.dart';
import 'package:phone/core/extensions/string_extensions.dart';
import 'package:phone/features/finance/models/transaction_tile_info.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';

class TransactionTile extends StatelessWidget {
  final TransactionResponse transaction;

  const new({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formattedAmount =
        (transaction.type == TransactionType.income
                ? transaction.amount
                : -transaction.amount)
            .toFormattedAmount();
    final info = _getTransactionDisplayInfo(transaction);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: info.backgroundColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: info.initials != null
                  ? Text(
                      info.initials!,
                      style: TextStyle(
                        fontSize: 18,
                        color: info.backgroundColor,
                      ),
                    )
                  : Icon(info.icon, color: info.backgroundColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                Text(
                  info.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: transaction.type == TransactionType.income
                  ? const Color(0xFF28A745)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  TransactionTileInfo _getTransactionDisplayInfo(TransactionResponse tx) {
    final studentPayment = tx.studentPayment;

    if (studentPayment != null) {
      final studentName = studentPayment.fullName;
      final paidUntilFormatted = DateFormat('dd.MM.yyyy')
          .format(studentPayment.paidUntil);

      return TransactionTileInfo(
        title: studentName,
        subtitle: 'Оплачено до $paidUntilFormatted',
        initials: studentName.initials,
        backgroundColor: const Color(0xFF28A745),
      );
    }

    final isIncome = tx.type == TransactionType.income;
    final timeFormatted = DateFormat('HH:mm').format(tx.createdAt);

    return TransactionTileInfo(
      title: isIncome ? 'Пополнение' : 'Списание',
      subtitle: timeFormatted,
      icon: isIncome
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      backgroundColor: isIncome
          ? const Color(0xFF28A745)
          : const Color(0xFFE00153),
    );
  }
}
