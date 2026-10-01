import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_list_view.dart';
import 'package:phone/generated/models/group_summary.dart';

class GroupSearchDelegate extends SearchDelegate {
  final List<GroupSummary> groups;

  new(this.groups, String searchLabel)
    : super(searchFieldLabel: searchLabel, keyboardType: TextInputType.text);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),

    SizedBox(width: 8),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      close(context, null);
    },
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final filteredGroups = groups.where((group) {
      final groupName = group.name.toLowerCase();
      final searchLower = query.toLowerCase();

      return groupName.contains(searchLower);
    }).toList();

    if (filteredGroups.isEmpty) {
      return const Center(child: Text('No groups found'));
    }

    return GroupListView(groups: filteredGroups);
  }
}
