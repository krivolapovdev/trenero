import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/delete_confirmation_sheet.dart';
import 'package:phone/features/groups/controllers/delete_group_controller.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class DeleteGroupBottomSheet extends ConsumerWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DeleteConfirmationSheet(
    title: context.t.groups.deleteGroup,
    message: context.t.groups.deleteGroupMessage,
    delete: () async {
      final controller = deleteGroupControllerProvider;

      final success = await ref.read(controller.notifier).deleteGroup(group.id);

      if (success) return null;

      return ref.read(controller).error?.toString();
    },
  );
}
