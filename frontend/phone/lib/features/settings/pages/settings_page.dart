import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone/core/widgets/titled_page.dart';
import 'package:phone/features/settings/widgets/settings_group_card.dart';
import 'package:phone/features/settings/widgets/settings_section_title.dart';
import 'package:phone/features/settings/widgets/settings_tile.dart';
import 'package:phone/i18n/strings.g.dart';

class SettingsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.settings_outlined,
    super.selectedIcon = Icons.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SettingsSectionTitle(title: context.t.settings.appearance),
          SettingsGroupCard(
            children: [
              SettingsTile(
                icon: Icons.outlined_flag,
                title: context.t.settings.language,
                trailing: Icon(Icons.chevron_right, color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 24),

          SettingsSectionTitle(title: context.t.settings.account),
          SettingsGroupCard(
            children: [
              SettingsTile(
                icon: Icons.logout,
                title: context.t.settings.logout,
                trailing: Icon(Icons.chevron_right, color: Colors.black54),
              ),
              SettingsTile(
                icon: Icons.delete_outline,
                title: context.t.settings.deleteAccount,
                trailing: Icon(Icons.chevron_right, color: Colors.black54),
              ),
            ],
          ),
          SizedBox(height: 24),

          SettingsSectionTitle(title: context.t.settings.other),
          SettingsGroupCard(
            children: [
              SettingsTile(
                icon: Icons.code,
                title: context.t.settings.version,
                trailing: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final versionText = snapshot.hasData
                        ? snapshot.data!.version
                        : '...';

                    return Text(
                      versionText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    );
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.account_circle_outlined,
                title: context.t.settings.contacts,
                trailing: Icon(Icons.chevron_right, color: Colors.black54),
              ),
              SettingsTile(
                icon: Icons.local_police_outlined,
                title: context.t.settings.privacyPolicy,
                trailing: Icon(Icons.link, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
