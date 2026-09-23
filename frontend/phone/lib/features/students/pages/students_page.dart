import 'package:flutter/material.dart';
import 'package:phone/core/widgets/titled_page.dart';

class StudentsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.groups_2_outlined,
    super.selectedIcon = Icons.groups_2,
  });

  @override
  Widget build(BuildContext context) =>
      const Column(children: [Center(child: Text('Students Page'))]);
}
