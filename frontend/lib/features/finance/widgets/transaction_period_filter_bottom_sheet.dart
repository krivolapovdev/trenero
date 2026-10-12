import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/features/finance/controllers/transaction_filter_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/models/transaction_period_filter.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

enum _PeriodField { start, end }

class TransactionPeriodFilterBottomSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TransactionPeriodFilterBottomSheet> createState() =>
      _TransactionPeriodFilterBottomSheetState();
}

class _TransactionPeriodFilterBottomSheetState
    extends ConsumerState<TransactionPeriodFilterBottomSheet> {
  static final DateTime _firstDay = DateTime(2000);
  static final DateTime _lastDay = DateTime(2100, 12, 31);

  static const double _rowHeight = 44;
  static const double _daysOfWeekHeight = 30;
  static const double _spinnerSize = 18;

  late final TextEditingController _startController;
  late final TextEditingController _endController;
  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _endFocusNode = FocusNode();

  DateTime? _start;
  DateTime? _end;

  late DateTime _focusedDay;

  _PeriodField _activeField = _PeriodField.start;
  bool _isLoading = false;

  DateTime? get _activeDate =>
      _activeField == _PeriodField.start ? _start : _end;

  bool get _isInvertedRange =>
      _start != null && _end != null && _start!.isAfter(_end!);

  bool get _canApply => !_isLoading && !_isInvertedRange && !_hasUnparsedInput;

  bool get _hasUnparsedInput =>
      _isUnparsed(_PeriodField.start) || _isUnparsed(_PeriodField.end);

  @override
  void initState() {
    super.initState();

    final period = ref.read(transactionFilterControllerProvider);
    _start = period.start;
    _end = period.end;
    _focusedDay = _clampToRange(
      _start ?? _end ?? DateUtils.dateOnly(DateTime.now()),
    );

    _startController = TextEditingController(text: _format(_start));
    _endController = TextEditingController(text: _format(_end));

    _startController.addListener(_onStartChanged);
    _endController.addListener(_onEndChanged);
    _startFocusNode.addListener(_onFocusChanged);
    _endFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _startController
      ..removeListener(_onStartChanged)
      ..dispose();
    _endController
      ..removeListener(_onEndChanged)
      ..dispose();
    _startFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _endFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  static String _format(DateTime? date) =>
      date == null ? '' : DateInputField.format(date);

  TextEditingController _controllerOf(_PeriodField field) =>
      field == _PeriodField.start ? _startController : _endController;

  FocusNode _focusNodeOf(_PeriodField field) =>
      field == _PeriodField.start ? _startFocusNode : _endFocusNode;

  DateTime _clampToRange(DateTime date) {
    if (date.isBefore(_firstDay)) return _firstDay;
    if (date.isAfter(_lastDay)) return _lastDay;

    return date;
  }

  bool _isUnparsed(_PeriodField field) {
    final text = _controllerOf(field).text.trim();

    return text.isNotEmpty && DateInputField.tryParse(text) == null;
  }

  void _onStartChanged() => _onTextChanged(_PeriodField.start);

  void _onEndChanged() => _onTextChanged(_PeriodField.end);

  void _onTextChanged(_PeriodField field) {
    final parsed = DateInputField.tryParse(_controllerOf(field).text);

    setState(() {
      _activeField = field;

      if (field == _PeriodField.start) {
        _start = parsed;
      } else {
        _end = parsed;
      }

      if (parsed != null) _focusedDay = _clampToRange(parsed);
    });
  }

  void _onFocusChanged() {
    if (_startFocusNode.hasFocus) {
      _activate(_PeriodField.start);
      return;
    }

    if (_endFocusNode.hasFocus) _activate(_PeriodField.end);
  }

  void _activate(_PeriodField field) {
    if (_activeField == field) return;

    setState(() {
      _activeField = field;
      _focusedDay = _clampToRange(_activeDate ?? _focusedDay);
    });
  }

  void _selectDay(DateTime selectedDay) {
    if (_isLoading) return;

    final date = DateUtils.dateOnly(selectedDay);
    final field = _activeField;
    final formatted = DateInputField.format(date);

    if (_controllerOf(field).text != formatted) {
      _controllerOf(field).text = formatted;
    }

    setState(() {
      if (field == _PeriodField.start) {
        _start = date;
      } else {
        _end = date;
      }

      _focusedDay = date;
    });
  }

  void _shiftMonth(int months) => setState(() {
    _focusedDay = _clampToRange(
      DateTime(_focusedDay.year, _focusedDay.month + months),
    );
  });

  bool _isSelectedDay(DateTime day) => isSameDay(day, _activeDate);

  Future<void> _apply() async {
    if (!_canApply) return;

    final period = TransactionPeriodFilter(start: _start, end: _end);

    if (period.sameAs(ref.read(transactionFilterControllerProvider))) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    ref.read(transactionFilterControllerProvider.notifier).setPeriod(period);
    await ref.read(transactionsControllerProvider.notifier).refresh();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleSettings.currentLocale.languageCode;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.sm + keyboardInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            _PeriodField.start,
                            context.t.finance.filter.start,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildField(
                            _PeriodField.end,
                            context.t.finance.filter.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildMonthHeader(locale),
                    const SizedBox(height: AppSpacing.xs),
                    _buildCalendar(locale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    children: [
      Expanded(
        child: Text(
          context.t.finance.filter.title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      TextButton(
        onPressed: _canApply ? _apply : null,
        child: _isLoading
            ? const SizedBox(
                width: _spinnerSize,
                height: _spinnerSize,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                context.t.finance.filter.apply,
                style: const TextStyle(fontSize: 18),
              ),
      ),
    ],
  );

  Widget _buildField(_PeriodField field, String label) => TextField(
    controller: _controllerOf(field),
    focusNode: _focusNodeOf(field),
    enabled: !_isLoading,
    keyboardType: TextInputType.number,
    inputFormatters: const [DateInputFormatter()],
    decoration: InputDecoration(labelText: label),
  );

  Widget _buildMonthHeader(String locale) => Row(
    children: [
      Expanded(
        child: Text(
          DateFormat.yMMMM(locale).format(_focusedDay),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      IconButton(
        icon: const Icon(FluentIcons.chevron_left_24_regular),
        onPressed: _isLoading ? null : () => _shiftMonth(-1),
      ),
      IconButton(
        icon: const Icon(FluentIcons.chevron_right_24_regular),
        onPressed: _isLoading ? null : () => _shiftMonth(1),
      ),
    ],
  );

  Widget _buildCalendar(String locale) => TableCalendar<void>(
    locale: locale,
    firstDay: _firstDay,
    lastDay: _lastDay,
    focusedDay: _focusedDay,
    headerVisible: false,
    rowHeight: _rowHeight,
    daysOfWeekHeight: _daysOfWeekHeight,
    startingDayOfWeek: StartingDayOfWeek.monday,
    availableGestures: AvailableGestures.horizontalSwipe,
    rangeStartDay: _start,
    rangeEndDay: _end,
    selectedDayPredicate: _isSelectedDay,
    onDaySelected: (selectedDay, _) => _selectDay(selectedDay),
    onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
    daysOfWeekStyle: DaysOfWeekStyle(
      dowTextFormatter: (weekday, dayLocale) =>
          DateFormat.E(dayLocale).format(weekday).toUpperCase(),
      weekdayStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.mutedText,
      ),
      weekendStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.mutedText,
      ),
    ),
    calendarStyle: const CalendarStyle(
      outsideDaysVisible: false,
      isTodayHighlighted: false,
      cellMargin: EdgeInsets.all(4),
      defaultTextStyle: TextStyle(fontSize: 16, color: Colors.black),
      rangeHighlightColor: AppColors.badgeSurface,
      rangeHighlightScale: 0.72,
      selectedDecoration: BoxDecoration(
        color: AppColors.badgeSurface,
        shape: BoxShape.circle,
      ),
      selectedTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.badgeOn,
      ),
      rangeStartDecoration: BoxDecoration(
        color: AppColors.badgeSurface,
        shape: BoxShape.circle,
      ),
      rangeStartTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.badgeOn,
      ),
      rangeEndDecoration: BoxDecoration(
        color: AppColors.badgeSurface,
        shape: BoxShape.circle,
      ),
      rangeEndTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.badgeOn,
      ),
      withinRangeTextStyle: TextStyle(fontSize: 16, color: Colors.black),
    ),
  );
}
