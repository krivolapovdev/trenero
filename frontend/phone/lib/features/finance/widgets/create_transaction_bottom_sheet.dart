import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/finance/controllers/create_transaction_controller.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateTransactionBottomSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreateTransactionBottomSheet> createState() =>
      _CreateTransactionBottomSheetState();
}

class _CreateTransactionBottomSheetState
    extends ConsumerState<CreateTransactionBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  TransactionType _selectedType = TransactionType.income;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isCalendarExpanded = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _toggleCalendar() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
    });
  }

  Future<void> _onSave() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(createTransactionControllerProvider.notifier)
          .saveTransaction(
            type: _selectedType,
            amount: amount,
            date: _selectedDate,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, '$e', SnackBarType.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isAmountEmpty = _amountController.text.trim().isEmpty;
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
            const Text(
              'Новая транзакция',
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
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
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<TransactionType>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<TransactionType>(
                              value: TransactionType.expense,
                              label: Text('Расход'),
                              icon: Icon(
                                FluentIcons.arrow_down_24_regular,
                                color: Colors.redAccent,
                              ),
                            ),
                            ButtonSegment<TransactionType>(
                              value: TransactionType.income,
                              label: Text('Доход'),
                              icon: Icon(
                                FluentIcons.arrow_up_24_regular,
                                color: Colors.green,
                              ),
                            ),
                          ],
                          selected: {_selectedType},
                          onSelectionChanged:
                              (Set<TransactionType> newSelection) {
                                setState(() {
                                  _selectedType = newSelection.first;
                                });
                              },
                        ),
                      ),

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
                        decoration: const InputDecoration(
                          labelText: 'Сумма*',
                          hintText: '0.00',
                          prefixIcon: Icon(FluentIcons.money_24_regular),
                        ),
                        onTap: () {
                          if (_isCalendarExpanded) {
                            setState(() {
                              _isCalendarExpanded = false;
                            });
                          }
                        },
                      ),

                      Column(
                        children: [
                          InkWell(
                            onTap: _isLoading ? null : _toggleCalendar,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Дата*',
                                prefixIcon: const Icon(
                                  FluentIcons.calendar_32_regular,
                                ),
                                suffixIcon: Icon(
                                  _isCalendarExpanded
                                      ? FluentIcons.chevron_up_24_regular
                                      : FluentIcons.chevron_down_24_regular,
                                ),
                              ),
                              child: Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          ClipRect(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: _isCalendarExpanded
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: SfDateRangePicker(
                                        view: DateRangePickerView.month,
                                        monthViewSettings:
                                            DateRangePickerMonthViewSettings(
                                              firstDayOfWeek: 1,
                                            ),
                                        selectionMode:
                                            DateRangePickerSelectionMode.single,
                                        initialSelectedDate: _selectedDate,
                                        initialDisplayDate: _selectedDate,
                                        maxDate: DateTime.now(),
                                        onSelectionChanged:
                                            (
                                              DateRangePickerSelectionChangedArgs
                                              args,
                                            ) {
                                              if (args.value is DateTime) {
                                                setState(() {
                                                  _selectedDate =
                                                      args.value as DateTime;
                                                  _isCalendarExpanded = false;
                                                });
                                              }
                                            },
                                      ),
                                    )
                                  : const SizedBox(
                                      width: double.infinity,
                                      height: 0,
                                    ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: (isAmountEmpty || _isLoading)
                                ? null
                                : _onSave,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(FluentIcons.add_24_regular),
                            label: const Text(
                              'Создать',
                              style: TextStyle(fontSize: 18),
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
