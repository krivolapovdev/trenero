import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/features/settings/widgets/settings_group_card.dart';
import 'package:phone/features/settings/widgets/settings_tile.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(
        context.t.settings.contacts,
        style: const TextStyle(color: Colors.black87),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SettingsGroupCard(
          children: [
            SettingsTile(
              icon: Icons.email,
              title: 'Email',
              trailing: const Text(
                AppConstants.emailContact,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              onTap: () => launchUrl(
                Uri.parse('mailto:${AppConstants.emailContact}'),
                mode: LaunchMode.externalApplication,
              ),
            ),

            const Divider(height: 1, indent: 10, endIndent: 10),

            SettingsTile(
              icon: Icons.telegram,
              title: 'Telegram',
              trailing: const Text(
                '@${AppConstants.telegramContact}',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              onTap: () => launchUrl(
                Uri.parse('https://t.me/$AppConstants.emailContact'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
