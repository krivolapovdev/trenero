import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A list that is loaded a few months at a time.
///
/// The first load reaches back [monthsPerLoad] months from today, the current
/// month included. Stepping a calendar further back loads the next window of
/// months from the server instead of every record the owner ever had, so the
/// first response stays small.
///
/// Loading a month that lies before the loaded range goes through
/// [loadEarlierMonths]: the records that are already stored stay in the state
/// while a window is in flight, so a calendar keeps its blocks and the section
/// shimmers over them instead of dropping them.
abstract class MonthWindowController<T> extends AsyncNotifier<List<T>> {
  /// How many months a single load reaches across.
  static const int monthsPerLoad = 3;

  /// The first day of the earliest month that is loaded, `null` until the first
  /// load finished.
  DateTime? _loadedFrom;

  /// The last day that is loaded, `null` until the first load finished.
  DateTime? _loadedTo;

  /// Guards against loading another window while one is still in flight.
  bool _isLoading = false;

  /// The earliest month that was asked for and is not loaded yet.
  DateTime? _pendingMonth;

  /// Reads the records of the range [from]..[to] from the server.
  Future<List<T>> fetch(DateTime from, DateTime to);

  /// The month the calendar of the owner shows, the one a reload reaches back
  /// from.
  DateTime shownMonth();

  /// Marks the months before the loaded range as loading, or as done.
  void setLoadingEarlier(bool isLoading);

  /// Opens the latest month again, the one a reloaded set of records reaches
  /// back from.
  void showLatestMonth();

  /// The first day of the month [months] months before the month of [day].
  static DateTime firstDayOfMonthBefore(DateTime day, int months) =>
      DateTime(day.year, day.month - months);

  /// Whether [month] falls before [other], comparing the months only.
  static bool _isBeforeMonth(DateTime month, DateTime other) =>
      month.year < other.year ||
      (month.year == other.year && month.month < other.month);

  @override
  Future<List<T>> build() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final windowFrom = firstDayOfMonthBefore(today, monthsPerLoad - 1);

    // The calendar can show a month that lies before the window (the month that
    // is shown survives a reload of the records), so the window reaches back to
    // it instead of leaving it empty.
    final shown = shownMonth();
    final from =
        _loadedFrom ?? (shown.isBefore(windowFrom) ? shown : windowFrom);
    final to = _loadedTo ?? today;

    final records = await fetch(from, to);
    _loadedFrom = from;
    _loadedTo = to;

    return records;
  }

  /// Loads the months before the loaded range until [month] is stored too.
  ///
  /// The calendar steps one month at a time, so a single window is usually
  /// enough; the loop keeps the promise when [month] lies further back. A month
  /// that is asked for while a window is still in flight is remembered and
  /// loaded by the window that is running, so a fast run back through the
  /// months cannot leave one of them empty. While a window is in flight the
  /// records that are already stored stay and [setLoadingEarlier] reports the
  /// load, so the calendar can shimmer over the month that was opened.
  Future<void> loadEarlierMonths(DateTime month) async {
    _rememberPendingMonth(month);

    if (_isLoading || !_hasPendingMonth) return;

    _isLoading = true;
    setLoadingEarlier(true);

    // The records that are already stored, put back when a window fails.
    var current = state.value ?? <T>[];

    try {
      while (_hasPendingMonth) {
        // The window ends the day before the loaded range starts, so no record
        // is stored twice.
        final from = firstDayOfMonthBefore(_loadedFrom!, monthsPerLoad);
        final to = _loadedFrom!.subtract(const Duration(days: 1));

        final earlier = await fetch(from, to);

        current = [...earlier, ...current];
        state = AsyncData(current);
        _loadedFrom = from;
      }
    } catch (_) {
      // The records that are stored stay shown, the month can be opened again.
      state = AsyncData(current);
    } finally {
      _pendingMonth = null;
      setLoadingEarlier(false);
      _isLoading = false;
    }
  }

  /// Remembers [month] as the month that still has to be loaded, keeping the
  /// earliest one that was asked for.
  void _rememberPendingMonth(DateTime month) {
    final pending = _pendingMonth;
    if (pending == null || _isBeforeMonth(month, pending)) {
      _pendingMonth = month;
    }
  }

  /// Whether a month that was asked for still lies before the loaded range.
  bool get _hasPendingMonth =>
      _loadedFrom != null &&
      _pendingMonth != null &&
      _isBeforeMonth(_pendingMonth!, _loadedFrom!);

  /// Drops the loaded months, opens the latest month and reads the last
  /// [monthsPerLoad] months again.
  ///
  /// The state goes through loading with no value, so the calendar shimmers
  /// instead of keeping the months that are no longer loaded.
  Future<void> refresh() async {
    _loadedFrom = null;
    _loadedTo = null;

    showLatestMonth();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
