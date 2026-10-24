import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/finance/widgets/submit_button.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/controllers/roster_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class AddRosterStudentsBottomSheet extends ConsumerStatefulWidget {
  final String rosterId;
  final Set<String> existingStudentIds;

  const new({
    super.key,
    required this.rosterId,
    this.existingStudentIds = const {},
  });

  @override
  ConsumerState<AddRosterStudentsBottomSheet> createState() =>
      _AddRosterStudentsBottomSheetState();
}

class _AddRosterStudentsBottomSheetState
    extends ConsumerState<AddRosterStudentsBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  String? _selectedStudentId;
  bool _isExpanded = false;
  bool _isSaving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _noteController.addListener(_onFieldChanged);
    _noteFocusNode.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _onSelectStudent(StudentSummaryResponse student) {
    setState(() {
      _selectedStudentId = student.id;
      _isExpanded = false;
    });
  }

  Widget? _buildCharCounter(
    int currentLength,
    int maxLength, {
    required bool isFocused,
  }) {
    if (!isFocused) return null;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$currentLength/$maxLength',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _onAdd(StudentSummaryResponse selectedStudent) async {
    setState(() => _isSaving = true);

    final noteText = _noteController.text.trim();
    final note = noteText.isEmpty ? null : noteText;

    try {
      final success = await ref
          .read(rosterStudentsProvider(widget.rosterId).notifier)
          .addStudents([selectedStudent.id], note: note);

      if (!mounted) return;

      if (success) {
        ref
            .read(rosterListControllerProvider.notifier)
            .getAllRosters(forceRefresh: true);
        Navigator.of(context).pop();
      } else {
        setState(() => _isSaving = false);
        AppSnackBar.show(
          context,
          context.t.error,
          context.t.errors.unknown,
          SnackBarType.error,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackBar.show(
        context,
        context.t.error,
        context.t.errors.unknown,
        SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allStudents =
        ref.watch(studentListControllerProvider).value ??
        const <StudentSummaryResponse>[];

    final availableStudents = allStudents;

    final filteredStudents = _searchQuery.isEmpty
        ? availableStudents
        : availableStudents
              .where(
                (s) => s.fullName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    final selectedStudent = availableStudents
        .where((s) => s.id == _selectedStudentId)
        .firstOrNull;

    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = selectedStudent != null && !_isSaving;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 16,
          bottom: 8 + keyboardInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.rosters.addStudents,
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: _isSaving,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      // Student selector field
                      InkWell(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: '${context.t.students.title}*',
                            prefixIcon: const Icon(
                              FluentIcons.person_16_regular,
                            ),
                            suffixIcon: Icon(
                              _isExpanded
                                  ? FluentIcons.chevron_up_24_regular
                                  : FluentIcons.chevron_down_24_regular,
                            ),
                          ),
                          child: Text(
                            selectedStudent?.fullName ??
                                context.t.students.noStudent,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedStudent == null
                                  ? Theme.of(context).disabledColor
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      // Expanded student options with search
                      if (_isExpanded)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 220),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  onChanged: (val) =>
                                      setState(() => _searchQuery = val),
                                  decoration: InputDecoration(
                                    hintText: MaterialLocalizations.of(context)
                                        .searchFieldLabel,
                                    prefixIcon: const Icon(
                                      FluentIcons.search_16_regular,
                                      size: 18,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: filteredStudents.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          context.t.students.filter.empty,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filteredStudents.length,
                                        itemBuilder: (context, index) {
                                          final s = filteredStudents[index];
                                          final isSelected =
                                              s.id == _selectedStudentId;

                                          return ListTile(
                                            dense: true,
                                            title: Text(
                                              s.fullName,
                                              style: TextStyle(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            trailing: isSelected
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.black,
                                                  )
                                                : null,
                                            onTap: () => _onSelectStudent(s),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),

                      // Note field for roster
                      TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 255,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        buildCounter: (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                        decoration: InputDecoration(
                          labelText: context.t.note,
                          prefixIcon: const Icon(FluentIcons.note_16_regular),
                          suffixIcon: _buildCharCounter(
                            _noteController.text.length,
                            255,
                            isFocused: _noteFocusNode.hasFocus,
                          ),
                          suffixIconConstraints: const BoxConstraints(),
                        ),
                        enabled: !_isSaving,
                      ),

                      // Submit button
                      SubmitButton(
                        isLoading: _isSaving,
                        enabled: canSubmit,
                        onPressed: () {
                          if (selectedStudent != null) {
                            _onAdd(selectedStudent);
                          }
                        },
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
