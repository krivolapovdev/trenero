import 'package:flutter/material.dart';
import 'package:phone/core/widgets/titled_page.dart';

class GroupsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  @override
  Widget build(BuildContext context) =>
      const Column(children: [Center(child: Text('Groups Page'))]);
}
