import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupFormSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final IconData submitIcon;
  final String? initialName;
  final String? initialPrice;
  final String? initialNote;
  final bool isLoading;
  final Future<void> Function({
    required String name,
    required String priceText,
    required String note,
  })
  onSubmit;

  const new({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.submitIcon,
    required this.onSubmit,
    this.initialName,
    this.initialPrice,
    this.initialNote,
    this.isLoading = false,
  });

  @override
  State<GroupFormSheet> createState() => _GroupFormSheetState();
}

class _GroupFormSheetState extends State<GroupFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _priceController = TextEditingController(text: widget.initialPrice);
    _noteController = TextEditingController(text: widget.initialNote);
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    FocusScope.of(context).unfocus();

    await widget.onSubmit(
      name: name,
      priceText: _priceController.text,
      note: _noteController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading;
    final isNameEmpty = _nameController.text.trim().isEmpty;
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
              widget.title,
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
                      TextField(
                        decoration: InputDecoration(
                          labelText: '${context.t.name}*',
                          prefixIcon: const Icon(
                            FluentIcons.mention_16_regular,
                          ),
                        ),
                        controller: _nameController,
                        enabled: !isLoading,
                      ),

                      TextField(
                        decoration: InputDecoration(
                          labelText: context.t.groups.defaultPrice,
                          hintText: '123.45',
                          prefixIcon: const Icon(FluentIcons.money_16_regular),
                        ),
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        enabled: !isLoading,
                      ),

                      TextField(
                        decoration: InputDecoration(
                          labelText: context.t.note,
                          prefixIcon: const Icon(FluentIcons.note_16_regular),
                        ),
                        controller: _noteController,
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
                            onPressed: (isNameEmpty || isLoading)
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
                                : Icon(widget.submitIcon),
                            label: Text(
                              widget.submitLabel,
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
