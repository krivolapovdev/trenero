import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class LockedStudentField extends StatelessWidget {
  final String? name;

  const new({super.key, this.name});

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: context.t.finance.student,
      prefixIcon: const Icon(FluentIcons.person_16_regular),
      enabled: false,
    ),
    child: Text(
      name ?? context.t.students.noStudent,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16, color: Theme.of(context).disabledColor),
    ),
  );
}
