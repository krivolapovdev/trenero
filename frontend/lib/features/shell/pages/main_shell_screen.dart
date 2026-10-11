import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/finance/pages/finance_page.dart';
import 'package:phone/features/groups/pages/group_list_page.dart';
import 'package:phone/features/settings/pages/settings_page.dart';
import 'package:phone/features/shell/widgets/shell_navigation_bar.dart';
import 'package:phone/features/students/pages/student_list_page.dart';
import 'package:phone/i18n/strings.g.dart';

class MainShellScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onDestinationSelected(int index) =>
      setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = <ShellPage>[
      FinancePage(title: context.t.finance.title),
      GroupListPage(title: context.t.groups.title),
      StudentListPage(title: context.t.students.title),
      SettingsPage(title: context.t.settings.title),
    ];

    final currentPage = pages[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.title),
        elevation: 0,
        actions: currentPage.actions(context),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
      ),

      body: IndexedStack(index: _currentIndex, children: pages),

      bottomNavigationBar: ShellNavigationBar(
        pages: pages,
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
