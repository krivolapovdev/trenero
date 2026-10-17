import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone/i18n/strings.g.dart';

final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

class AppVersionTile extends StatelessWidget {
  const new({super.key});

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
