import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupStudentsEmpty extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      context.t.students.emptySubtitle,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
