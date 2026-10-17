import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentGroupsEmpty extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      context.t.groups.emptySubtitle,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
