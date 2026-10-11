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

    const SizedBox(width: 8),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      close(context, null);
    },
  );

  @override
  Widget buildResults(BuildContext context) =>
      _GroupSearchResults(groups: groups, query: query);

  @override
  Widget buildSuggestions(BuildContext context) =>
      _GroupSearchResults(groups: groups, query: query);
}

class _GroupSearchResults extends StatelessWidget {
  final List<GroupSummaryResponse> groups;
  final String query;

  const new({required this.groups, required this.query});

  @override
  Widget build(BuildContext context) {
    final searchLower = query.toLowerCase();
    final filteredGroups = groups
        .where((group) => group.name.toLowerCase().contains(searchLower))
        .toList();

    if (filteredGroups.isEmpty) {
      return Center(child: Text(context.t.groups.notFound));
    }

    return GroupListView(groups: filteredGroups);
  }
}
