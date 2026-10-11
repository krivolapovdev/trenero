import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_list_view.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupSearchDelegate extends SearchDelegate {
  final List<GroupSummaryResponse> groups;

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
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final filteredGroups = groups.where((group) {
      final groupName = group.name.toLowerCase();
      final searchLower = query.toLowerCase();

      return groupName.contains(searchLower);
    }).toList();

    if (filteredGroups.isEmpty) {
      return Center(child: Text(context.t.groups.notFound));
    }

    return GroupListView(groups: filteredGroups);
  }
}
