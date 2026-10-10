import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/generated/export.dart';

final studentLessonsProvider =
    AsyncNotifierProvider.family<
      StudentLessonsController,
      List<VisitWithLessonResponse>,
      String
    >(StudentLessonsController.new);

/// The lessons of a student, loaded a few months at a time.
///
/// The first load reaches back [monthsPerLoad] months from today, the current
/// month included. Stepping the calendar further back loads the next window of
/// months from the server instead of every lesson the student ever had, so the
/// first response stays small.
class StudentLessonsController
    extends AsyncNotifier<List<VisitWithLessonResponse>> {
  final String studentId;

  new(this.studentId);

  /// How many months a single load reaches across.
  static const int monthsPerLoad = 3;

  /// The first day of the earliest month that is loaded, `null` until the first
  /// load finished.
  DateTime? _loadedFrom;

  /// The last day that is loaded, `null` until the first load finished.
  DateTime? _loadedTo;

  /// Guards against loading another window while one is still in flight.
  bool _isLoading = false;

  /// The first day of the month [months] months before the month of [day].
  static DateTime firstDayOfMonthBefore(DateTime day, int months) =>
      DateTime(day.year, day.month - months);

  @override
  Future<List<VisitWithLessonResponse>> build() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from =
        _loadedFrom ??
        StudentLessonsController.firstDayOfMonthBefore(
          today,
          monthsPerLoad - 1,
        );
    final to = _loadedTo ?? today;

    final visits = await _fetch(from, to);
    _loadedFrom = from;
    _loadedTo = to;

    return visits;
  }

  Future<List<VisitWithLessonResponse>> _fetch(DateTime from, DateTime to) =>
      ref
          .read(studentRepositoryProvider)
          .getStudentVisits(studentId: studentId, from: from, to: to);

  /// Loads the months before the loaded range until [month] is stored too.
  ///
  /// The calendar steps one month at a time, so a single window is usually
  /// enough; the loop keeps the promise when [month] lies further back.
  Future<void> loadEarlierMonths(DateTime month) async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      while (_loadedFrom != null && _isBeforeMonth(month, _loadedFrom!)) {
        // The window ends the day before the loaded range starts, so no lesson
        // is stored twice.
        final from = StudentLessonsController.firstDayOfMonthBefore(
          _loadedFrom!,
          monthsPerLoad,
        );
        final to = _loadedFrom!.subtract(const Duration(days: 1));

        final earlier = await _fetch(from, to);
        final current = state.value ?? const <VisitWithLessonResponse>[];

        state = AsyncData([...earlier, ...current]);
        _loadedFrom = from;
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Whether [month] falls before [other], comparing the months only.
  static bool _isBeforeMonth(DateTime month, DateTime other) =>
      month.year < other.year ||
      (month.year == other.year && month.month < other.month);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
