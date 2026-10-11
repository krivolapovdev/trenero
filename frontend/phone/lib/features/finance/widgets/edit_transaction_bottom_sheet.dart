import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/features/finance/controllers/update_transaction_controller.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

class EditTransactionBottomSheet extends ConsumerStatefulWidget {
  final TransactionResponse transaction;

  const new({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionBottomSheet> createState() =>
      _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState
    extends ConsumerState<EditTransactionBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  late DateTime _selectedDate;

  /// The amount the sheet was opened with, as the field shows it.
  late final String _initialAmountText;

  bool _isDateValid = true;
  bool _isLoading = false;

  /// Whether a field differs from the transaction the sheet was opened with, so
  /// that the sheet stays untouched until the user changes something.
  bool get _hasChanges =>
      _amountController.text != _initialAmountText ||
      DateUtils.dateOnly(_selectedDate) !=
          DateUtils.dateOnly(widget.transaction.date);

  @override
  void initState() {
    super.initState();

    final amount = widget.transaction.amount;
    _initialAmountText = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toString();

    _amountController
      ..text = _initialAmountText
      ..addListener(_onAmountChanged);

    _selectedDate = widget.transaction.date;
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _isDateValid = date != null;
      if (date == null) return;

      _selectedDate = date;
    });
  }

  Future<void> _onUpdate() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final updated = await ref
        .read(updateTransactionControllerProvider.notifier)
        .updateTransaction(
          transactionId: widget.transaction.id,
          amount: amount,
          date: _selectedDate,
        );

    if (!mounted) return;

    if (updated != null) {
      Navigator.of(context).pop(updated);
      return;
    }

    setState(() {
      _isLoading = false;
    });

    final error = ref.read(updateTransactionControllerProvider).error;
    if (error != null) {
      AppSnackBar.show(context, '$error', SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAmountEmpty = _amountController.text.trim().isEmpty;
    final isIncome = widget.transaction.type == TransactionType.income;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 0,
          bottom: 8 + keyboardInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.finance.editTransaction,
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isIncome
                      ? FluentIcons.arrow_up_24_regular
                      : FluentIcons.arrow_down_24_regular,
                  color: isIncome ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  isIncome
                      ? context.t.finance.typeIncome
                      : context.t.finance.typeExpense,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 22,
                    children: [
                      TextField(
                        controller: _amountController,
                        enabled: !_isLoading,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: context.t.finance.amount,
                          hintText: '0.00',
                          prefixIcon: const Icon(FluentIcons.money_24_regular),
                        ),
                      ),

                      DateInputField(
                        labelText: context.t.finance.date,
                        icon: FluentIcons.calendar_32_regular,
                        initialDate: _selectedDate,
                        lastDate: DateTime.now(),
                        enabled: !_isLoading,
                        onDateChanged: _onDateChanged,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed:
                                (isAmountEmpty ||
                                    !_isDateValid ||
                                    !_hasChanges ||
                                    _isLoading)
                                ? null
                                : _onUpdate,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            label: Text(
                              context.t.edit,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
