import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentFormSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String? initialFullName;
  final DateTime? initialBirthdate;
  final String? initialPhone;
  final String? initialNote;
  final bool initialFree;
  final bool isLoading;
  final Future<void> Function({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
    required bool free,
  })
  onSubmit;

  const new({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.initialFullName,
    this.initialBirthdate,
    this.initialPhone,
    this.initialNote,
    this.initialFree = false,
    this.isLoading = false,
  });

  @override
  State<StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<StudentFormSheet> {
  static final DateTime _firstDate = DateTime(1900);

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _noteController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _noteFocusNode;

  DateTime? _birthdate;
  late bool _free;

  @override
  void initState() {
    super.initState();
    _birthdate = widget.initialBirthdate;
    _free = widget.initialFree;
    _nameController = TextEditingController(text: widget.initialFullName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _noteController = TextEditingController(text: widget.initialNote);
    _nameFocusNode = FocusNode()..addListener(_onFieldChanged);
    _noteFocusNode = FocusNode()..addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _noteController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  bool get _hasChanges =>
      _nameController.text != (widget.initialFullName ?? '') ||
      _phoneController.text != (widget.initialPhone ?? '') ||
      _noteController.text != (widget.initialNote ?? '') ||
      _birthdate != widget.initialBirthdate ||
      _free != widget.initialFree;

  void _onBirthdateChanged(DateTime? date) => setState(() => _birthdate = date);

  void _onFreeChanged(bool? value) => setState(() => _free = value ?? false);

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _nameFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final fullName = _nameController.text.trim();
    if (fullName.isEmpty) return;

    FocusScope.of(context).unfocus();

    await widget.onSubmit(
      fullName: fullName,
      birthdate: _birthdate,
      phone: _phoneController.text,
      note: _noteController.text,
      free: _free,
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
                          labelText: '${context.t.students.fullName}*',
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

                      DateInputField(
                        labelText: context.t.students.birthdate,
                        icon: FluentIcons.calendar_ltr_16_regular,
                        initialDate: _birthdate,
                        firstDate: _firstDate,
                        lastDate: DateTime.now(),
                        enabled: !isLoading,
                        allowClear: true,
                        onDateChanged: _onBirthdateChanged,
                      ),

                      TextField(
                        decoration: InputDecoration(
                          labelText: context.t.students.phone,
                          hintText: '+7 999 123-45-67',
                          prefixIcon: const Icon(FluentIcons.call_16_regular),
                        ),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-() ]'),
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

                      InkWell(
                        onTap: isLoading ? null : () => _onFreeChanged(!_free),
                        child: InputDecorator(
                          isEmpty: true,
                          decoration: InputDecoration(
                            labelText: context.t.students.free,
                            enabled: !isLoading,
                            prefixIcon: Checkbox(
                              value: _free,
                              onChanged: isLoading ? null : _onFreeChanged,
                              visualDensity: Theme.of(context).visualDensity,
                            ),
                            hintText: ' ',
                          ),
                        ),
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
