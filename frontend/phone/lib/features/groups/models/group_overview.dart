class GroupOverview {
  final String id;
  final String name;
  final num? defaultPrice;
  final String? note;
  final List<dynamic> groupStudents;

  const new({
    required this.id,
    required this.name,
    this.defaultPrice,
    this.note,
    this.groupStudents = const [],
  });
}
