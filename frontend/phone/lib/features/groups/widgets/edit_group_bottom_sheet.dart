import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/update_group_controller.dart';
import 'package:phone/features/groups/widgets/group_form_sheet.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class EditGroupBottomSheet extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<EditGroupBottomSheet> createState() =>
      _EditGroupBottomSheetState();
}

class _EditGroupBottomSheetState extends ConsumerState<EditGroupBottomSheet> {
  String? _formatPrice(num? price) {
    if (price == null) return null;

    final asDouble = price.toDouble();
    return asDouble == asDouble.roundToDouble()
        ? asDouble.toInt().toString()
        : asDouble.toString();
  }

  Future<void> _onUpdate({
    required String name,
    required String priceText,
    required String note,
  }) async {
    final success = await ref
        .read(updateGroupControllerProvider.notifier)
        .updateGroup(
          groupId: widget.group.id,
          name: name,
          priceText: priceText,
          note: note,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();

      await ref
          .read(groupListControllerProvider.notifier)
          .getAllGroups(forceRefresh: true);

      if (!mounted) return;
    } else {
      final state = ref.read(updateGroupControllerProvider);
      final error = state.error;
      if (error != null) {
        AppSnackBar.show(context, 'Error: $error', SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(updateGroupControllerProvider).isLoading;
    final group = widget.group;

    return GroupFormSheet(
      title: context.t.groups.editGroup,
      submitLabel: context.t.update,
      submitIcon: Icons.check,
      isLoading: isLoading,
      initialName: group.name,
      initialPrice: _formatPrice(group.defaultPrice),
      initialNote: group.note,
      onSubmit: _onUpdate,
    );
  }
}
