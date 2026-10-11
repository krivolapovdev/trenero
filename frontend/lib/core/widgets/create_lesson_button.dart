import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class CreateLessonButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const new({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    child: Text(context.t.create, style: const TextStyle(fontSize: 16)),
  );
}
