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

  /// The widget shown in the app bar. Override it to make the title dynamic.
  Widget titleView(BuildContext context) => Text(title);

  /// Builds the [title] with the number of items currently in the list,
  /// e.g. `Students [34]`. A zero [count] hides the number.
  Widget titleWithCount(BuildContext context, int count) => count == 0
      ? Text(title)
      : Text(context.t.titleWithCount(title: title, count: count));
}
