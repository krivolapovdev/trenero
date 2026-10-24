import 'package:flutter/material.dart';
import 'package:phone/features/rosters/widgets/roster_list_view.dart';
import 'package:phone/generated/models/roster_response.dart';
import 'package:phone/i18n/strings.g.dart';

class RosterSearchDelegate extends SearchDelegate {
  final List<RosterResponse> rosters;

  new(this.rosters, String searchLabel)
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
      _RosterSearchResults(rosters: rosters, query: query);

  @override
  Widget buildSuggestions(BuildContext context) =>
      _RosterSearchResults(rosters: rosters, query: query);
}

class _RosterSearchResults extends StatelessWidget {
  final List<RosterResponse> rosters;
  final String query;

  const new({required this.rosters, required this.query});

  @override
  Widget build(BuildContext context) {
    final searchLower = query.toLowerCase();
    final filteredRosters = rosters
        .where(
          (roster) =>
              roster.name.toLowerCase().contains(searchLower) ||
              (roster.note != null &&
                  roster.note!.toLowerCase().contains(searchLower)),
        )
        .toList();

    if (filteredRosters.isEmpty) {
      return Center(child: Text(context.t.rosters.notFound));
    }

    return RosterListView(rosters: filteredRosters);
  }
}
