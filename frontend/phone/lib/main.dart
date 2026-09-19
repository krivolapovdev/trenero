import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/features/auth/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeLocale();

  runApp(TranslationProvider(child: const Application()));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trenero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const AuthPage(),
    );
  }
}

Future<void> initializeLocale() async {
  final preferences = await SharedPreferences.getInstance();
  final String? storedLang = preferences.getString('language');

  if (storedLang != null) {
    LocaleSettings.setLocaleRaw(storedLang);
  } else {
    LocaleSettings.useDeviceLocale();
  }
}
