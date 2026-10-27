import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/create_group_controller.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/widgets/group_form_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

class CreateGroupBottomSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreateGroupBottomSheet> createState() =>
      _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState
    extends ConsumerState<CreateGroupBottomSheet> {
  Future<void> _onSave({
    required String name,
    required String priceText,
    required String note,
  }) async {
    final group = await ref
        .read(createGroupControllerProvider.notifier)
        .saveGroup(name: name, priceText: priceText, note: note);

    if (!mounted) return;

    if (group != null) {
      final navigator = Navigator.of(context);
      navigator.pop(group);
      navigator.push(
        MaterialPageRoute(builder: (context) => GroupPage(group: group)),
      );
    } else {
      final state = ref.read(createGroupControllerProvider);
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
    final isLoading = ref.watch(createGroupControllerProvider).isLoading;

    return GroupFormSheet(
      title: context.t.groups.createGroup,
      submitLabel: context.t.create,
      isLoading: isLoading,
      onSubmit: _onSave,
    );
  }
}
