import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/pages/transaction_page.dart';
import 'package:phone/features/finance/widgets/edit_transaction_bottom_sheet.dart';
import 'package:phone/generated/models/transaction_response.dart';

class TransactionDateGroup extends StatelessWidget {
  final String dateHeader;
  final List<TransactionResponse> transactions;
  final String? overrideTitle;
  final bool isTappable;
  final ValueChanged<TransactionResponse>? onLongPress;

  const new({
    super.key,
    required this.dateHeader,
    required this.transactions,
    this.overrideTitle,
    this.isTappable = true,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.xl,
          bottom: AppSpacing.sm,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
        ),
        child: Text(
          dateHeader,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      for (final transaction in transactions)
        TransactionTile(
          key: ValueKey(transaction.id),
          transaction: transaction,
          overrideTitle: overrideTitle,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          borderRadius: BorderRadius.zero,
          onTap: isTappable
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TransactionPage(
                      transaction: transaction,
                      overrideTitle: overrideTitle,
                    ),
                  ),
                )
              : null,
          onLongPress: isTappable
              ? () => onLongPress != null
                    ? onLongPress!(transaction)
                    : AppBottomSheet.show(
                        context: context,
                        child: EditTransactionBottomSheet(
                          transaction: transaction,
                        ),
                      )
              : null,
        ),
    ],
  );
}
