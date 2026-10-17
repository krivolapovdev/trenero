import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/generated/models/group_summary_response.dart';

final _group = GroupSummaryResponse(
  id: 'group-a',
  name: 'Group A',
  createdAt: DateTime(2025, 8, 22),
  note: 'Bring the notebook',
);

Widget _wrap({bool noteVisible = true}) => MaterialApp(
  home: Scaffold(
    body: GroupCard(group: _group, onTap: () {}, noteVisible: noteVisible),
  ),
);

void main() {
  testWidgets('the card draws the note of the group', (tester) async {
    await tester.pumpWidget(_wrap());

    expect(find.text('Group A'), findsOneWidget);
    expect(find.text('Bring the notebook'), findsOneWidget);
  });

  testWidgets('the note of the group can be dropped', (tester) async {
    await tester.pumpWidget(_wrap(noteVisible: false));

    expect(find.text('Group A'), findsOneWidget);
    expect(find.text('Bring the notebook'), findsNothing);
  });
}
