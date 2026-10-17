import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupFormSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
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
  late final FocusNode _nameFocusNode;
  late final FocusNode _noteFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _priceController = TextEditingController(text: widget.initialPrice);
    _noteController = TextEditingController(text: widget.initialNote);
    _nameController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _noteController.addListener(_onFieldChanged);
    _nameFocusNode = FocusNode()..addListener(_onFieldChanged);
    _noteFocusNode = FocusNode()..addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

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

  bool get _hasChanges =>
      _nameController.text != (widget.initialName ?? '') ||
      _priceController.text != (widget.initialPrice ?? '') ||
      _noteController.text != (widget.initialNote ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _nameFocusNode.dispose();
    _noteFocusNode.dispose();
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
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        maxLength: 255,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        buildCounter: (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                        decoration: InputDecoration(
                          labelText: '${context.t.name}*',
                          prefixIcon: const Icon(
                            FluentIcons.mention_16_regular,
                          ),
                          suffixIcon: _buildCharCounter(
                            _nameController.text.length,
                            255,
                            isFocused: _nameFocusNode.hasFocus,
                          ),
                          suffixIconConstraints: const BoxConstraints(),
                        ),
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
                        controller: _noteController,
                        focusNode: _noteFocusNode,
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
                        enabled: !isLoading,
                      ),

                      Padding(
                        padding: const EdgeInsetsGeometry.symmetric(
                          vertical: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed:
                                (isNameEmpty || !_hasChanges || isLoading)
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
                                : null,
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
