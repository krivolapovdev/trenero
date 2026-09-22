import 'package:flutter/material.dart';
import 'package:phone/core/widgets/titled_page.dart';

class SettingsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.settings_outlined,
    super.selectedIcon = Icons.settings,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings Page')));
  }
}
