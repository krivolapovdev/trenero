import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/features/groups/models/group_student_payment.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentPaymentBottomSheet extends StatefulWidget {
  final String studentName;
  final double defaultAmount;
  final DateTime defaultPaidUntil;
  final double? currentCustomAmount;
  final DateTime? currentCustomPaidUntil;

  const new({
    super.key,
    required this.studentName,
    required this.defaultAmount,
    required this.defaultPaidUntil,
    this.currentCustomAmount,
    this.currentCustomPaidUntil,
  });

  @override
  State<StudentPaymentBottomSheet> createState() =>
      _StudentPaymentBottomSheetState();
}

class _StudentPaymentBottomSheetState extends State<StudentPaymentBottomSheet> {
  late final TextEditingController _amountController;
  late DateTime _paidUntil;

  @override
  void initState() {
    super.initState();
    final amount = widget.currentCustomAmount ?? widget.defaultAmount;
    _amountController = TextEditingController(
      text: amount > 0 ? _formatAmount(amount) : '',
    );
    _paidUntil = widget.currentCustomPaidUntil ?? widget.defaultPaidUntil;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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

  Future<void> _pickPaidUntil() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidUntil.isBefore(today) ? today : _paidUntil,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365 * 3)),
    );

    if (picked == null || !mounted) return;
    setState(() => _paidUntil = picked);
  }

  void _onReset() {
    Navigator.of(context).pop(
      const GroupStudentPayment(
        selected: true,
        customAmount: null,
        customPaidUntil: null,
      ),
    );
  }

  void _onSave() {
    final parsedAmount = double.tryParse(_amountController.text.trim());
    final isCustomAmount =
        parsedAmount != null && parsedAmount != widget.defaultAmount;
    final isCustomDate =
        DateUtils.dateOnly(_paidUntil) !=
        DateUtils.dateOnly(widget.defaultPaidUntil);

    Navigator.of(context).pop(
      GroupStudentPayment(
        selected: true,
        customAmount: isCustomAmount ? parsedAmount : null,
        customPaidUntil: isCustomDate ? _paidUntil : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final hasCustomValues =
        widget.currentCustomAmount != null ||
        widget.currentCustomPaidUntil != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          bottom: 22 + keyboardInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              widget.studentName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: '${context.t.finance.amount}*',
                hintText: '0.00',
                prefixIcon: const Icon(FluentIcons.money_24_regular),
              ),
            ),
            InkWell(
              onTap: _pickPaidUntil,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: context.t.finance.paidUntil,
                  prefixIcon: const Icon(FluentIcons.calendar_24_regular),
                ),
                child: Text(
                  _formatDate(_paidUntil),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (hasCustomValues)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onReset,
                      child: Text(context.t.reset),
                    ),
                  ),
                if (hasCustomValues) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _onSave,
                    child: Text(context.t.create),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
