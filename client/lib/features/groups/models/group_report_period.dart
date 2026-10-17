class GroupReportPeriod {
  final String groupId;
  final int year;
  final int month;

  const new({required this.groupId, required this.year, required this.month});

  @override
  bool operator ==(Object other) =>
      other is GroupReportPeriod &&
      other.groupId == groupId &&
      other.year == year &&
      other.month == month;

  @override
  int get hashCode => Object.hash(groupId, year, month);

  @override
  String toString() => 'GroupReportPeriod($groupId, $year-$month)';
}

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
