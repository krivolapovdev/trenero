import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/auth_provider.dart';
import 'package:phone/features/auth/pages/auth_page.dart';
import 'package:phone/i18n/strings.g.dart';

class LogoutConfirmationSheet extends ConsumerWidget {
  const new({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const LogoutConfirmationSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.t.settings.logoutMessage,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).clear();

                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                  (route) => false,
                );
              },
              child: Text(
                context.t.settings.logout,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.t.cancel,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
