///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsRu with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override String get ok => 'OK';
	@override String get cancel => 'Отменить';
	@override late final _Translations$auth$ru auth = _Translations$auth$ru._(_root);
	@override late final _Translations$statistics$ru statistics = _Translations$statistics$ru._(_root);
	@override late final _Translations$groups$ru groups = _Translations$groups$ru._(_root);
	@override late final _Translations$students$ru students = _Translations$students$ru._(_root);
	@override late final _Translations$settings$ru settings = _Translations$settings$ru._(_root);
}

// Path: auth
class _Translations$auth$ru implements Translations$auth$en {
	_Translations$auth$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get signInWithApple => 'Войти через Apple';
	@override String get signInWithGoogle => 'Войти через Google';
	@override String get agreePrivacyPolicy => 'Продолжая, вы соглашаетесь с нашей Политикой конфиденциальности';
}

// Path: statistics
class _Translations$statistics$ru implements Translations$statistics$en {
	_Translations$statistics$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Статистика';
}

// Path: groups
class _Translations$groups$ru implements Translations$groups$en {
	_Translations$groups$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Группы';
}

// Path: students
class _Translations$students$ru implements Translations$students$en {
	_Translations$students$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ученики';
}

// Path: settings
class _Translations$settings$ru implements Translations$settings$en {
	_Translations$settings$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки';
	@override String get appearance => 'Внешний вид';
	@override String get language => 'Язык';
	@override String get selectLanguage => 'Выберите язык приложения';
	@override String get account => 'Аккаунт';
	@override String get logout => 'Выйти';
	@override String get logoutMessage => 'Вы уверены, что хотите выйти?';
	@override String get deleteAccount => 'Удалить аккаунт';
	@override String get other => 'Другое';
	@override String get version => 'Версия';
	@override String get contacts => 'Контакты';
	@override String get privacyPolicy => 'Политика конфиденциальности';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'ok' => 'OK',
			'cancel' => 'Отменить',
			'auth.signInWithApple' => 'Войти через Apple',
			'auth.signInWithGoogle' => 'Войти через Google',
			'auth.agreePrivacyPolicy' => 'Продолжая, вы соглашаетесь с нашей Политикой конфиденциальности',
			'statistics.title' => 'Статистика',
			'groups.title' => 'Группы',
			'students.title' => 'Ученики',
			'settings.title' => 'Настройки',
			'settings.appearance' => 'Внешний вид',
			'settings.language' => 'Язык',
			'settings.selectLanguage' => 'Выберите язык приложения',
			'settings.account' => 'Аккаунт',
			'settings.logout' => 'Выйти',
			'settings.logoutMessage' => 'Вы уверены, что хотите выйти?',
			'settings.deleteAccount' => 'Удалить аккаунт',
			'settings.other' => 'Другое',
			'settings.version' => 'Версия',
			'settings.contacts' => 'Контакты',
			'settings.privacyPolicy' => 'Политика конфиденциальности',
			_ => null,
		};
	}
}
