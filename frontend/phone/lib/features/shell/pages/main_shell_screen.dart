import 'package:flutter/material.dart';
import 'package:phone/core/widgets/titled_page.dart';
import 'package:phone/features/groups/pages/groups_page.dart';
import 'package:phone/features/settings/pages/settings_page.dart';
import 'package:phone/features/statistics/pages/statistics_page.dart';
import 'package:phone/features/students/pages/students_page.dart';
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
    final List<TitledPage> pages = [
      StatisticsPage(title: context.t.statistics.title),
      GroupsPage(title: context.t.groups.title),
      StudentsPage(title: context.t.students.title),
      SettingsPage(title: context.t.settings.title),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(pages[_currentIndex].title)),

      body: IndexedStack(index: _currentIndex, children: pages),

      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: pages.map((page) {
          return NavigationDestination(
            icon: Icon(page.icon),
            selectedIcon: Icon(page.selectedIcon),
            label: page.title,
          );
        }).toList(),
      ),
    );
  }
}
