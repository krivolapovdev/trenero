import 'package:flutter/material.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/pages/lesson_ui.dart';
import 'package:phone/features/groups/pages/modifiers_text.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentLessonAttendanceCard extends StatelessWidget {
  static const Duration _animationDuration = Duration(milliseconds: 250);

  final String studentName;
  final LessonAttendance? attendance;
  final bool canEdit;
  final bool hasChanges;
  final bool isAttendanceLoading;
  final bool isLoading;
  final bool isUpdate;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final VoidCallback onSubmit;

  const new({
    super.key,
    required this.studentName,
    required this.attendance,
    required this.canEdit,
    required this.hasChanges,
    required this.isAttendanceLoading,
    required this.isLoading,
    required this.isUpdate,
    required this.onToggle,
    required this.onLongPress,
    required this.onSubmit,
  });

  bool get isPresent => attendance?.status == VisitStatus.present;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unmarked = attendance == null;
    final isFree = attendance?.type == VisitType.free;
    final isPresent = attendance?.status == VisitStatus.present;

    final modifiers = <String>[
      if (attendance?.status == VisitStatus.excused) context.t.lessons.excused,
      if (attendance?.type == VisitType.free) context.t.lessons.freeLesson,
    ];

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSize(
              duration: _animationDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isAttendanceLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : InkWell(
                      onTap: canEdit && !unmarked ? onToggle : null,
                      onLongPress: canEdit ? onLongPress : null,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: unmarked
                                ? TextDecoration.lineThrough
                                : null,
                            color: unmarked
                                ? colorScheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        subtitle: modifiers.isEmpty
                            ? null
                            : ModifiersText(modifiers: modifiers),
                        trailing: unmarked
                            ? null
                            : Checkbox(
                                value: isPresent,
                                activeColor: isFree ? freeCheckColor : null,
                                onChanged: canEdit ? (_) => onToggle() : null,
                              ),
                      ),
                    ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: (isLoading || !hasChanges) ? null : onSubmit,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isUpdate ? Icons.check : Icons.add),
                label: Text(
                  isUpdate ? context.t.edit : context.t.create,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
