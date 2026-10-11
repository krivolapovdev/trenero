import 'package:flutter/material.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

class LessonAttendanceSelection {
  final LessonAttendance? attendance;

  const new({this.attendance});
}

enum _StatusChoice { present, absent, excused, unmarked }

class LessonAttendanceBottomSheet extends StatelessWidget {
  final String studentName;

  final bool free;

  final LessonAttendance? attendance;

  const new({
    super.key,
    required this.studentName,
    required this.free,
    this.attendance,
  });

  VisitStatus? get _status => attendance?.status;

  _StatusChoice get _statusChoice => switch (_status) {
    VisitStatus.present => _StatusChoice.present,
    VisitStatus.absent => _StatusChoice.absent,
    VisitStatus.excused => _StatusChoice.excused,
    _ => _StatusChoice.unmarked,
  };

  VisitType get _effectiveType =>
      free ? VisitType.free : (attendance?.type ?? VisitType.regular);

  bool get _showsType => !free && _status != null;

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
