import 'package:flutter/material.dart';

extension StringExtension on String {
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

  Color toColor({double saturation = 0.45, double value = 0.85}) {
    final hash = hashCode.abs();
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
  }
}
