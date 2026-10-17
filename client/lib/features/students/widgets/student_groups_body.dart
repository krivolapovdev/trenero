import 'package:flutter/material.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/students/widgets/group_checkbox_tile.dart';
import 'package:phone/features/students/widgets/student_group_placeholder.dart';
import 'package:phone/features/students/widgets/student_groups_empty.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentGroupsBody extends StatelessWidget {
  final List<GroupSummaryResponse> groups;
  final Set<String> selectedGroupIds;
  final bool isLoading;
  final bool hasError;
  final Object? error;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  const new({
    super.key,
    required this.groups,
    required this.selectedGroupIds,
    required this.isLoading,
    required this.hasError,
    required this.onToggle,
    required this.onRetry,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError && groups.isEmpty) {
      return RetryView(message: error.userMessage(context.t), onRetry: onRetry);
    }

    if (!isLoading && groups.isEmpty) return const StudentGroupsEmpty();

    final displayGroups = groups.isEmpty
        ? studentGroupPlaceholderGroups
        : groups;

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: displayGroups.length,
              itemBuilder: (context, index) {
                final group = displayGroups[index];

                return GroupCheckboxTile(
                  key: ValueKey(group.id),
                  group: group,
                  selected: selectedGroupIds.contains(group.id),
                  enabled: !isLoading,
                  onToggle: () => onToggle(group.id),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
