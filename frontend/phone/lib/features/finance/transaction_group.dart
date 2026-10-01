import 'package:phone/generated/models/transaction_response.dart';

class TransactionGroup {
  final String dateTitle;
  final List<TransactionResponse> items;

  const new({required this.dateTitle, required this.items});
}
