import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/controllers/roster_students_controller.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class EditRosterStudentBottomSheet extends ConsumerStatefulWidget {
  final String rosterId;
  final StudentResponse student;
  final StudentSummaryResponse? fullSummary;

  const new({
    super.key,
    required this.rosterId,
    required this.student,
    this.fullSummary,
  });

  @override
  ConsumerState<EditRosterStudentBottomSheet> createState() =>
      _EditRosterStudentBottomSheetState();
}

class _EditRosterStudentBottomSheetState
    extends ConsumerState<EditRosterStudentBottomSheet> {
  late final TextEditingController _noteController;
  late final FocusNode _noteFocusNode;

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.student.note ?? '');
    _noteFocusNode = FocusNode();
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

  bool get _hasChanges =>
      _noteController.text.trim() != (widget.student.note ?? '').trim();

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

  Future<void> _onSave() async {
    setState(() => _isSaving = true);
    final noteText = _noteController.text.trim();
    final note = noteText.isEmpty ? null : noteText;

    try {
      final success = await ref
          .read(rosterStudentsProvider(widget.rosterId).notifier)
          .updateStudentNote(widget.student.id, note);

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

  Future<void> _onDelete() async {
    setState(() => _isDeleting = true);
    try {
      final success = await ref
          .read(rosterStudentsProvider(widget.rosterId).notifier)
          .removeStudent(widget.student.id);

      if (!mounted) return;

      if (success) {
        ref
            .read(rosterListControllerProvider.notifier)
            .getAllRosters(forceRefresh: true);
        Navigator.of(context).pop();
      } else {
        setState(() => _isDeleting = false);
        AppSnackBar.show(
          context,
          context.t.error,
          context.t.errors.unknown,
          SnackBarType.error,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final isBusy = _isSaving || _isDeleting;

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
              widget.student.fullName,
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: isBusy,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        maxLength: 255,
                        maxLines: 3,
                        minLines: 1,
                        buildCounter: (
                          context, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                        decoration: InputDecoration(
                          labelText: context.t.rosters.note,
                          prefixIcon: const Icon(FluentIcons.note_16_regular),
                          suffixIcon: _buildCharCounter(
                            _noteController.text.length,
                            255,
                            isFocused: _noteFocusNode.hasFocus,
                          ),
                          suffixIconConstraints: const BoxConstraints(),
                        ),
                        enabled: !isBusy,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: isBusy ? null : _onDelete,
                              icon: _isDeleting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.red,
                                      ),
                                    )
                                  : const Icon(
                                      CupertinoIcons.trash,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                              label: Text(
                                context.t.delete,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: (!_hasChanges || isBusy)
                                  ? null
                                  : _onSave,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                              label: Text(
                                context.t.update,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
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
