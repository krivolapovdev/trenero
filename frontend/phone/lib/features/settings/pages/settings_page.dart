import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/titled_page.dart';
import 'package:phone/features/settings/pages/contacts_page.dart';
import 'package:phone/features/settings/widgets/language_selection_sheet.dart';
import 'package:phone/features/settings/widgets/logout_confirmation_sheet.dart';
import 'package:phone/features/settings/widgets/settings_group_card.dart';
import 'package:phone/features/settings/widgets/settings_section_title.dart';
import 'package:phone/features/settings/widgets/settings_tile.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.settings_outlined,
    super.selectedIcon = Icons.settings,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16.0),
    children: [
      SettingsSectionTitle(title: context.t.settings.appearance),
      SettingsGroupCard(
        children: [
          Consumer(
            builder: (context, ref, child) => SettingsTile(
              icon: Icons.outlined_flag,
              title: context.t.settings.language,
              trailing: Text(
                ref.watch(languageProvider).name,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              onTap: () => LanguageSelectionSheet.show(context),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      SettingsSectionTitle(title: context.t.settings.account),
      SettingsGroupCard(
        children: [
          SettingsTile(
            icon: Icons.logout,
            title: context.t.settings.logout,
            trailing: const Icon(Icons.chevron_right, color: Colors.black54),
            onTap: () => LogoutConfirmationSheet.show(context),
          ),
          SettingsTile(
            icon: Icons.delete_outline,
            title: context.t.settings.deleteAccount,
            trailing: const Icon(Icons.chevron_right, color: Colors.black54),
          ),
        ],
      ),
      const SizedBox(height: 24),

      SettingsSectionTitle(title: context.t.settings.other),
      SettingsGroupCard(
        children: [
          SettingsTile(
            icon: Icons.code,
            title: context.t.settings.version,
            trailing: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) => Text(
                snapshot.hasData ? snapshot.data!.version : '...',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ),

          SettingsTile(
            icon: Icons.account_circle_outlined,
            title: context.t.settings.contacts,
            trailing: const Icon(Icons.chevron_right, color: Colors.black54),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactsPage()),
            ),
          ),

          SettingsTile(
            icon: Icons.local_police_outlined,
            title: context.t.settings.privacyPolicy,
            trailing: const Icon(Icons.link, color: Colors.black54),
            onTap: () => launchUrl(
              Uri.parse(AppConstants.privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    ],
  );
}
