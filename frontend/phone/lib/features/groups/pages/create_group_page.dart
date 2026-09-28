import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/error_snack_bar.dart';
import 'package:phone/core/widgets/outlined_input_field.dart';
import 'package:phone/features/groups/providers/create_group_notifier.dart';
import 'package:phone/features/groups/providers/groups_notifier.dart';
import 'package:phone/i18n/strings.g.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final success = await ref
        .read(createGroupNotifierProvider.notifier)
        .saveGroup(
          name: name,
          priceText: _priceController.text,
          note: _noteController.text,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      await ref.read(groupsNotifierProvider.notifier).refreshGroups();
    } else {
      final state = ref.read(createGroupNotifierProvider);
      final error = state.error;
      if (error != null) {
        ErrorSnackBar.show(context, 'Error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createGroupNotifierProvider, (previous, next) {
      if (next.isLoading) {
        FocusScope.of(context).unfocus();
      }
    });

    final createState = ref.watch(createGroupNotifierProvider);
    final isLoading = createState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(context.t.groups.createGroup),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _nameController,
            builder: (context, value, child) {
              final isNameEmpty = value.text.trim().isEmpty;

              return IconButton(
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded, size: 28),
                onPressed: (isNameEmpty || isLoading) ? null : _onSave,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            OutlinedTextField(
              label: '${context.t.name} *',
              controller: _nameController,
              leadingIcon: const Icon(Icons.alternate_email),
              maxLength: 255,
              enabled: !isLoading,
            ),

            const SizedBox(height: 24),

            OutlinedTextField(
              label: context.t.groups.defaultPrice,
              controller: _priceController,
              hint: '123.45',
              leadingIcon: const Icon(Icons.attach_money),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              enabled: !isLoading,
            ),

            const SizedBox(height: 24),

            OutlinedTextField(
              label: context.t.note,
              controller: _noteController,
              leadingIcon: const Icon(Icons.notes),
              maxLength: 1023,
              isMultiLine: true,
              enabled: !isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
