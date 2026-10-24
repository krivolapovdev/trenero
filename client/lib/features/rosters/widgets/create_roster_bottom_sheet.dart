import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/rosters/controllers/create_roster_controller.dart';
import 'package:phone/features/rosters/widgets/roster_form_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

class CreateRosterBottomSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreateRosterBottomSheet> createState() =>
      _CreateRosterBottomSheetState();
}

class _CreateRosterBottomSheetState
    extends ConsumerState<CreateRosterBottomSheet> {
  Future<void> _onSave({
    required String name,
    DateTime? date,
    required String note,
  }) async {
    final success = await ref
        .read(createRosterControllerProvider.notifier)
        .saveRoster(name: name, date: date, note: note);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final state = ref.read(createRosterControllerProvider);
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
    final isLoading = ref.watch(createRosterControllerProvider).isLoading;

    return RosterFormSheet(
      title: context.t.rosters.createRoster,
      submitLabel: context.t.create,
      initialDate: DateTime.now(),
      isLoading: isLoading,
      onSubmit: _onSave,
    );
  }
}
