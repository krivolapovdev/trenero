import 'package:flutter/material.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

/// What [LessonAttendanceBottomSheet] popped.
///
/// A `null` [attendance] means the student was left unmarked: no visit is
/// stored for them and the one they had is deleted.
class LessonAttendanceSelection {
  final LessonAttendance? attendance;

  const new({this.attendance});
}

/// The status options the sheet offers.
///
/// "Unmarked" is not a [VisitStatus]: it means the student has no visit at all,
/// so it is kept as a choice of its own.
enum _StatusChoice { present, absent, excused, unmarked }

/// Picks the status and the type of a student's mark with radio buttons.
///
/// The status is picked from Present, Absent, Excused and Unmarked. The type is
/// only offered while a status is picked, because an unmarked student has no
/// visit. A student who studies for free always keeps a free lesson, so the type
/// is hidden and forced to Free for them.
///
/// Nothing is confirmed with a button: picking a radio pops the sheet with the
/// [LessonAttendanceSelection] it stands for, so the change is applied straight
/// away. The sheet pops with `null` when it is dismissed without a pick.
class LessonAttendanceBottomSheet extends StatelessWidget {
  /// The name of the student the sheet marks, shown as its title.
  final String studentName;

  /// Whether the student studies for free, which pins the type to Free.
  final bool free;

  /// The mark the student currently carries, `null` when they are unmarked.
  final LessonAttendance? attendance;

  const new({
    super.key,
    required this.studentName,
    required this.free,
    this.attendance,
  });

  /// The status the student currently carries, `null` while they are unmarked.
  VisitStatus? get _status => attendance?.status;

  /// The status option that is selected for the student.
  _StatusChoice get _statusChoice => switch (_status) {
    VisitStatus.present => _StatusChoice.present,
    VisitStatus.absent => _StatusChoice.absent,
    VisitStatus.excused => _StatusChoice.excused,
    _ => _StatusChoice.unmarked,
  };

  /// The type the sheet stores: a free student is always free.
  VisitType get _effectiveType =>
      free ? VisitType.free : (attendance?.type ?? VisitType.regular);

  /// The type is only offered while the student is marked and not free.
  bool get _showsType => !free && _status != null;

  /// Pops with the picked status, or unmarked when the unmarked one is picked.
  void _pickStatus(BuildContext context, _StatusChoice? choice) {
    final status = switch (choice) {
      _StatusChoice.present => VisitStatus.present,
      _StatusChoice.absent => VisitStatus.absent,
      _StatusChoice.excused => VisitStatus.excused,
      _ => null,
    };

    Navigator.of(context).pop(
      LessonAttendanceSelection(
        attendance: status == null
            ? null
            : LessonAttendance(status: status, type: _effectiveType),
      ),
    );
  }

  /// Pops with the picked type, keeping the status the student carries.
  void _pickType(BuildContext context, VisitType? type) {
    final status = _status;
    if (status == null || type == null) return;

    Navigator.of(context).pop(
      LessonAttendanceSelection(
        attendance: LessonAttendance(status: status, type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            studentName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          _buildSectionTitle(context, context.t.lessons.status),

          RadioGroup<_StatusChoice>(
            groupValue: _statusChoice,
            onChanged: (choice) => _pickStatus(context, choice),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOption(
                  context,
                  value: _StatusChoice.present,
                  label: context.t.lessons.present,
                ),
                _buildOption(
                  context,
                  value: _StatusChoice.absent,
                  label: context.t.lessons.absent,
                ),
                _buildOption(
                  context,
                  value: _StatusChoice.excused,
                  label: context.t.lessons.excused,
                ),
                _buildOption(
                  context,
                  value: _StatusChoice.unmarked,
                  label: context.t.lessons.unmarked,
                ),
              ],
            ),
          ),

          if (_showsType) ...[
            _buildSectionTitle(context, context.t.lessons.type),
            RadioGroup<VisitType>(
              groupValue: _effectiveType,
              onChanged: (type) => _pickType(context, type),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOption(
                    context,
                    value: VisitType.regular,
                    label: context.t.lessons.regular,
                  ),
                  _buildOption(
                    context,
                    value: VisitType.free,
                    label: context.t.lessons.free,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  Widget _buildSectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );

  Widget _buildOption<T>(
    BuildContext context, {
    required T value,
    required String label,
  }) => RadioListTile<T>(
    value: value,
    title: Text(label, style: const TextStyle(fontSize: 16)),
    contentPadding: EdgeInsets.zero,
    dense: true,
    visualDensity: VisualDensity.compact,
  );
}
