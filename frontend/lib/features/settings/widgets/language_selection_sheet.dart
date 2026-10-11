import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/extensions/app_locale_extension.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/i18n/strings.g.dart';

class LanguageSelectionSheet extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider).value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.settings.selectLanguage,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            _LanguageTile(
              locale: AppLocale.ru,
              selected: currentLocale == AppLocale.ru,
              onTap: () => _select(context, ref, AppLocale.ru),
            ),
            _LanguageTile(
              locale: AppLocale.en,
              selected: currentLocale == AppLocale.en,
              onTap: () => _select(context, ref, AppLocale.en),
            ),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, AppLocale locale) {
    ref.read(languageProvider.notifier).setLanguage(locale);
    Navigator.pop(context);
  }
}

class _LanguageTile extends StatelessWidget {
  static const double _flagFontSize = 24;

  final AppLocale locale;
  final bool selected;
  final VoidCallback onTap;

  const new({
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
