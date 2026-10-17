import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class SaveLessonAction extends StatelessWidget {
  final bool isCreate;
  final bool isLoading;
  final bool hasChanges;
  final bool studentsAvailable;
  final VoidCallback onPressed;

  const new({
    super.key,
    required this.isCreate,
    required this.isLoading,
    required this.hasChanges,
    required this.studentsAvailable,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: (isLoading || !hasChanges || !studentsAvailable)
        ? null
        : onPressed,
    icon: isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
    label: Text(
      isCreate ? context.t.create : context.t.update,
      style: const TextStyle(fontSize: 18),
    ),
  );
}
