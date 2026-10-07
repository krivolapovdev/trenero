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
	@override String get name => 'Имя';
	@override String get note => 'Заметка';
	@override String get cancel => 'Отменить';
	@override String get repeat => 'Повторить';
	@override String get create => 'Создать';
	@override String get update => 'Обновить';
	@override String get all => 'Все';
	@override String get today => 'Сегодня';
	@override String get yesterday => 'Вчера';
	@override String get error => 'Ошибка';
	@override late final _Translations$auth$ru auth = _Translations$auth$ru._(_root);
	@override late final _Translations$home$ru home = _Translations$home$ru._(_root);
	@override late final _Translations$groups$ru groups = _Translations$groups$ru._(_root);
	@override late final _Translations$students$ru students = _Translations$students$ru._(_root);
	@override late final _Translations$settings$ru settings = _Translations$settings$ru._(_root);
	@override late final _Translations$reports$ru reports = _Translations$reports$ru._(_root);
	@override late final _Translations$transactions$ru transactions = _Translations$transactions$ru._(_root);
	@override late final _Translations$finance$ru finance = _Translations$finance$ru._(_root);
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

// Path: home
class _Translations$home$ru implements Translations$home$en {
	_Translations$home$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Главная';
}

// Path: groups
class _Translations$groups$ru implements Translations$groups$en {
	_Translations$groups$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Группы';
	@override String get emptySubtitle => 'Групп пока нет';
	@override String get createFirstGroup => 'Создать первую группу';
	@override String get createGroup => 'Добавить группу';
	@override String get editGroup => 'Редактировать группу';
	@override String get defaultPrice => 'Стандартная цена';
}

// Path: students
class _Translations$students$ru implements Translations$students$en {
	_Translations$students$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ученики';
	@override String get emptySubtitle => 'Учеников пока нет';
	@override String get createFirstStudent => 'Создать первого ученика';
	@override String get createStudent => 'Добавить ученика';
	@override late final _Translations$students$status$ru status = _Translations$students$status$ru._(_root);
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

// Path: reports
class _Translations$reports$ru implements Translations$reports$en {
	_Translations$reports$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Отчеты';
	@override String get subtitle => 'Учет и аналитика';
}

// Path: transactions
class _Translations$transactions$ru implements Translations$transactions$en {
	_Translations$transactions$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Транзакции';
	@override String get subtitle => 'Доходы и расходы';
}

// Path: finance
class _Translations$finance$ru implements Translations$finance$en {
	_Translations$finance$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Финансы';
	@override String get income => 'Доходы';
	@override String get expenses => 'Расходы';
	@override String get lastTransactions => 'Последние операции';
}

// Path: students.status
class _Translations$students$status$ru implements Translations$students$status$en {
	_Translations$students$status$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get inactive => 'Неактивен';
	@override String get present => 'Присутствовал';
	@override String get missing => 'Отсутствовал';
	@override String get paid => 'Оплачено';
	@override String get unpaid => 'Не оплачено';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'name' => 'Имя',
			'note' => 'Заметка',
			'cancel' => 'Отменить',
			'repeat' => 'Повторить',
			'create' => 'Создать',
			'update' => 'Обновить',
			'all' => 'Все',
			'today' => 'Сегодня',
			'yesterday' => 'Вчера',
			'error' => 'Ошибка',
			'auth.signInWithApple' => 'Войти через Apple',
			'auth.signInWithGoogle' => 'Войти через Google',
			'auth.agreePrivacyPolicy' => 'Продолжая, вы соглашаетесь с нашей Политикой конфиденциальности',
			'home.title' => 'Главная',
			'groups.title' => 'Группы',
			'groups.emptySubtitle' => 'Групп пока нет',
			'groups.createFirstGroup' => 'Создать первую группу',
			'groups.createGroup' => 'Добавить группу',
			'groups.editGroup' => 'Редактировать группу',
			'groups.defaultPrice' => 'Стандартная цена',
			'students.title' => 'Ученики',
			'students.emptySubtitle' => 'Учеников пока нет',
			'students.createFirstStudent' => 'Создать первого ученика',
			'students.createStudent' => 'Добавить ученика',
			'students.status.inactive' => 'Неактивен',
			'students.status.present' => 'Присутствовал',
			'students.status.missing' => 'Отсутствовал',
			'students.status.paid' => 'Оплачено',
			'students.status.unpaid' => 'Не оплачено',
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
			'reports.title' => 'Отчеты',
			'reports.subtitle' => 'Учет и аналитика',
			'transactions.title' => 'Транзакции',
			'transactions.subtitle' => 'Доходы и расходы',
			'finance.title' => 'Финансы',
			'finance.income' => 'Доходы',
			'finance.expenses' => 'Расходы',
			'finance.lastTransactions' => 'Последние операции',
			_ => null,
		};
	}
}
