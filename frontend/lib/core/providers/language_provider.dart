import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/shared_preferences_provider.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

const String _languageKey = 'language';

class LanguageNotifier extends AsyncNotifier<AppLocale> {
  @override
  Future<AppLocale> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return _getSavedLocale(prefs);
  }

  AppLocale _getSavedLocale(SharedPreferences prefs) {
    final String? storedLang = prefs.getString(_languageKey);

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
    final prefs = await ref.read(sharedPreferencesProvider.future);

    LocaleSettings.setLocale(newLocale);
    timeago.setDefaultLocale(newLocale.languageCode);
    await prefs.setString(_languageKey, newLocale.languageTag);

    // Update notifier state
    state = AsyncData(newLocale);
  }
}

final languageProvider = AsyncNotifierProvider<LanguageNotifier, AppLocale>(
  LanguageNotifier.new,
);
