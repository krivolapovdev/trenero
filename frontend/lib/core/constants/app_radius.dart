import 'package:flutter/widgets.dart';

/// Corner radii shared across the application.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  static const Radius smRad = Radius.circular(sm);
  static const Radius mdRad = Radius.circular(md);
  static const Radius lgRad = Radius.circular(lg);
  static const Radius xlRad = Radius.circular(xl);
  static const Radius xxlRad = Radius.circular(xxl);

  static const BorderRadius smAll = BorderRadius.all(smRad);
  static const BorderRadius mdAll = BorderRadius.all(mdRad);
  static const BorderRadius lgAll = BorderRadius.all(lgRad);
  static const BorderRadius xlAll = BorderRadius.all(xlRad);
  static const BorderRadius xxlAll = BorderRadius.all(xxlRad);

  /// Rounded top corners, used by modal bottom sheets.
  static const BorderRadius topRounded = BorderRadius.vertical(top: xlRad);

  /// Rounded bottom corners, used by the app bars.
  static const BorderRadius bottomRounded = BorderRadius.vertical(
    bottom: lgRad,
  );
}
