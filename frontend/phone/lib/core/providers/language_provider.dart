import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/shared_preferences_provider.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _languageKey = 'language';

class LanguageNotifier extends Notifier<AppLocale> {
  late final SharedPreferences _prefs;

  @override
  AppLocale build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _getSavedLocale();
  }

  AppLocale _getSavedLocale() {
    final String? storedLang = _prefs.getString(_languageKey);

    if (storedLang != null) {
      final AppLocale locale = AppLocaleUtils.parse(storedLang);
      LocaleSettings.setLocale(locale);
      return locale;
    }

    final deviceLocale = AppLocaleUtils.findDeviceLocale();
    LocaleSettings.setLocale(deviceLocale);
    return deviceLocale;
  }

  Future<void> setLanguage(AppLocale newLocale) async {
    state = newLocale;
    LocaleSettings.setLocale(newLocale);
    await _prefs.setString(_languageKey, newLocale.languageTag);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLocale>(
  LanguageNotifier.new,
);
