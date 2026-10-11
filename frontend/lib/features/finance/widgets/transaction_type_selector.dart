import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const new({super.key, required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: SegmentedButton<TransactionType>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment<TransactionType>(
          value: TransactionType.expense,
          label: Text(context.t.finance.typeExpense),
          icon: const Icon(
            FluentIcons.arrow_down_24_regular,
            color: Colors.redAccent,
          ),
        ),
        ButtonSegment<TransactionType>(
          value: TransactionType.income,
          label: Text(context.t.finance.typeIncome),
          icon: const Icon(
            FluentIcons.arrow_up_24_regular,
            color: Colors.green,
          ),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (selection) => onChanged(selection.first),
    ),
  );
}
