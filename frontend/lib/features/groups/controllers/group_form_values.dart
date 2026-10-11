/// The validated fields of the group form.
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

/// Validates the fields the create and the edit group sheets submit.
///
/// Throws an [ArgumentError] when a field cannot be stored, so the controller
/// guard reports it to the user the way it reports a failed request.
GroupFormValues validateGroupForm({
  required String name,
  required String? priceText,
  required String? note,
}) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) {
    throw ArgumentError('Group name is required.');
  }

  double? parsedPrice;
  if (priceText != null && priceText.trim().isNotEmpty) {
    parsedPrice = double.tryParse(priceText.trim());
    if (parsedPrice == null || parsedPrice < 0) {
      throw ArgumentError('Price must be a valid positive number.');
    }
  }

  final trimmedNote = note?.trim();

  return GroupFormValues(
    name: trimmedName,
    defaultPrice: parsedPrice,
    note: (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
  );
}
