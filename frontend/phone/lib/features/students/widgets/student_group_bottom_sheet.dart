import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/assign_student_group_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Picks the group of a student together with the day the student joined it.
///
/// The student form no longer carries a group: a student is created without a
/// group and is attached to one later through this sheet, which stores the
/// picked day as `joinedAt`. A group is required, so there is no "no group"
/// option.
class StudentGroupBottomSheet extends ConsumerStatefulWidget {
  /// The student the picked group is assigned to.
  final String studentId;

  /// The group of the student, preselected when they already belong to one.
  final String? initialGroupId;

  const new({super.key, required this.studentId, this.initialGroupId});

  @override
  ConsumerState<StudentGroupBottomSheet> createState() =>
      _StudentGroupBottomSheetState();
}

class _StudentGroupBottomSheetState
    extends ConsumerState<StudentGroupBottomSheet> {
  static final DateFormat _displayDate = DateFormat('dd.MM.yyyy');
  static final DateTime _firstDate = DateTime(1900);

  late final TextEditingController _joinedAtController;

  late DateTime _joinedAt;
  String? _groupId;

  bool _isGroupExpanded = false;

  @override
  void initState() {
    super.initState();
    _groupId = widget.initialGroupId;
    _joinedAt = DateUtils.dateOnly(DateTime.now());
    _joinedAtController = TextEditingController(text: _formattedJoinedAt);
  }

  String get _formattedJoinedAt => _displayDate.format(_joinedAt);

  @override
  void dispose() {
    _joinedAtController.dispose();
    super.dispose();
  }

  void _toggleGroup() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isGroupExpanded = !_isGroupExpanded;
    });
  }

  void _collapseGroup() {
    if (!_isGroupExpanded) return;

    setState(() {
      _isGroupExpanded = false;
    });
  }

  void _selectGroup(String groupId) {
    setState(() {
      _groupId = groupId;
      _isGroupExpanded = false;
    });
  }

  Future<void> _pickJoinedAt() async {
    final lastDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _clampDate(_joinedAt, _firstDate, lastDate),
      firstDate: _firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null) return;

    setState(() {
      _joinedAt = DateUtils.dateOnly(picked);
      _joinedAtController.text = _formattedJoinedAt;
    });
  }

  DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }

  Future<void> _onSubmit() async {
    final groupId = _groupId;
    if (groupId == null) return;

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(assignStudentGroupControllerProvider.notifier)
        .assignGroup(
          studentId: widget.studentId,
          groupId: groupId,
          joinedAt: _joinedAt,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      await ref
          .read(studentListControllerProvider.notifier)
          .getAllStudents(forceRefresh: true);
    } else {
      final error = ref.read(assignStudentGroupControllerProvider).error;
      if (error != null) {
        AppSnackBar.show(context, 'Error: $error', SnackBarType.error);
      }
    }
  }

  Widget _buildGroupField(
    List<GroupSummaryResponse> groups,
    bool isGroupsLoading,
    bool isLoading,
  ) {
    if (groups.isEmpty) {
      if (isGroupsLoading) {
        return Skeletonizer(
          ignorePointers: true,
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: context.t.students.group,
              prefixIcon: const Icon(FluentIcons.people_team_16_regular),
            ),
          ),
        );
      }

      return TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: context.t.students.group,
          hintText: context.t.groups.emptySubtitle,
          prefixIcon: const Icon(FluentIcons.people_team_16_regular),
        ),
      );
    }

    final selectedGroup = groups
        .where((group) => group.id == _groupId)
        .firstOrNull;

    return Column(
      children: [
        InkWell(
          onTap: isLoading ? null : _toggleGroup,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: context.t.students.group,
              prefixIcon: const Icon(FluentIcons.people_team_16_regular),
              suffixIcon: Icon(
                _isGroupExpanded
                    ? FluentIcons.chevron_up_24_regular
                    : FluentIcons.chevron_down_24_regular,
              ),
            ),
            child: Text(
              selectedGroup?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isGroupExpanded
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
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: [
                            ...groups.map(
                              (group) => _buildGroupOption(
                                label: group.name,
                                value: group.id,
                              ),
                            ),
                          ],
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

  Widget _buildGroupOption({required String label, required String value}) {
    final isSelected = _groupId == value;

    return ListTile(
      dense: true,
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.deepPurple)
          : null,
      onTap: () => _selectGroup(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(assignStudentGroupControllerProvider).isLoading;
    final groupsState = ref.watch(groupListControllerProvider);
    final groups = groupsState.value ?? const <GroupSummaryResponse>[];
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 0,
          bottom: 8 + keyboardInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.students.group,
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 22,
                    children: [
                      _buildGroupField(
                        groups,
                        groupsState.isLoading,
                        isLoading,
                      ),

                      TextField(
                        decoration: InputDecoration(
                          labelText: context.t.students.joinedAt,
                          prefixIcon: const Icon(
                            FluentIcons.calendar_ltr_16_regular,
                          ),
                        ),
                        controller: _joinedAtController,
                        readOnly: true,
                        onTap: () {
                          _collapseGroup();
                          _pickJoinedAt();
                        },
                        enabled: !isLoading,
                      ),

                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          vertical: 10,
                          horizontal: 0,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: (_groupId == null || isLoading)
                                ? null
                                : _onSubmit,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              context.t.update,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
