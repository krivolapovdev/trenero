import 'package:flutter/material.dart';
import 'package:phone/features/groups/pages/lesson_ui.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

class AttendanceMark extends StatelessWidget {
  static const double _size = 48;
  static const double _iconSize = 24;

  final bool isPresent;
  final bool isFree;
  final VisitStatus? status;

  const new({
    super.key,
    required this.isPresent,
    required this.isFree,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final label = switch (status) {
      VisitStatus.present => context.t.lessons.present,
      VisitStatus.excused => context.t.lessons.excused,
      _ => context.t.lessons.absent,
    };

    return Semantics(
      label: label,
      child: SizedBox.square(
        dimension: _size,
        child: Icon(
          isPresent ? Icons.check_box : Icons.check_box_outline_blank,
          size: _iconSize,
          color: isPresent
              ? (isFree ? freeCheckColor : colorScheme.primary)
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
