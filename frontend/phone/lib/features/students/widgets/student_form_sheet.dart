import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentFormSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final IconData submitIcon;
  final String? initialFullName;
  final DateTime? initialBirthdate;
  final String? initialPhone;
  final String? initialNote;
  final bool isLoading;
  final Future<void> Function({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
  })
  onSubmit;

  const new({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.submitIcon,
    required this.onSubmit,
    this.initialFullName,
    this.initialBirthdate,
    this.initialPhone,
    this.initialNote,
    this.isLoading = false,
  });

  @override
  State<StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<StudentFormSheet> {
  static final DateFormat _displayDate = DateFormat('dd.MM.yyyy');
  static final DateTime _firstDate = DateTime(1900);

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _noteController;
  late final TextEditingController _birthdateController;

  DateTime? _birthdate;

  @override
  void initState() {
    super.initState();
    _birthdate = widget.initialBirthdate;
    _nameController = TextEditingController(text: widget.initialFullName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _noteController = TextEditingController(text: widget.initialNote);
    _birthdateController = TextEditingController(text: _formattedBirthdate);
    _nameController.addListener(_onFieldChanged);
  }

  String get _formattedBirthdate =>
      _birthdate == null ? '' : _displayDate.format(_birthdate!);

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final lastDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _clampDate(
        _birthdate ?? DateTime(2005),
        _firstDate,
        lastDate,
      ),
      firstDate: _firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null) return;

    setState(() {
      _birthdate = picked;
      _birthdateController.text = _formattedBirthdate;
    });
  }

  void _clearBirthdate() {
    setState(() {
      _birthdate = null;
      _birthdateController.clear();
    });
  }

  DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
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
                          labelText: '${context.t.students.fullName}*',
                          prefixIcon: const Icon(FluentIcons.person_16_regular),
                        ),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        enabled: !isLoading,
                      ),

                      TextField(
                        decoration: InputDecoration(
                          labelText: context.t.students.birthdate,
                          prefixIcon: const Icon(
                            FluentIcons.calendar_ltr_16_regular,
                          ),
                          suffixIcon: (_birthdate == null || isLoading)
                              ? null
                              : IconButton(
                                  onPressed: _clearBirthdate,
                                  icon: const Icon(Icons.clear),
                                ),
                        ),
                        controller: _birthdateController,
                        readOnly: true,
                        onTap: _pickBirthdate,
                        enabled: !isLoading,
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
