import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OutlinedTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final Widget? leadingIcon;
  final int? maxLength;
  final bool isMultiLine;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const new({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.leadingIcon,
    this.maxLength,
    this.isMultiLine = false,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  State<OutlinedTextField> createState() => _OutlinedTextFieldState();
}

class _OutlinedTextFieldState extends State<OutlinedTextField> {
  final FocusNode _focusNode = FocusNode();

  bool get _isFocused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onStateChange);
    widget.controller.addListener(_onStateChange);
  }

  void _onStateChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onStateChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLength = widget.controller.text.length;

    return TextField(
      readOnly: !widget.enabled,
      controller: widget.controller,
      focusNode: _focusNode,
      maxLength: widget.maxLength,
      maxLines: widget.isMultiLine ? null : 1,
      keyboardType:
          widget.keyboardType ??
          (widget.isMultiLine ? TextInputType.multiline : TextInputType.text),
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        counterText: '',
        labelText: widget.label,
        alignLabelWithHint: widget.isMultiLine,
        labelStyle: TextStyle(
          color: _isFocused || widget.controller.text.isNotEmpty
              ? Colors.deepPurple
              : Colors.black54,
        ),
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        prefixIcon: widget.leadingIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: widget.leadingIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: widget.maxLength != null && _isFocused
            ? Padding(
                padding: const EdgeInsets.only(right: 20, left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currentLength/${widget.maxLength}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            width: _isFocused ? 1 : 0,
            color: _isFocused ? Colors.deepPurple : Colors.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(width: 1, color: Colors.deepPurple),
        ),
      ),
    );
  }
}
