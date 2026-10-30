import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_payments_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/models/group_student_payment.dart';
import 'package:phone/features/groups/widgets/payment_amount_card.dart';
import 'package:phone/features/groups/widgets/payment_date_card.dart';
import 'package:phone/features/groups/widgets/save_payments_action.dart';
import 'package:phone/features/groups/widgets/student_payment_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/student_payment_card.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupPaymentsPage extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupPaymentsPage> createState() => _GroupPaymentsPageState();
}

class _GroupPaymentsPageState extends ConsumerState<GroupPaymentsPage> {
  late DateTime _paymentDate;
  late DateTime _paidUntilDate;
  late final TextEditingController _amountController;

  Map<String, GroupStudentPayment>? _payments;

  @override
  void initState() {
    super.initState();
    _paymentDate = DateTime.now();
    _paidUntilDate = DateTime(
      _paymentDate.year,
      _paymentDate.month + 1,
      _paymentDate.day,
    );

    final defaultPrice = widget.group.defaultPrice;
    final initialAmount = (defaultPrice != null && defaultPrice > 0)
        ? _formatAmount(defaultPrice)
        : '';
    _amountController = TextEditingController(text: initialAmount);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() => setState(() {});

  String _formatAmount(num amount) {
    final asDouble = amount.toDouble();
    return asDouble == asDouble.roundToDouble()
        ? asDouble.toInt().toString()
        : asDouble.toString();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Map<String, GroupStudentPayment> _effectivePayments(
    List<GroupStudentSummaryResponse> students,
  ) {
    final current = _payments;
    if (current != null) return current;

    final hasAnyUnpaid = students.any(
      (s) => !s.free && !s.statuses.contains(StudentStatus.paid),
    );

    return {
      for (final student in students)
        student.id: GroupStudentPayment(
          selected:
              !student.free &&
              (hasAnyUnpaid
                  ? !student.statuses.contains(StudentStatus.paid)
                  : true),
        ),
    };
  }

  Future<void> _pickPaymentDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(_paymentDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: selected.isAfter(today) ? today : selected,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked == null || !mounted) return;

    setState(() {
      _paymentDate = picked;
      if (_paidUntilDate.isBefore(picked)) {
        _paidUntilDate = DateTime(picked.year, picked.month + 1, picked.day);
      }
    });
  }

  Future<void> _pickPaidUntilDate() async {
    final initial = _paidUntilDate.isBefore(_paymentDate)
        ? _paymentDate
        : _paidUntilDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _paymentDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _paidUntilDate = picked;
    });
  }

  void _toggleStudent(
    Map<String, GroupStudentPayment> payments,
    GroupStudentSummaryResponse student,
  ) {
    setState(() {
      final current = payments[student.id];
      final isSelected = current?.selected ?? false;
      _payments = {
        ...payments,
        student.id: (current ?? const GroupStudentPayment()).copyWith(
          selected: !isSelected,
        ),
      };
    });
  }

  void _toggleAll(
    List<GroupStudentSummaryResponse> students,
    Map<String, GroupStudentPayment> payments,
  ) {
    setState(() {
      final payingStudents = students.where((s) => !s.free).toList();
      final allSelected =
          payingStudents.isNotEmpty &&
          payingStudents.every((s) => payments[s.id]?.selected ?? false);

      final next = {...payments};
      for (final student in payingStudents) {
        final current = next[student.id] ?? const GroupStudentPayment();
        next[student.id] = current.copyWith(selected: !allSelected);
      }
      _payments = next;
    });
  }

  Future<void> _editStudent(
    GroupStudentSummaryResponse student,
    Map<String, GroupStudentPayment> payments,
  ) async {
    final currentPayment = payments[student.id];
    final defaultAmount = double.tryParse(_amountController.text.trim()) ?? 0;

    final updated = await AppBottomSheet.show<GroupStudentPayment>(
      context: context,
      child: StudentPaymentBottomSheet(
        studentName: student.fullName,
        defaultAmount: defaultAmount,
        defaultPaidUntil: _paidUntilDate,
        currentCustomAmount: currentPayment?.customAmount,
        currentCustomPaidUntil: currentPayment?.customPaidUntil,
      ),
    );

    if (!mounted || updated == null) return;

    setState(() {
      _payments = {
        ...payments,
        student.id: (currentPayment ?? const GroupStudentPayment()).copyWith(
          selected: true,
          customAmount: updated.customAmount,
          clearCustomAmount: updated.customAmount == null,
          customPaidUntil: updated.customPaidUntil,
          clearCustomPaidUntil: updated.customPaidUntil == null,
        ),
      };
    });
  }

  Future<void> _onSubmit(
    List<GroupStudentSummaryResponse> students,
    Map<String, GroupStudentPayment> payments,
  ) async {
    FocusScope.of(context).unfocus();

    final defaultAmount = double.tryParse(_amountController.text.trim());
    final items = <GroupStudentPaymentItem>[];

    for (final student in students) {
      final payment = payments[student.id];
      if (payment == null || !payment.selected) continue;

      final amount = payment.customAmount ?? defaultAmount;
      if (amount == null || amount <= 0) continue;

      final paidUntil = payment.customPaidUntil ?? _paidUntilDate;

      items.add(
        GroupStudentPaymentItem(
          studentId: student.id,
          amount: amount,
          paidUntil: paidUntil,
        ),
      );
    }

    if (items.isEmpty) return;

    final isSaved = await ref
        .read(groupPaymentsControllerProvider.notifier)
        .createPayments(
          groupId: widget.group.id,
          paymentDate: _paymentDate,
          payments: items,
        );

    if (!mounted) return;

    if (isSaved) {
      Navigator.of(context).pop();
      return;
    }

    final error = ref.read(groupPaymentsControllerProvider).error;

    AppSnackBar.show(
      context,
      context.t.error,
      error?.toString() ?? context.t.error,
      SnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final studentsState = ref.watch(groupStudentsProvider(widget.group.id));
    final isLoading = ref.watch(groupPaymentsControllerProvider).isLoading;

    final students =
        studentsState.value ?? const <GroupStudentSummaryResponse>[];
    final payments = _effectivePayments(students);

    final defaultAmount = double.tryParse(_amountController.text.trim());

    final selectedCount = students
        .where((s) => payments[s.id]?.selected ?? false)
        .length;

    final canSubmit =
        !isLoading &&
        selectedCount > 0 &&
        students.where((s) => payments[s.id]?.selected ?? false).every((s) {
          final p = payments[s.id];
          final amount = p?.customAmount ?? defaultAmount;
          return amount != null && amount > 0;
        });

    final groupName =
        ref
            .watch(groupListControllerProvider)
            .value
            ?.where((g) => g.id == widget.group.id)
            .firstOrNull
            ?.name ??
        widget.group.name;

    final canEdit = !isLoading && !studentsState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupName.isNotEmpty
              ? context.t.groups.groupPaymentsTitle(name: groupName)
              : context.t.groups.payments,
        ),
        actions: [
          SavePaymentsAction(
            isLoading: isLoading,
            enabled: canSubmit,
            onPressed: () => _onSubmit(students, payments),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: AbsorbPointer(
          absorbing: isLoading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PaymentDateCard(
                      label: context.t.finance.date,
                      formattedDate: _formatDate(_paymentDate),
                      canEdit: canEdit,
                      onTap: _pickPaymentDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PaymentDateCard(
                      label: context.t.finance.paidUntil,
                      formattedDate: _formatDate(_paidUntilDate),
                      canEdit: canEdit,
                      onTap: _pickPaidUntilDate,
                    ),
                  ),
                ],
              ),
              PaymentAmountCard(
                controller: _amountController,
                canEdit: canEdit,
              ),
              StudentPaymentCard(
                students: students,
                payments: payments,
                canEdit: canEdit,
                isLoading: studentsState.isLoading,
                onToggle: (student) => _toggleStudent(payments, student),
                onEdit: (student) => _editStudent(student, payments),
                onToggleAll: () => _toggleAll(students, payments),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
