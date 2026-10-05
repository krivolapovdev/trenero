import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/features/settings/widgets/settings_group_card.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SettingsGroupCard(
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Colors.black87),
              title: const Text(
                'Email',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Text(
                AppConstants.emailContact,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              onTap: () => launchUrl(
                Uri.parse('mailto:${AppConstants.emailContact}'),
                mode: LaunchMode.externalApplication,
              ),
            ),

            const Divider(height: 1, indent: 10, endIndent: 10),

            ListTile(
              leading: const Icon(Icons.telegram, color: Colors.black87),
              title: const Text(
                'Telegram',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              trailing: const Text(
                '@${AppConstants.telegramContact}',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              onTap: () => launchUrl(
                Uri.parse('https://t.me/${AppConstants.telegramContact}'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
