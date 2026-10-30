class GroupStudentPayment {
  final bool selected;
  final double? customAmount;
  final DateTime? customPaidUntil;

  const new({this.selected = true, this.customAmount, this.customPaidUntil});

  GroupStudentPayment copyWith({
    bool? selected,
    double? customAmount,
    bool clearCustomAmount = false,
    DateTime? customPaidUntil,
    bool clearCustomPaidUntil = false,
  }) => GroupStudentPayment(
    selected: selected ?? this.selected,
    customAmount: clearCustomAmount
        ? null
        : (customAmount ?? this.customAmount),
    customPaidUntil: clearCustomPaidUntil
        ? null
        : (customPaidUntil ?? this.customPaidUntil),
  );
}

class GroupStudentPaymentItem {
  final String studentId;
  final double amount;
  final DateTime paidUntil;

  const new({
    required this.studentId,
    required this.amount,
    required this.paidUntil,
  });
}
