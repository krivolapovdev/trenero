import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/status_badges.dart';

class EntityCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final List<StatusBadgeData>? badges;

  const new({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.badges,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
    clipBehavior: Clip.antiAlias,
    color: Colors.white,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: const TextStyle(fontSize: 14)),
            ],

            if (badges != null && badges!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              StatusBadges(badges: badges!),
            ],
          ],
        ),
      ),
    ),
  );
}
