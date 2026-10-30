import 'package:flutter/material.dart';
import 'package:phone/features/groups/models/group_student_payment.dart';
import 'package:phone/features/groups/widgets/student_payment_tile.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentPaymentCard extends StatelessWidget {
  static const double _cornerRadius = 16;

  final List<GroupStudentSummaryResponse> students;
  final Map<String, GroupStudentPayment> payments;
  final bool canEdit;
  final bool isLoading;
  final ValueChanged<GroupStudentSummaryResponse> onToggle;
  final ValueChanged<GroupStudentSummaryResponse> onEdit;
  final VoidCallback onToggleAll;

  const new({
    super.key,
    required this.students,
    required this.payments,
    required this.canEdit,
    required this.isLoading,
    required this.onToggle,
    required this.onEdit,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final isStudentsLoading = isLoading && students.isEmpty;
    final payingStudents = students.where((s) => !s.free).toList();
    final allSelected =
        payingStudents.isNotEmpty &&
        payingStudents.every((s) => payments[s.id]?.selected ?? false);

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isStudentsLoading) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.t.students.title,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else if (students.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.t.students.title,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  context.t.lessons.noStudents,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t.students.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      if (canEdit && payingStudents.isNotEmpty)
                        TextButton(
                          onPressed: onToggleAll,
                          child: Text(
                            allSelected
                                ? context.t.lessons.deselectAll
                                : context.t.lessons.selectAll,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              for (final (index, student) in students.indexed)
                StudentPaymentTile(
                  key: ValueKey(student.id),
                  student: student,
                  number: index + 1,
                  isSelected: payments[student.id]?.selected ?? false,
                  customAmount: payments[student.id]?.customAmount,
                  customPaidUntil: payments[student.id]?.customPaidUntil,
                  canEdit: canEdit,
                  onToggle: () => onToggle(student),
                  onEdit: () => onEdit(student),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
