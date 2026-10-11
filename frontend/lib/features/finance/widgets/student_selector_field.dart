import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/student_option_tile.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentSelectorField extends StatelessWidget {
  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const double _listMaxHeight = 240;

  final List<StudentSummaryResponse> students;
  final String? selectedStudentId;
  final bool isExpanded;
  final bool isSubmitting;
  final VoidCallback onToggle;
  final ValueChanged<String?> onSelect;

  const new({
    super.key,
    required this.students,
    required this.selectedStudentId,
    required this.isExpanded,
    required this.isSubmitting,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selectedStudent = students
        .where((student) => student.id == selectedStudentId)
        .firstOrNull;

    return Column(
      children: [
        InkWell(
          onTap: isSubmitting ? null : onToggle,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: context.t.finance.student,
              prefixIcon: const Icon(FluentIcons.person_16_regular),
              enabled: !isSubmitting,
              suffixIcon: Icon(
                isExpanded
                    ? FluentIcons.chevron_up_24_regular
                    : FluentIcons.chevron_down_24_regular,
              ),
            ),
            child: Text(
              selectedStudent?.fullName ?? context.t.students.noStudent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: isSubmitting ? Theme.of(context).disabledColor : null,
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      color: Colors.grey.shade50,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: _listMaxHeight,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: students.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return StudentOptionTile(
                                label: context.t.students.noStudent,
                                selected: selectedStudentId == null,
                                enabled: !isSubmitting,
                                onTap: () => onSelect(null),
                              );
                            }

                            final student = students[index - 1];

                            return StudentOptionTile(
                              key: ValueKey(student.id),
                              label: student.fullName,
                              selected: selectedStudentId == student.id,
                              enabled: !isSubmitting,
                              onTap: () => onSelect(student.id),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),
      ],
    );
  }
}
