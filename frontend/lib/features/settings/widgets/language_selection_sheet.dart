import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/features/settings/widgets/language_tile.dart';
import 'package:phone/i18n/strings.g.dart';

class LanguageSelectionSheet extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider).value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.settings.selectLanguage,
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            LanguageTile(
              locale: AppLocale.ru,
              selected: currentLocale == AppLocale.ru,
              onTap: () => _select(context, ref, AppLocale.ru),
            ),
            LanguageTile(
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
