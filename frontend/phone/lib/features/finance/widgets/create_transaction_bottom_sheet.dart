import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/finance/controllers/create_transaction_controller.dart';
import 'package:phone/features/students/controllers/create_student_payment_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateTransactionBottomSheet extends ConsumerStatefulWidget {
  /// Student the payment is created for, pre-selected when the sheet opens.
  final String? initialStudentId;

  /// Hides the type selector and always creates an income transaction.
  final bool isIncomeOnly;

  /// Amount prefilled when the sheet opens, usually the group default price of
  /// [initialStudentId].
  final num? initialAmount;

  const new({
    super.key,
    this.initialStudentId,
    this.isIncomeOnly = false,
    this.initialAmount,
  });

  @override
  ConsumerState<CreateTransactionBottomSheet> createState() =>
      _CreateTransactionBottomSheetState();
}

class _CreateTransactionBottomSheetState
    extends ConsumerState<CreateTransactionBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paidUntilController = TextEditingController();

  TransactionType _selectedType = TransactionType.income;
  DateTime _selectedDate = DateTime.now();
  String? _selectedStudentId;
  DateTime? _paidUntil;
  bool _isLoading = false;
  bool _isCalendarExpanded = false;
  bool _isStudentExpanded = false;

  /// The last amount taken from a group default price. It allows the sheet to
  /// refresh that amount when another student is picked, while a sum typed by
  /// the user stays untouched.
  double? _autoFilledAmount;

  @override
  void initState() {
    super.initState();

    final initialAmount = widget.initialAmount?.toDouble();
    if (initialAmount != null) {
      _autoFilledAmount = initialAmount;
      _amountController.text = _formatAmount(initialAmount);
    }

    // Registered after the prefill so that it does not call setState during
    // initState.
    _amountController.addListener(_onAmountChanged);

    final initialStudentId = widget.initialStudentId;
    if (initialStudentId != null) {
      _selectedStudentId = initialStudentId;
      _paidUntil = _defaultPaidUntil;
      _paidUntilController.text = _formatDate(_paidUntil!);
    }
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paidUntilController.dispose();
    super.dispose();
  }

  bool get _isIncome => _selectedType == TransactionType.income;

  /// A student payment is an income transaction attributed to a student.
  bool get _isStudentPayment => _isIncome && _selectedStudentId != null;

  /// Prefills the paid until date with one month from the payment date.
  DateTime get _defaultPaidUntil =>
      DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);

  void _toggleCalendar() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isStudentExpanded = false;
      _isCalendarExpanded = !_isCalendarExpanded;
    });
  }

  void _toggleStudent() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isCalendarExpanded = false;
      _isStudentExpanded = !_isStudentExpanded;
    });
  }

  void _collapseStudent() {
    if (!_isStudentExpanded) return;

    setState(() {
      _isStudentExpanded = false;
    });
  }

  void _selectStudent(String? studentId) {
    final paidUntil = studentId == null
        ? null
        : (_paidUntil ?? _defaultPaidUntil);

    _applyGroupDefaultAmount(studentId);

    setState(() {
      _selectedStudentId = studentId;
      _isStudentExpanded = false;
      _paidUntil = paidUntil;
      _paidUntilController.text = paidUntil == null
          ? ''
          : _formatDate(paidUntil);
    });
  }

  Future<void> _pickPaidUntil() async {
    final lastDate = DateTime.now().add(const Duration(days: 365 * 3));
    final initialDate = _paidUntil ?? _defaultPaidUntil;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(_selectedDate)
          ? _selectedDate
          : initialDate,
      firstDate: _selectedDate,
      lastDate: lastDate,
    );

    if (picked == null) return;

    setState(() {
      _paidUntil = picked;
      _paidUntilController.text = _formatDate(picked);
    });
  }

  Future<void> _onSave() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final paidUntil = _paidUntil;
    if (_isStudentPayment && paidUntil == null) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _isCalendarExpanded = false;
      _isStudentExpanded = false;
    });

    try {
      final bool isSaved;

      if (_isStudentPayment) {
        isSaved = await ref
            .read(createStudentPaymentControllerProvider.notifier)
            .saveStudentPayment(
              studentId: _selectedStudentId!,
              amount: amount,
              date: _selectedDate,
              paidUntil: paidUntil!,
            );
      } else {
        isSaved = await ref
            .read(createTransactionControllerProvider.notifier)
            .saveTransaction(
              type: _selectedType,
              amount: amount,
              date: _selectedDate,
            );
      }

      if (!mounted) return;

      if (!isSaved) {
        final error = _isStudentPayment
            ? ref.read(createStudentPaymentControllerProvider).error
            : ref.read(createTransactionControllerProvider).error;

        AppSnackBar.show(
          context,
          error == null ? context.t.error : '${context.t.error}: $error',
          SnackBarType.error,
        );
        return;
      }

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

  /// Formats [amount] without trailing zeros, the way price fields do.
  String _formatAmount(num amount) {
    final asDouble = amount.toDouble();

    return asDouble == asDouble.roundToDouble()
        ? asDouble.toInt().toString()
        : asDouble.toString();
  }

  /// The default price of the group the given student belongs to, if any.
  double? _groupDefaultAmount(String? studentId) {
    if (studentId == null) return null;

    final students =
        ref.read(studentListControllerProvider).value ??
        const <StudentSummaryResponse>[];

    for (final student in students) {
      if (student.id == studentId) {
        return student.studentGroup?.defaultPrice?.toDouble();
      }
    }

    return null;
  }

  /// Fills the amount with the group default price of the picked student.
  ///
  /// The value is refreshed while the field still shows the previously
  /// auto-filled price, so a sum typed by the user is never overwritten.
  void _applyGroupDefaultAmount(String? studentId) {
    final defaultAmount = _groupDefaultAmount(studentId);
    if (defaultAmount == null || defaultAmount <= 0) return;

    final currentAmount = double.tryParse(_amountController.text.trim());
    final isAutoFilled =
        _autoFilledAmount != null && currentAmount == _autoFilledAmount;

    if (currentAmount != null && !isAutoFilled) return;

    _autoFilledAmount = defaultAmount;
    _amountController.text = _formatAmount(defaultAmount);
  }

  Widget _buildStudentField(
    AsyncValue<List<StudentSummaryResponse>> studentsState,
  ) {
    final students = studentsState.value ?? const <StudentSummaryResponse>[];

    if (students.isEmpty) {
      if (!studentsState.isLoading) return const SizedBox.shrink();

      return Skeletonizer(
        ignorePointers: true,
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: context.t.finance.student,
            prefixIcon: const Icon(FluentIcons.person_16_regular),
          ),
        ),
      );
    }

    final selectedStudents = students.where(
      (student) => student.id == _selectedStudentId,
    );
    final selectedStudent = selectedStudents.isEmpty
        ? null
        : selectedStudents.first;

    return Column(
      children: [
        InkWell(
          onTap: _isLoading ? null : _toggleStudent,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: context.t.finance.student,
              prefixIcon: const Icon(FluentIcons.person_16_regular),
              enabled: !_isLoading,
              suffixIcon: Icon(
                _isStudentExpanded
                    ? FluentIcons.chevron_up_24_regular
                    : FluentIcons.chevron_down_24_regular,
              ),
            ),
            child: Text(
              selectedStudent?.fullName ?? context.t.students.noStudent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: _isLoading ? Theme.of(context).disabledColor : null,
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isStudentExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      color: Colors.grey.shade50,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: [
                            _buildStudentOption(
                              label: context.t.students.noStudent,
                              value: null,
                            ),
                            ...students.map(
                              (student) => _buildStudentOption(
                                label: student.fullName,
                                value: student.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentOption({required String label, required String? value}) {
    final isSelected = _selectedStudentId == value;

    return ListTile(
      dense: true,
      enabled: !_isLoading,
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.deepPurple)
          : null,
      onTap: () => _selectStudent(value),
    );
  }

  Widget _buildPaidUntilField() => TextField(
    decoration: InputDecoration(
      labelText: '${context.t.finance.paidUntil}*',
      prefixIcon: const Icon(FluentIcons.calendar_ltr_16_regular),
    ),
    controller: _paidUntilController,
    readOnly: true,
    enabled: !_isLoading,
    onTap: () {
      _collapseStudent();
      _pickPaidUntil();
    },
  );

  @override
  Widget build(BuildContext context) {
    final isAmountEmpty = _amountController.text.trim().isEmpty;
    final isPaidUntilMissing = _isStudentPayment && _paidUntil == null;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final studentsState = ref.watch(studentListControllerProvider);

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
                      if (!widget.isIncomeOnly)
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

                                    if (!_isIncome) {
                                      _isStudentExpanded = false;
                                    }
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
                          _collapseStudent();

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
                                enabled: !_isLoading,
                                suffixIcon: Icon(
                                  _isCalendarExpanded
                                      ? FluentIcons.chevron_up_24_regular
                                      : FluentIcons.chevron_down_24_regular,
                                ),
                              ),
                              child: Text(
                                _formatDate(_selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isLoading
                                      ? Theme.of(context).disabledColor
                                      : null,
                                ),
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
                                                final date =
                                                    args.value as DateTime;
                                                final paidUntil = _paidUntil;
                                                final isValidPaidUntil =
                                                    paidUntil != null &&
                                                    !paidUntil.isBefore(date);

                                                setState(() {
                                                  _selectedDate = date;
                                                  _isCalendarExpanded = false;

                                                  if (!isValidPaidUntil) {
                                                    _paidUntil =
                                                        _isStudentPayment
                                                        ? _defaultPaidUntil
                                                        : null;
                                                    _paidUntilController.text =
                                                        _paidUntil == null
                                                        ? ''
                                                        : _formatDate(
                                                            _paidUntil!,
                                                          );
                                                  }
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

                      if (_isIncome) _buildStudentField(studentsState),

                      if (_isStudentPayment) _buildPaidUntilField(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed:
                                (isAmountEmpty ||
                                    isPaidUntilMissing ||
                                    _isLoading)
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
