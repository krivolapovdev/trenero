import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/features/finance/controllers/create_transaction_controller.dart';
import 'package:phone/features/students/controllers/create_student_payment_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CreateTransactionBottomSheet extends ConsumerStatefulWidget {
  final String? initialStudentId;

  final String? initialStudentName;

  final bool isIncomeOnly;

  final bool isStudentLocked;

  final num? initialAmount;

  const new({
    super.key,
    this.initialStudentId,
    this.initialStudentName,
    this.isIncomeOnly = false,
    this.isStudentLocked = false,
    this.initialAmount,
  });

  @override
  ConsumerState<CreateTransactionBottomSheet> createState() =>
      _CreateTransactionBottomSheetState();
}

class _CreateTransactionBottomSheetState
    extends ConsumerState<CreateTransactionBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  TransactionType _selectedType = TransactionType.income;
  DateTime _selectedDate = DateTime.now();
  bool _isDateValid = true;
  String? _selectedStudentId;
  DateTime? _paidUntil;
  bool _isLoading = false;
  bool _isStudentExpanded = false;

  double? _autoFilledAmount;

  @override
  void initState() {
    super.initState();

    final initialAmount = widget.initialAmount?.toDouble();
    if (initialAmount != null) {
      _autoFilledAmount = initialAmount;
      _amountController.text = _formatAmount(initialAmount);
    }

    _amountController.addListener(_onAmountChanged);

    final initialStudentId = widget.initialStudentId;
    if (initialStudentId != null) {
      _selectedStudentId = initialStudentId;
      _paidUntil = _defaultPaidUntil;
    }
  }

  void _onAmountChanged() => setState(() {});

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isIncome => _selectedType == TransactionType.income;

  bool get _isStudentPayment => _isIncome && _selectedStudentId != null;

  DateTime get _defaultPaidUntil =>
      DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);

  DateTime get _maxPaidUntil => DateTime.now().add(const Duration(days: 365 * 3));

  void _onDateChanged(DateTime? date) {
    setState(() {
      _isDateValid = date != null;
      if (date == null) return;

      final paidUntil = _paidUntil;
      final isValidPaidUntil = paidUntil != null && !paidUntil.isBefore(date);

      _selectedDate = date;

      if (!isValidPaidUntil) {
        _paidUntil = _isStudentPayment ? _defaultPaidUntil : null;
      }
    });
  }

  void _onPaidUntilChanged(DateTime? date) {
    setState(() {
      _paidUntil = date;
    });
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;

      if (!_isIncome) {
        _isStudentExpanded = false;
      }
    });
  }

  void _toggleStudent() {
    FocusScope.of(context).unfocus();
    setState(() {
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
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, '$error', SnackBarType.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatAmount(num amount) {
    final asDouble = amount.toDouble();

    return asDouble == asDouble.roundToDouble()
        ? asDouble.toInt().toString()
        : asDouble.toString();
  }

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

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(studentListControllerProvider);
    final students = studentsState.value ?? const <StudentSummaryResponse>[];

    final isAmountEmpty = _amountController.text.trim().isEmpty;
    final isPaidUntilMissing = _isStudentPayment && _paidUntil == null;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit =
        !isAmountEmpty && !isPaidUntilMissing && _isDateValid && !_isLoading;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 22, right: 22, bottom: 8 + keyboardInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetTitle(title: context.t.finance.createTransaction),
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
                        _TransactionTypeSelector(
                          selectedType: _selectedType,
                          onChanged: _onTypeChanged,
                        ),

                      _AmountField(
                        controller: _amountController,
                        enabled: !_isLoading,
                        onTap: _collapseStudent,
                      ),

                      DateInputField(
                        labelText: '${context.t.finance.date}*',
                        icon: FluentIcons.calendar_32_regular,
                        initialDate: _selectedDate,
                        lastDate: DateTime.now(),
                        enabled: !_isLoading,
                        onDateChanged: _onDateChanged,
                      ),

                      if (_isIncome)
                        _StudentField(
                          isLocked: widget.isStudentLocked,
                          lockedStudentName: widget.initialStudentName,
                          students: students,
                          isLoading: studentsState.isLoading,
                          selectedStudentId: _selectedStudentId,
                          isExpanded: _isStudentExpanded,
                          isSubmitting: _isLoading,
                          onToggle: _toggleStudent,
                          onSelect: _selectStudent,
                        ),

                      if (_isStudentPayment)
                        _PaidUntilField(
                          initialDate: _paidUntil,
                          firstDate: _selectedDate,
                          lastDate: _maxPaidUntil,
                          enabled: !_isLoading,
                          onDateChanged: _onPaidUntilChanged,
                        ),

                      _SubmitButton(
                        isLoading: _isLoading,
                        enabled: canSubmit,
                        onPressed: _onSave,
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

class _SheetTitle extends StatelessWidget {
  final String title;

  const new({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 20, color: Colors.black),
    textAlign: TextAlign.center,
  );
}

class _TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const new({required this.selectedType, required this.onChanged});

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

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onTap;

  const new({
    required this.controller,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ],
    decoration: InputDecoration(
      labelText: '${context.t.finance.amount}*',
      hintText: '0.00',
      prefixIcon: const Icon(FluentIcons.money_24_regular),
    ),
    onTap: onTap,
  );
}

class _StudentField extends StatelessWidget {
  final bool isLocked;
  final String? lockedStudentName;
  final List<StudentSummaryResponse> students;
  final bool isLoading;
  final String? selectedStudentId;
  final bool isExpanded;
  final bool isSubmitting;
  final VoidCallback onToggle;
  final ValueChanged<String?> onSelect;

  const new({
    required this.isLocked,
    required this.students,
    required this.isLoading,
    required this.selectedStudentId,
    required this.isExpanded,
    required this.isSubmitting,
    required this.onToggle,
    required this.onSelect,
    this.lockedStudentName,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      final selectedName = students
          .where((student) => student.id == selectedStudentId)
          .firstOrNull
          ?.fullName;

      return _LockedStudentField(name: selectedName ?? lockedStudentName);
    }

    if (students.isEmpty) {
      if (!isLoading) return const SizedBox.shrink();

      return Skeletonizer(
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: context.t.finance.student,
            prefixIcon: const Icon(FluentIcons.person_16_regular),
          ),
        ),
      );
    }

    return _StudentSelectorField(
      students: students,
      selectedStudentId: selectedStudentId,
      isExpanded: isExpanded,
      isSubmitting: isSubmitting,
      onToggle: onToggle,
      onSelect: onSelect,
    );
  }
}

class _LockedStudentField extends StatelessWidget {
  final String? name;

  const new({this.name});

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: context.t.finance.student,
      prefixIcon: const Icon(FluentIcons.person_16_regular),
      enabled: false,
    ),
    child: Text(
      name ?? context.t.students.noStudent,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16, color: Theme.of(context).disabledColor),
    ),
  );
}

