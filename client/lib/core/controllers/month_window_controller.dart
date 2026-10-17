import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class MonthWindowController<T> extends AsyncNotifier<List<T>> {
  static const int monthsPerLoad = 3;

  DateTime? _loadedFrom;

  DateTime? _loadedTo;

  bool _isLoading = false;

  DateTime? _pendingMonth;

  Future<List<T>> fetch(DateTime from, DateTime to);

  DateTime shownMonth();

  void setLoadingEarlier(bool isLoading);

  void showLatestMonth();

  static DateTime firstDayOfMonthBefore(DateTime day, int months) =>
      DateTime(day.year, day.month - months);

  static bool _isBeforeMonth(DateTime month, DateTime other) =>
      month.year < other.year ||
      (month.year == other.year && month.month < other.month);

  @override
  Future<List<T>> build() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final windowFrom = firstDayOfMonthBefore(today, monthsPerLoad - 1);

    final shown = shownMonth();
    final from =
        _loadedFrom ?? (shown.isBefore(windowFrom) ? shown : windowFrom);
    final to = _loadedTo ?? today;

    final records = await fetch(from, to);
    _loadedFrom = from;
    _loadedTo = to;

    return records;
  }

  Future<void> loadEarlierMonths(DateTime month) async {
    _rememberPendingMonth(month);

    if (_isLoading || !_hasPendingMonth) return;

    _isLoading = true;
    setLoadingEarlier(true);

    var current = state.value ?? <T>[];

    try {
      while (_hasPendingMonth) {
        final from = firstDayOfMonthBefore(_loadedFrom!, monthsPerLoad);
        final to = _loadedFrom!.subtract(const Duration(days: 1));

        final earlier = await fetch(from, to);

        current = [...earlier, ...current];
        state = AsyncData(current);
        _loadedFrom = from;
      }
    } catch (_) {
      state = AsyncData(current);
    } finally {
      _pendingMonth = null;
      setLoadingEarlier(false);
      _isLoading = false;
    }
  }

  void _rememberPendingMonth(DateTime month) {
    final pending = _pendingMonth;
    if (pending == null || _isBeforeMonth(month, pending)) {
      _pendingMonth = month;
    }
  }

  bool get _hasPendingMonth =>
      _loadedFrom != null &&
      _pendingMonth != null &&
      _isBeforeMonth(_pendingMonth!, _loadedFrom!);

  Future<void> refresh() async {
    _loadedFrom = null;
    _loadedTo = null;

    showLatestMonth();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
