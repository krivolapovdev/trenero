import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/extensions/app_locale_extension.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/i18n/strings.g.dart';

class LanguageSelectionSheet extends ConsumerWidget {
  const new({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const LanguageSelectionSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);

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

            _buildLanguageTile(context, ref, currentLocale, AppLocale.ru),
            _buildLanguageTile(context, ref, currentLocale, AppLocale.en),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    AppLocale currentLocale,
    AppLocale targetLocale,
  ) {
    final isSelected = currentLocale == targetLocale;

    return ListTile(
      leading: Text(targetLocale.flag, style: const TextStyle(fontSize: 24)),
      title: Text(targetLocale.label, style: const TextStyle(fontSize: 16)),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.deepPurple)
          : null,
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(targetLocale);
        Navigator.pop(context);
      },
    );
  }
}