class _StudentSelectorField extends StatelessWidget {
  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const double _listMaxHeight = 240;

  final List<StudentSummaryResponse> students;
  final String? selectedStudentId;
  final bool isExpanded;
  final bool isSubmitting;
  final VoidCallback onToggle;
  final ValueChanged<String?> onSelect;

  const new({
    required this.students,
    required this.selectedStudentId,
    required this.isExpanded,
    required this.isSubmitting,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selectedStudent = students
        .where((student) => student.id == selectedStudentId)
        .firstOrNull;

    return Column(
      children: [
        InkWell(
          onTap: isSubmitting ? null : onToggle,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: context.t.finance.student,
              prefixIcon: const Icon(FluentIcons.person_16_regular),
              enabled: !isSubmitting,
              suffixIcon: Icon(
                isExpanded
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
                color: isSubmitting ? Theme.of(context).disabledColor : null,
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
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
                        constraints: const BoxConstraints(
                          maxHeight: _listMaxHeight,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: students.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _StudentOptionTile(
                                label: context.t.students.noStudent,
                                selected: selectedStudentId == null,
                                enabled: !isSubmitting,
                                onTap: () => onSelect(null),
                              );
                            }

                            final student = students[index - 1];

                            return _StudentOptionTile(
                              key: ValueKey(student.id),
                              label: student.fullName,
                              selected: selectedStudentId == student.id,
                              enabled: !isSubmitting,
                              onTap: () => onSelect(student.id),
                            );
                          },
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
}

class _StudentOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    enabled: enabled,
    title: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: selected
        ? const Icon(Icons.check, color: Colors.deepPurple)
        : null,
    onTap: onTap,
  );
}

class _PaidUntilField extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool enabled;
  final ValueChanged<DateTime?> onDateChanged;

  const new({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.enabled,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) => DateInputField(
    labelText: '${context.t.finance.paidUntil}*',
    icon: FluentIcons.calendar_ltr_16_regular,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    enabled: enabled,
    onDateChanged: onDateChanged,
  );
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  const new({
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        label: Text(
          context.t.create,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
}
