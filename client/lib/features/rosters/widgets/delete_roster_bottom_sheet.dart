import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/delete_confirmation_sheet.dart';
import 'package:phone/features/rosters/controllers/delete_roster_controller.dart';
import 'package:phone/generated/models/roster_response.dart';
import 'package:phone/i18n/strings.g.dart';

class DeleteRosterBottomSheet extends ConsumerWidget {
  final RosterResponse roster;

  const new({super.key, required this.roster});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DeleteConfirmationSheet(
    title: context.t.rosters.deleteRoster,
    message: context.t.rosters.deleteRosterMessage,
    delete: () async {
      final controller = deleteRosterControllerProvider;

      final success = await ref
          .read(controller.notifier)
          .deleteRoster(roster.id);

      if (success) return null;

      return ref.read(controller).error?.toString();
    },
  );
}
