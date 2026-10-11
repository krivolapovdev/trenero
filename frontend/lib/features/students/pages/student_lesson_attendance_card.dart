import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentLessonAttendanceCard extends StatelessWidget {
  static const Duration _animationDuration = Duration(milliseconds: 250);

  final String studentName;
  final bool isPresent;
  final bool canEdit;
  final bool hasChanges;
  final bool isAttendanceLoading;
  final bool isLoading;
  final bool isUpdate;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  const new({
    super.key,
    required this.studentName,
    required this.isPresent,
    required this.canEdit,
    required this.hasChanges,
    required this.isAttendanceLoading,
    required this.isLoading,
    required this.isUpdate,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Material(
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
                : CheckboxListTile(
                    value: isPresent,
                    onChanged: canEdit ? (_) => onToggle() : null,
                    title: Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
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
