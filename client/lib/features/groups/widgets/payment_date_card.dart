import 'package:flutter/material.dart';

class PaymentDateCard extends StatelessWidget {
  final String label;
  final String formattedDate;
  final bool canEdit;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.label,
    required this.formattedDate,
    required this.canEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: canEdit ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        ),
        child: Text(formattedDate, style: const TextStyle(fontSize: 16)),
      ),
    ),
  );
}
