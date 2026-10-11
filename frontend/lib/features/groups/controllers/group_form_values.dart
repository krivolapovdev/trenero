import 'package:phone/core/errors/app_exception.dart';

class GroupFormValues {
  final String name;
  final double? defaultPrice;
  final String? note;

  const new({
    required this.name,
    required this.defaultPrice,
    required this.note,
  });
}

GroupFormValues validateGroupForm({
  required String name,
  required String? priceText,
  required String? note,
}) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    throw const ValidationException('Group name is required.');
  }

  double? parsedPrice;
  if (priceText != null && priceText.trim().isNotEmpty) {
    parsedPrice = double.tryParse(priceText.trim());
    if (parsedPrice == null || parsedPrice < 0) {
      throw const ValidationException('Price must be a valid positive number.');
    }
  }

  final trimmedNote = note?.trim();

  return GroupFormValues(
    name: trimmedName,
    defaultPrice: parsedPrice,
    note: (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
  );
}
