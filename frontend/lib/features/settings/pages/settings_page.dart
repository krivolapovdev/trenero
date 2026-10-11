import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/settings/pages/contacts_page.dart';
import 'package:phone/features/settings/widgets/delete_account_bottom_sheet.dart';
import 'package:phone/features/settings/widgets/language_selection_sheet.dart';
import 'package:phone/features/settings/widgets/logout_confirmation_sheet.dart';
import 'package:phone/features/settings/widgets/settings_group_card.dart';
import 'package:phone/features/settings/widgets/settings_section_title.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

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
        const SettingsGroupCard(children: [_SettingsLanguageTile()]),
        const SizedBox(height: 24),

        SettingsSectionTitle(title: context.t.settings.account),
        SettingsGroupCard(
          children: [
            _SettingsNavTile(
              leading: Icon(Icons.logout, color: logoutColor),
              title: context.t.settings.logout,
              color: logoutColor,
              onTap: () => AppBottomSheet.show(
                context: context,
                child: const LogoutConfirmationSheet(),
              ),
            ),

            _SettingsNavTile(
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
            const _AppVersionTile(),
            _SettingsNavTile(
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
            _SettingsNavTile(
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

class _SettingsLanguageTile extends ConsumerWidget {
  const new();

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

class _AppVersionTile extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.code, color: Colors.black87),
    title: Text(
      context.t.settings.version,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    ),
    trailing: FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) => Text(
        snapshot.hasData ? snapshot.data!.version : '...',
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
    ),
  );
}

class _SettingsNavTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final Widget trailing;

  const new({
    required this.leading,
    required this.title,
    required this.onTap,
    this.color,
    this.trailing = const Icon(Icons.chevron_right, color: Colors.black54),
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: leading,
    title: Text(
      title,
      style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
    ),
    trailing: trailing,
    onTap: onTap,
  );
}
