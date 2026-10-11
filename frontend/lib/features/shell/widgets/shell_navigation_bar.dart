import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/shell_page.dart';

class ShellNavigationBar extends StatelessWidget {
  final List<ShellPage> pages;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const new({
    super.key,
    required this.pages,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: AppRadius.lgRad),
    child: NavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final page in pages)
          NavigationDestination(
            icon: Icon(page.icon),
            selectedIcon: Icon(page.selectedIcon),
            label: page.title,
          ),
      ],
    ),
  );
}
