import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentLessonDateCard extends StatelessWidget {
  final String formattedDate;
  final bool canEdit;
  final VoidCallback onTap;

  const new({
    super.key,
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
          labelText: context.t.lessons.date,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        ),
        child: Text(
          formattedDate,
          style: TextStyle(
            fontSize: 16,
            color: canEdit ? null : Theme.of(context).disabledColor,
          ),
        ),
      ),
    ),
  );
}
