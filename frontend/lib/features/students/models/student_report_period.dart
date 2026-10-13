class StudentReportPeriod {
  final String studentId;
  final int year;
  final int month;

  const new({required this.studentId, required this.year, required this.month});

  @override
  bool operator ==(Object other) =>
      other is StudentReportPeriod &&
      other.studentId == studentId &&
      other.year == year &&
      other.month == month;

  @override
  int get hashCode => Object.hash(studentId, year, month);

  @override
  String toString() => 'StudentReportPeriod($studentId, $year-$month)';
}
