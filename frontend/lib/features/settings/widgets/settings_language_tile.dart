import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/settings/widgets/language_selection_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

class SettingsLanguageTile extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageTag = ref.watch(
      languageProvider.select((state) => state.value?.languageTag ?? '...'),
    );

    return ListTile(
      leading: const Icon(Icons.outlined_flag, color: Colors.black87),
      title: Text(
        context.t.settings.language,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: Text(
        languageTag,
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
      onTap: () => AppBottomSheet.show(
        context: context,
        child: const LanguageSelectionSheet(),
      ),
    );
  }
}
