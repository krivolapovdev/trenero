import 'package:flutter/material.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/features/finance/models/transaction_tile_info.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';

class TransactionTile extends StatelessWidget {
  final TransactionResponse transaction;
  final String? overrideTitle;
  final VoidCallback? onTap;

  const new({
    super.key,
    required this.transaction,
    this.overrideTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount =
        (transaction.type == TransactionType.income
                ? transaction.amount
                : -transaction.amount)
            .toFormattedAmount();
    final info = TransactionTileInfo.fromTransaction(
      transaction,
      overrideTitle: overrideTitle,
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                      ? TransactionTileInfo.incomeColor
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
