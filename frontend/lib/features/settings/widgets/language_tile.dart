import 'package:flutter/material.dart';
import 'package:phone/core/extensions/app_locale_extension.dart';
import 'package:phone/i18n/strings.g.dart';

class LanguageTile extends StatelessWidget {
  static const double _flagFontSize = 24;

  final AppLocale locale;
  final bool selected;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Text(
      locale.flag,
      style: const TextStyle(fontSize: _flagFontSize),
    ),
    title: Text(locale.label, style: const TextStyle(fontSize: 16)),
    trailing: selected
        ? const Icon(Icons.check, color: Colors.deepPurple)
        : null,
    onTap: onTap,
  );
}
