import 'package:flutter/material.dart';

extension StringExtension on String {
  static const double _defaultSaturation = 0.45;
  static const double _defaultValue = 0.85;
  static const int _hueRange = 360;

  String get initials {
    final trimmed = trim();
    if (trimmed.isEmpty) return '';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  Color toColor({
    double saturation = _defaultSaturation,
    double value = _defaultValue,
  }) {
    final hue = (hashCode.abs() % _hueRange).toDouble();
    return HSVColor.fromAHSV(1, hue, saturation, value).toColor();
  }
}

extension NullableStringExtension on String? {
  /// Returns the trimmed value, or `null` when it is blank.
  String? get trimmedOrNull {
    final trimmed = this?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
