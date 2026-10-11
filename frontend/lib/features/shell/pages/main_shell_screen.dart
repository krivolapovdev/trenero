import 'package:flutter/material.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/finance/pages/finance_page.dart';
import 'package:phone/features/groups/pages/group_list_page.dart';
import 'package:phone/features/settings/pages/settings_page.dart';
import 'package:phone/features/students/pages/student_list_page.dart';
import 'package:phone/i18n/strings.g.dart';

class MainShellScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<ShellPage> pages = [
      FinancePage(title: context.t.finance.title),
      GroupListPage(title: context.t.groups.title),
      StudentListPage(title: context.t.students.title),
      SettingsPage(title: context.t.settings.title),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pages[_currentIndex].title),
        elevation: 0,
        actions: pages[_currentIndex].actions(context),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),

      body: IndexedStack(index: _currentIndex, children: pages),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: pages
              .map(
                (page) => NavigationDestination(
                  icon: Icon(page.icon),
                  selectedIcon: Icon(page.selectedIcon),
                  label: page.title,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
