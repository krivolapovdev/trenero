import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/titled_page.dart';
import 'package:phone/features/groups/models/group_overview.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/i18n/strings.g.dart';

final groups = const [
  GroupOverview(
    id: '1',
    name: 'OTG-24',
    defaultPrice: 5000,
    groupStudents: [1, 2],
  ),
  GroupOverview(
    id: '2',
    name: 'GNP-17',
    defaultPrice: 6000,
    groupStudents: [1],
  ),
  GroupOverview(
    id: '3',
    name: 'MTH-101',
    // defaultPrice: 4500,
    // note: 'Monday & Wednesday 18:00',
    groupStudents: [1, 2, 3, 4, 5],
  ),
  GroupOverview(
    id: '4',
    name: 'ENG-A2',
    defaultPrice: 5500,
    note: 'Evening speaking club',
    groupStudents: [1, 2, 3],
  ),
  GroupOverview(
    id: '5',
    name: 'PHY-08',
    defaultPrice: 7000,
    groupStudents: [1, 2, 3, 4],
  ),
  GroupOverview(
    id: '6',
    name: 'CS-202',
    defaultPrice: 8000,
    note: 'Advanced Algorithms Intensive',
    groupStudents: [1, 2, 3, 4, 5, 6, 7, 8],
  ),
  GroupOverview(id: '7', name: 'DES-10', defaultPrice: 5000, groupStudents: []),
  GroupOverview(
    id: '8',
    name: 'BIO-03',
    defaultPrice: 4000,
    note: 'Lab sessions on Fridays',
    groupStudents: [1, 2],
  ),
  GroupOverview(
    id: '9',
    name: 'HIS-15',
    defaultPrice: 3500,
    groupStudents: [1, 2, 3],
  ),
  GroupOverview(
    id: '10',
    name: 'CHEM-22',
    defaultPrice: 6500,
    note: 'Requires protective lab gear',
    groupStudents: [1, 2, 3, 4, 5, 6],
  ),
];

class GroupsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  @override
  Widget build(BuildContext context) => groups.isEmpty
      ? EmptyState(
          buttonText: context.t.groups.createFirstGroup,
          subtitle: context.t.groups.emptySubtitle,
          onButtonPressed: () {},
        )
      : CustomMaterialIndicator(
          color: Colors.black,
          clipBehavior: Clip.antiAlias,
          onRefresh: () => Future.delayed(const Duration(seconds: 2)),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ...groups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Hero(
                    tag: 'group-card-${group.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: GroupCard(
                        group: group,
                        onTap: () {
                          pushWithoutNavBar(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupPage(group: group),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
}
