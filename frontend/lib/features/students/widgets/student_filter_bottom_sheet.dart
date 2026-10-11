import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/extensions/student_status_extension.dart';
import 'package:phone/features/students/models/student_filter.dart';
import 'package:phone/features/students/widgets/filter_checkbox_tile.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentFilterBottomSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<StudentFilterBottomSheet> createState() =>
      _StudentFilterBottomSheetState();
}

class _StudentFilterBottomSheetState
    extends ConsumerState<StudentFilterBottomSheet> {
  late StudentFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(studentFilterControllerProvider);
  }

  void _toggleGroup(String groupId) =>
      setState(() => _draft = _draft.toggleGroup(groupId));

  void _toggleStatus(StudentStatus status) =>
      setState(() => _draft = _draft.toggleStatus(status));

  void _reset() => setState(() => _draft = const StudentFilter());

  void _apply() {
    ref.read(studentFilterControllerProvider.notifier).setFilter(_draft);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupListControllerProvider);
    final groups = groupsState.value ?? const <GroupSummaryResponse>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 22, right: 22, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.students.filter.title,
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FilterSectionTitle(title: context.t.students.filter.group),

                    if (groupsState.isLoading && groups.isEmpty)
                      const _FilterLoading()
                    else ...[
                      if (groups.isNotEmpty)
                        FilterCheckboxTile(
                          label: context.t.groups.noGroup,
                          isSelected: _draft.groupIds.contains(
                            StudentFilter.noGroupId,
                          ),
                          onToggle: () => _toggleGroup(StudentFilter.noGroupId),
                        ),

                      for (final group in groups)
                        FilterCheckboxTile(
                          key: ValueKey(group.id),
                          label: group.name,
                          isSelected: _draft.groupIds.contains(group.id),
                          onToggle: () => _toggleGroup(group.id),
                        ),
                    ],

                    const SizedBox(height: 8),

                    _FilterSectionTitle(
                      title: context.t.students.filter.status,
                    ),

                    for (final status in StudentStatus.$valuesDefined)
                      FilterCheckboxTile(
                        key: ValueKey(status.name),
                        label: status.label(context),
                        isSelected: _draft.statuses.contains(status),
                        onToggle: () => _toggleStatus(status),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                TextButton(
                  onPressed: _draft.isEmpty ? null : _reset,
                  child: Text(context.t.students.filter.reset),
                ),

                const Spacer(),

                TextButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.check),
                  label: Text(
                    context.t.students.filter.apply,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  final String title;

  const new({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );
}

class _FilterLoading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Center(child: CircularProgressIndicator()),
  );
}
