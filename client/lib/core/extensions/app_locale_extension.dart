import 'package:phone/i18n/strings.g.dart';

extension AppLocaleExtension on AppLocale {
  String get flag => switch (this) {
    AppLocale.ru => '🇷🇺',
    AppLocale.en => '🇬🇧',
  };

  String get label => switch (this) {
    AppLocale.ru => 'Русский',
    AppLocale.en => 'English',
  };
}
