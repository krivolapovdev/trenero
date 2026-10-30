import 'package:flutter/material.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/features/groups/pages/lesson_ui.dart';
import 'package:phone/features/students/extensions/student_status_extension.dart';
import 'package:phone/features/students/widgets/student_badges.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentPaymentTile extends StatelessWidget {
  final GroupStudentSummaryResponse student;
  final int number;
  final bool isSelected;
  final bool canEdit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final double? customAmount;
  final DateTime? customPaidUntil;

  const new({
    super.key,
    required this.student,
    required this.number,
    required this.isSelected,
    required this.canEdit,
    required this.onToggle,
    required this.onEdit,
    this.customAmount,
    this.customPaidUntil,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCustom = customAmount != null || customPaidUntil != null;

    final trailingWidgets = <Widget>[
      if (canEdit)
        Checkbox(
          value: isSelected,
          activeColor: student.free ? freeCheckColor : null,
          onChanged: (_) => onToggle(),
          visualDensity: VisualDensity.compact,
        ),
      if (canEdit)
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93)),
          onPressed: onEdit,
          visualDensity: VisualDensity.compact,
        ),
    ];

    Widget? subtitleWidget;
    if (isCustom) {
      final parts = <String>[];
      if (customAmount != null) {
        parts.add(customAmount!.toFormattedAmount(showSign: false));
      }
      if (customPaidUntil != null) {
        parts.add(_formatDate(customPaidUntil!));
      }
      subtitleWidget = Text(
        '${context.t.groups.customAmount}: ${parts.join(' • ')}',
        style: TextStyle(
          fontSize: 13,
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      final badges = student.statuses.toBadges(context);
      if (badges.isNotEmpty) {
        subtitleWidget = Padding(
          padding: const EdgeInsets.only(top: 4),
          child: StudentBadges(badges: badges),
        );
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      dense: true,
      onTap: canEdit ? onToggle : null,
      onLongPress: canEdit ? onEdit : null,
      leading: SizedBox(
        width: 24,
        child: Text(
          '$number.',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
      ),
      title: Text(
        student.fullName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: subtitleWidget,
      trailing: trailingWidgets.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: trailingWidgets),
    );
  }
}
