import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/i18n/strings.g.dart';

class DateInputField extends StatefulWidget {
  final DateTime? initialDate;

  final ValueChanged<DateTime?> onDateChanged;

  final String labelText;
  final IconData? icon;
  final bool enabled;

  final DateTime? firstDate;

  final DateTime? lastDate;

  final bool allowClear;

  static const String hint = '31.12.1999';

  static const int digitCount = 8;

  const new({
    super.key,
    required this.labelText,
    required this.onDateChanged,
    this.initialDate,
    this.icon,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.allowClear = false,
  });

  static String format(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  static DateTime? tryParse(String text) {
    final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$')
        .firstMatch(text.trim());
    if (match == null) return null;

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    final date = DateTime(year, month, day);
    final isRealDate =
        date.year == year && date.month == month && date.day == day;

    return isRealDate ? date : null;
  }

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  DateTime? _date;
  String? _errorText;

  late String _handledText;

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _controller = TextEditingController(
      text: _date == null ? '' : DateInputField.format(_date!),
    );
    _handledText = _controller.text;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(DateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final next = widget.initialDate;
    if (next != oldWidget.initialDate && next != _date) {
      _isSyncing = true;
      _date = next;
      _controller.text = next == null ? '' : DateInputField.format(next);
      _handledText = _controller.text;
      _errorText = null;
      _isSyncing = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isSyncing) return;

    final text = _controller.text;
    if (text == _handledText) return;

    _handledText = text;
    _refresh();
    widget.onDateChanged(_date);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) return;
    _refresh();
  }

  void _refresh() {
    final text = _controller.text;
    final parsed = DateInputField.tryParse(text);
    final inRange = parsed != null && _isInRange(parsed);

    setState(() {
      _date = inRange ? parsed : null;
      _errorText = _errorFor(text, parsed, inRange);
    });
  }

  bool _isInRange(DateTime date) {
    final first = widget.firstDate;
    final last = widget.lastDate;

    if (first != null && date.isBefore(first)) return false;
    if (last != null && date.isAfter(last)) return false;

    return true;
  }

  String? _errorFor(String text, DateTime? parsed, bool inRange) {
    if (text.isEmpty) return null;

    if (parsed == null) {
      final isComplete =
          text.replaceAll(RegExp(r'\D'), '').length ==
          DateInputField.digitCount;
      if (!isComplete && _focusNode.hasFocus) return null;
      return context.t.invalidDate;
    }

    return inRange ? null : context.t.invalidDate;
  }

  void _clear() => _controller.clear();

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    focusNode: _focusNode,
    enabled: widget.enabled,
    keyboardType: TextInputType.number,
    inputFormatters: const [DateInputFormatter()],
    decoration: InputDecoration(
      labelText: widget.labelText,
      hintText: DateInputField.hint,
      prefixIcon: widget.icon == null ? null : Icon(widget.icon),
      errorText: _errorText,
      suffixIcon: widget.allowClear && widget.enabled && _controller.text.isNotEmpty
          ? _ClearButton(onClear: _clear)
          : null,
    ),
  );
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onClear;

  const new({required this.onClear});

  @override
  Widget build(BuildContext context) =>
      IconButton(onPressed: onClear, icon: const Icon(Icons.clear));
}

class DateInputFormatter extends TextInputFormatter {
  const new();

  static const Set<int> _separatorAfter = {2, 4};

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .padRight(DateInputField.digitCount)
        .substring(0, DateInputField.digitCount)
        .trimRight();

    final masked = _mask(digits);

    final caret = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final digitsBeforeCaret = newValue.text
        .substring(0, caret)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length
        .clamp(0, digits.length);

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(
        offset: _offsetForDigit(masked, digitsBeforeCaret),
      ),
    );
  }

  String _mask(String digits) {
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (_separatorAfter.contains(i)) buffer.write('.');
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  int _offsetForDigit(String masked, int digitCount) {
    if (digitCount <= 0) return 0;

    var seen = 0;
    for (var i = 0; i < masked.length; i++) {
      if (masked[i] == '.') continue;

      seen++;
      if (seen == digitCount) return i + 1;
    }

    return masked.length;
  }
}
