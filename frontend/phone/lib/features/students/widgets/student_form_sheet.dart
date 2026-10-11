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
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _noteController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  /// Whether a field differs from the value the form was opened with.
  ///
  /// The form of a new student starts empty, so typing the name alone is
  /// already a change; the form of a stored one keeps its action disabled
  /// until the user edits something.
  bool get _hasChanges =>
      _nameController.text != (widget.initialFullName ?? '') ||
      _phoneController.text != (widget.initialPhone ?? '') ||
      _noteController.text != (widget.initialNote ?? '') ||
      _birthdate != widget.initialBirthdate ||
      _free != widget.initialFree;

  void _onBirthdateChanged(DateTime? date) => setState(() => _birthdate = date);

  void _onFreeChanged(bool? value) => setState(() => _free = value ?? false);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
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
                        decoration: InputDecoration(
                          labelText: context.t.note,
                          prefixIcon: const Icon(FluentIcons.note_16_regular),
                        ),
                        controller: _noteController,
                        enabled: !isLoading,
                      ),

                      // The free field is drawn as the fields above: the
                      // checkbox takes the box their icons take, the name of
                      // the field takes the place of their labels and the row
                      // takes their underline.
                      InkWell(
                        onTap: isLoading ? null : () => _onFreeChanged(!_free),
                        child: InputDecorator(
                          // A field that holds nothing shows its label where a
                          // typed value would sit, so the name of the field is
                          // read in the place of a label.
                          isEmpty: true,
                          decoration: InputDecoration(
                            labelText: context.t.students.free,
                            enabled: !isLoading,
                            prefixIcon: Checkbox(
                              value: _free,
                              onChanged: isLoading ? null : _onFreeChanged,
                              // The checkbox is drawn with the density of the
                              // fields above, so it takes the same box as the
                              // icons they hold.
                              visualDensity: Theme.of(context).visualDensity,
                            ),
                            // The hint is hidden while the label holds its
                            // place, but the line it keeps is the line a value
                            // takes in the fields above, so the underlines of
                            // the fields fall in line.
                            hintText: ' ',
                            maintainHintSize: true,
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          vertical: 10,
                          horizontal: 0,
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
