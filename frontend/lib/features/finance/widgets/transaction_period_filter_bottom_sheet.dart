import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/calendar_month_header.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/features/finance/controllers/transaction_filter_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/models/transaction_period_filter.dart';
import 'package:phone/features/finance/widgets/sheet_title.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:table_calendar/table_calendar.dart';

enum _PeriodField { start, end }

class TransactionPeriodFilterBottomSheet extends ConsumerStatefulWidget {
  final DateTime? today;

  const new({super.key, this.today});

  @override
  ConsumerState<TransactionPeriodFilterBottomSheet> createState() =>
      _TransactionPeriodFilterBottomSheetState();
}

class _TransactionPeriodFilterBottomSheetState
    extends ConsumerState<TransactionPeriodFilterBottomSheet> {
  static final DateTime _firstDay = DateTime(2000);

  DateTime get _today => DateUtils.dateOnly(widget.today ?? DateTime.now());
  DateTime get _lastDay => _today;

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
  bool _isSyncingFields = false;

  DateTime? get _activeDate =>
      _activeField == _PeriodField.start ? _start : _end;

  bool _isAfterToday(DateTime date) => DateUtils.dateOnly(date).isAfter(_today);

  bool get _hasFutureDate =>
      (_start != null && _isAfterToday(_start!)) ||
      (_end != null && _isAfterToday(_end!));

  bool get _isInvertedRange =>
      _start != null && _end != null && _start!.isAfter(_end!);

  bool get _canApply =>
      !_isLoading && !_isInvertedRange && !_hasUnparsedInput && !_hasFutureDate;

  bool get _hasUnparsedInput =>
      _isUnparsed(_PeriodField.start) || _isUnparsed(_PeriodField.end);

  bool get _canGoToNextMonth =>
      !_isLoading &&
      (_focusedDay.year < _today.year ||
          (_focusedDay.year == _today.year &&
              _focusedDay.month < _today.month));

  bool get _canGoToPreviousMonth =>
      !_isLoading &&
      (_focusedDay.year > _firstDay.year ||
          (_focusedDay.year == _firstDay.year &&
              _focusedDay.month > _firstDay.month));

  @override
  void initState() {
    super.initState();

    final period = ref.read(transactionFilterControllerProvider);
    _start = period.start;
    _end = period.end;
    _focusedDay = _clampToRange(_start ?? _end ?? _today);

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
    final d = DateUtils.dateOnly(date);
    if (d.isBefore(_firstDay)) return _firstDay;
    if (d.isAfter(_lastDay)) return _lastDay;

    return d;
  }

  bool _isUnparsed(_PeriodField field) {
    final text = _controllerOf(field).text.trim();

    return text.isNotEmpty && DateInputField.tryParse(text) == null;
  }

  void _onStartChanged() => _onTextChanged(_PeriodField.start);

  void _onEndChanged() => _onTextChanged(_PeriodField.end);

  void _onTextChanged(_PeriodField field) {
    if (_isSyncingFields) return;

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
    if (_isAfterToday(date)) return;

    final start = _start;

    // A tap only grows the range into an end when the calendar is waiting for
    // one and the tapped day lies after the chosen start. Any other tap starts
    // a fresh range and drops a previously picked end, so days belonging to an
    // older range can never linger as unwanted extra days.
    final picksEnd =
        _activeField == _PeriodField.end &&
        start != null &&
        date.isAfter(start);

    final nextStart = picksEnd ? start : date;
    final nextEnd = picksEnd ? date : null;

    _setFieldText(_PeriodField.start, nextStart);
    _setFieldText(_PeriodField.end, nextEnd);

    setState(() {
      _start = nextStart;
      _end = nextEnd;
      _activeField = picksEnd ? _PeriodField.start : _PeriodField.end;
      _focusedDay = date;
    });
  }

  void _setFieldText(_PeriodField field, DateTime? date) {
    final controller = _controllerOf(field);
    final text = _format(date);

    if (controller.text == text) return;

    _isSyncingFields = true;
    controller.text = text;
    _isSyncingFields = false;
  }

  void _shiftMonth(int months) => setState(() {
    _focusedDay = _clampToRange(
      DateTime(_focusedDay.year, _focusedDay.month + months),
    );
  });

  bool _isSelectedDay(DateTime day) =>
      isSameDay(day, _start) || isSameDay(day, _end);

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

  Future<void> _reset() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    ref.read(transactionFilterControllerProvider.notifier).clear();
    await ref.read(transactionsControllerProvider.notifier).refresh();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleSettings.currentLocale.languageCode;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final appliedPeriod = ref.watch(transactionFilterControllerProvider);
    final canReset =
        !_isLoading &&
        (_start != null || _end != null || appliedPeriod.isNotEmpty);

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
            SheetTitle(title: context.t.finance.filter.title),
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
                    CalendarMonthHeader(
                      focusedDay: _focusedDay,
                      locale: locale,
                      onPreviousMonth: _canGoToPreviousMonth
                          ? () => _shiftMonth(-1)
                          : null,
                      onNextMonth: _canGoToNextMonth
                          ? () => _shiftMonth(1)
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildCalendar(locale),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildActions(canReset: canReset),
          ],
        ),
      ),
    );
  }

  Widget _buildActions({required bool canReset}) => Row(
    children: [
      TextButton(
        onPressed: canReset ? _reset : null,
        child: Text(
          context.t.finance.filter.reset,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      const Spacer(),
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

  String? _errorText(_PeriodField field) {
    final date = field == _PeriodField.start ? _start : _end;
    if (date != null && _isAfterToday(date)) return context.t.invalidDate;

    return null;
  }

  Widget _buildField(_PeriodField field, String label) => TextField(
    controller: _controllerOf(field),
    focusNode: _focusNodeOf(field),
    enabled: !_isLoading,
    keyboardType: TextInputType.number,
    inputFormatters: const [DateInputFormatter()],
    decoration: InputDecoration(labelText: label, errorText: _errorText(field)),
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
    enabledDayPredicate: (day) => !_isAfterToday(day),
    onDaySelected: (selectedDay, _) => _selectDay(selectedDay),
    onPageChanged: (focusedDay) =>
        setState(() => _focusedDay = _clampToRange(focusedDay)),
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
      disabledTextStyle: TextStyle(fontSize: 16, color: AppColors.mutedText),
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
