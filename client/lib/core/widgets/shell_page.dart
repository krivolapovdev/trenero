import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

abstract class ShellPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  const new({
    super.key,
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });

  List<Widget> actions(BuildContext context) => const <Widget>[];

  Widget titleView(BuildContext context) => Text(title);

  Widget titleWithCount(BuildContext context, int count) => count == 0
      ? Text(title)
      : Text(context.t.titleWithCount(title: title, count: count));
}
