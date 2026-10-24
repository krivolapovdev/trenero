import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/rosters/controllers/update_roster_controller.dart';
import 'package:phone/features/rosters/widgets/roster_form_sheet.dart';
import 'package:phone/generated/models/roster_response.dart';
import 'package:phone/i18n/strings.g.dart';

class EditRosterBottomSheet extends ConsumerStatefulWidget {
  final RosterResponse roster;

  const new({super.key, required this.roster});

  @override
  ConsumerState<EditRosterBottomSheet> createState() =>
      _EditRosterBottomSheetState();
}

class _EditRosterBottomSheetState extends ConsumerState<EditRosterBottomSheet> {
  Future<void> _onSave({
    required String name,
    DateTime? date,
    required String note,
  }) async {
    final success = await ref
        .read(updateRosterControllerProvider.notifier)
        .updateRoster(
          rosterId: widget.roster.id,
          name: name,
          rosterDate: date,
          note: note,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final state = ref.read(updateRosterControllerProvider);
      final error = state.error;
      if (error != null) {
        AppSnackBar.show(
          context,
          context.t.error,
          error.userMessage(context.t),
          SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(updateRosterControllerProvider).isLoading;

    return RosterFormSheet(
      title: context.t.rosters.editRoster,
      submitLabel: context.t.update,
      initialName: widget.roster.name,
      initialDate: widget.roster.date,
      initialNote: widget.roster.note,
      isLoading: isLoading,
      onSubmit: _onSave,
    );
  }
}
