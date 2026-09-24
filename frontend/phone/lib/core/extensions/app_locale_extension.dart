import 'package:phone/i18n/strings.g.dart';

extension AppLocaleExt on AppLocale {
  String get flag {
    switch (this) {
      case AppLocale.ru:
        return '🇷🇺';
      case AppLocale.en:
        return '🇬🇧';
    }
  }

  String get label {
    switch (this) {
      case AppLocale.ru:
        return 'Русский';
      case AppLocale.en:
        return 'English';
    }
  }
}
