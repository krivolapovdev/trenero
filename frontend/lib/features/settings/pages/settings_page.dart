import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/settings/pages/contacts_page.dart';
import 'package:phone/features/settings/widgets/app_version_tile.dart';
import 'package:phone/features/settings/widgets/delete_account_bottom_sheet.dart';
import 'package:phone/features/settings/widgets/logout_confirmation_sheet.dart';
import 'package:phone/features/settings/widgets/settings_group_card.dart';
import 'package:phone/features/settings/widgets/settings_language_tile.dart';
import 'package:phone/features/settings/widgets/settings_nav_tile.dart';
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
        const SettingsGroupCard(children: [SettingsLanguageTile()]),
        const SizedBox(height: 24),

        SettingsSectionTitle(title: context.t.settings.account),
        SettingsGroupCard(
          children: [
            SettingsNavTile(
              leading: Icon(Icons.logout, color: logoutColor),
              title: context.t.settings.logout,
              color: logoutColor,
              onTap: () => AppBottomSheet.show(
                context: context,
                child: const LogoutConfirmationSheet(),
              ),
            ),

            SettingsNavTile(
              leading: Icon(Icons.delete_outline, color: deleteColor),
              title: context.t.settings.deleteAccount,
              color: deleteColor,
              onTap: () => AppBottomSheet.show(
                context: context,
                child: const DeleteAccountBottomSheet(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        SettingsSectionTitle(title: context.t.settings.other),
        SettingsGroupCard(
          children: [
            const AppVersionTile(),
            SettingsNavTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                color: Colors.black87,
              ),
              title: context.t.settings.contacts,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsPage()),
              ),
            ),
            SettingsNavTile(
              leading: const Icon(
                Icons.local_police_outlined,
                color: Colors.black87,
              ),
              trailing: const Icon(Icons.link, color: Colors.black54),
              title: context.t.settings.privacyPolicy,
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
