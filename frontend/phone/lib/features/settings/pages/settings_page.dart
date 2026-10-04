import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/settings/pages/contacts_page.dart';
import 'package:phone/features/settings/widgets/language_selection_sheet.dart';
import 'package:phone/features/settings/widgets/logout_confirmation_sheet.dart';
import 'package:phone/features/settings/widgets/settings_group_card.dart';
import 'package:phone/features/settings/widgets/settings_section_title.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.settings_outlined,
    super.selectedIcon = Icons.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deleteColor = theme.colorScheme.error;
    final logoutColor = Colors.orange.shade800;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SettingsSectionTitle(title: context.t.settings.appearance),
        SettingsGroupCard(
          children: [
            Consumer(
              builder: (context, ref, child) => ListTile(
                leading: const Icon(Icons.outlined_flag, color: Colors.black87),
                title: Text(
                  context.t.settings.language,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Text(
                  ref
                      .watch(languageProvider)
                      .when(
                        data: (locale) => locale.languageTag,
                        loading: () => '...',
                        error: (_, _) => '',
                      ),
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                onTap: () => AppBottomSheet.show(
                  context: context,
                  child: const LanguageSelectionSheet(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        SettingsSectionTitle(title: context.t.settings.account),
        SettingsGroupCard(
          children: [
            ListTile(
              leading: Icon(Icons.logout, color: logoutColor),
              title: Text(
                context.t.settings.logout,
                style: TextStyle(fontSize: 16, color: logoutColor),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => AppBottomSheet.show(
                context: context,
                child: const LogoutConfirmationSheet(),
              ),
            ),

            ListTile(
              leading: Icon(Icons.delete_outline, color: deleteColor),
              title: Text(
                context.t.settings.deleteAccount,
                style: TextStyle(fontSize: 16, color: deleteColor),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        SettingsSectionTitle(title: context.t.settings.other),
        SettingsGroupCard(
          children: [
            ListTile(
              leading: const Icon(Icons.code, color: Colors.black87),
              title: Text(
                context.t.settings.version,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) => Text(
                  snapshot.hasData ? snapshot.data!.version : '...',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                color: Colors.black87,
              ),
              title: Text(
                context.t.settings.contacts,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.local_police_outlined,
                color: Colors.black87,
              ),
              title: Text(
                context.t.settings.privacyPolicy,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
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
}
