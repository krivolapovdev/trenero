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
	@override String get edit => 'Редактировать';
	@override String get delete => 'Удалить';
	@override String get all => 'Все';
	@override String get month => 'Месяц';
	@override String get year => 'Год';
	@override String get print => 'Печать';
	@override String get error => 'Ошибка';
	@override String get noData => 'Нет данных';
	@override String get noTransactions => 'Нет операций';
	@override String get pleaseUpdateApp => 'Пожалуйста, обновите приложение';
	@override String get invalidDate => 'Некорректная дата';
	@override String titleWithCount({required Object title, required Object count}) => '${title} [${count}]';
	@override String errorLoadingData({required Object error}) => 'Ошибка загрузки данных: ${error}';
	@override late final _Translations$errors$ru errors = _Translations$errors$ru._(_root);
	@override late final _Translations$auth$ru auth = _Translations$auth$ru._(_root);
	@override late final _Translations$groups$ru groups = _Translations$groups$ru._(_root);
	@override late final _Translations$lessons$ru lessons = _Translations$lessons$ru._(_root);
	@override late final _Translations$students$ru students = _Translations$students$ru._(_root);
	@override late final _Translations$settings$ru settings = _Translations$settings$ru._(_root);
	@override late final _Translations$reports$ru reports = _Translations$reports$ru._(_root);
	@override late final _Translations$finance$ru finance = _Translations$finance$ru._(_root);
}

// Path: errors
class _Translations$errors$ru implements Translations$errors$en {
	_Translations$errors$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get network => 'Похоже, нет подключения к интернету. Проверьте соединение и попробуйте снова.';
	@override String get timeout => 'Сервер слишком долго не отвечает. Попробуйте снова.';
	@override String get cancelled => 'Запрос отменён.';
	@override String get unauthorized => 'Сессия истекла. Войдите снова.';
	@override String get forbidden => 'У вас нет прав на это действие.';
	@override String get notFound => 'Запись, которую вы искали, больше не существует.';
	@override String get conflict => 'Запрос конфликтует с уже сохранёнными данными.';
	@override String get validation => 'Запрос отклонён. Проверьте форму и попробуйте снова.';
	@override String get badRequest => 'Запрос отклонён. Попробуйте снова.';
	@override String get server => 'Сервер сейчас недоступен. Попробуйте позже.';
	@override String get unknown => 'Что-то пошло не так. Попробуйте снова.';
	@override String get signingIn => 'Не удалось войти. Попробуйте снова.';
	@override String get studentNameRequired => 'Укажите имя ученика.';
	@override String get groupNameRequired => 'Укажите название группы.';
	@override String get invalidPrice => 'Укажите корректную цену.';
	@override String get studentNameNotUnique => 'Ученик с таким именем уже существует.';
	@override String get groupNameNotUnique => 'Группа с таким названием уже существует.';
}

// Path: auth
class _Translations$auth$ru implements Translations$auth$en {
	_Translations$auth$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get signInWithGoogle => 'Войти через Google';
	@override String get agreePrivacyPolicy => 'Продолжая, вы соглашаетесь с нашей Политикой конфиденциальности';
	@override String get login => 'Войти';
	@override String get reviewerKey => 'Ключ ревьюера';
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
	@override String get noGroup => 'Без группы';
	@override String get defaultPrice => 'Стандартная цена';
	@override String get report => 'Отчет';
	@override String get notFound => 'Группы не найдены';
	@override String get deleteGroup => 'Удалить группу?';
	@override String get deleteGroupMessage => 'Группа будет удалена безвозвратно. Действие нельзя отменить.';
}

// Path: lessons
class _Translations$lessons$ru implements Translations$lessons$en {
	_Translations$lessons$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Урок';
	@override String get individualLesson => 'Индивидуальный урок';
	@override String get individualLessons => 'Индивидуальные уроки';
	@override String get groupLesson => 'Групповой урок';
	@override String get groupLessons => 'Групповые уроки';
	@override String get date => 'Дата';
	@override String get selectAll => 'Выбрать всех';
	@override String get deselectAll => 'Снять выбор';
	@override String get noStudents => 'В группе пока нет учеников';
	@override String get present => 'Присутствовал';
	@override String get missed => 'Пропустил';
	@override String get absent => 'Отсутствовал';
	@override String get excused => 'Уважительная причина';
	@override String get unmarked => 'Без отметки';
	@override String get notMarked => 'Не отмечены';
	@override String get status => 'Статус';
	@override String get type => 'Тип';
	@override String get regular => 'Обычный';
	@override String get free => 'Бесплатный';
	@override String get freeLesson => 'Урок бесплатный';
	@override String get deleteLesson => 'Удалить урок?';
	@override String get deleteLessonMessage => 'Урок и отметки посещаемости будут удалены безвозвратно. Действие нельзя отменить.';
	@override String errorLoading({required Object error}) => 'Ошибка загрузки уроков: ${error}';
	@override String get emptyDay => 'В этот день уроков нет.';
	@override String forDate({required Object date}) => 'Уроки на ${date}';
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
	@override String get editStudent => 'Редактировать ученика';
	@override String get fullName => 'ФИО';
	@override String get birthdate => 'Дата рождения';
	@override String get phone => 'Телефон';
	@override String get group => 'Группа';
	@override String get noStudent => 'Без ученика';
	@override String get free => 'Учится бесплатно';
	@override String get payment => 'Платёж';
	@override String paymentTitle({required Object name}) => 'Платежи: ${name}';
	@override String get noPayments => 'У студента нет платежей';
	@override String errorLoading({required Object error}) => 'Ошибка загрузки учеников: ${error}';
	@override String get deleteStudent => 'Удалить ученика?';
	@override String get deleteStudentMessage => 'Ученик и его уроки будут удалены безвозвратно. Действие нельзя отменить.';
	@override late final _Translations$students$filter$ru filter = _Translations$students$filter$ru._(_root);
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
	@override String get deleteAccountMessage => 'Аккаунт и все связанные данные будут удалены безвозвратно. Действие нельзя отменить.';
	@override String deleteAccountCountdown({required Object seconds}) => 'Удалить аккаунт можно будет через ${seconds} с';
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
	@override String get number => '№';
	@override String get fullName => 'ФИО';
	@override String get paid => 'Оплачено';
	@override String get result => 'Итог';
	@override String get total => 'Всего';
}

// Path: finance
class _Translations$finance$ru implements Translations$finance$en {
	_Translations$finance$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Финансы';
	@override String get createTransaction => 'Новая транзакция';
	@override String get income => 'Доходы';
	@override String get expenses => 'Расходы';
	@override String get lastTransactions => 'Последние операции';
	@override String get transactionTitle => 'Транзакция';
	@override String get transactionId => 'ID операции';
	@override String get date => 'Дата';
	@override String get amount => 'Сумма';
	@override String get type => 'Тип';
	@override String get typeIncome => 'Доход';
	@override String get typeExpense => 'Расход';
	@override String get student => 'Ученик';
	@override String get paidUntil => 'Оплачено до';
	@override String get createdAt => 'Создано';
	@override String get deposit => 'Пополнение';
	@override String get withdrawal => 'Списание';
	@override String get editTransaction => 'Редактировать транзакцию';
	@override String get deleteTransaction => 'Удалить транзакцию?';
	@override String get deleteTransactionMessage => 'Транзакция будет удалена безвозвратно. Действие нельзя отменить.';
	@override late final _Translations$finance$filter$ru filter = _Translations$finance$filter$ru._(_root);
}

// Path: students.filter
class _Translations$students$filter$ru implements Translations$students$filter$en {
	_Translations$students$filter$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Фильтры';
	@override String get group => 'Группа';
	@override String get status => 'Статус';
	@override String get apply => 'Применить';
	@override String get reset => 'Сбросить фильтры';
	@override String get empty => 'Ученики не найдены';
}

// Path: students.status
class _Translations$students$status$ru implements Translations$students$status$en {
	_Translations$students$status$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get inactive => 'Неактивен';
	@override String get present => 'Посетил';
	@override String get missing => 'Пропустил';
	@override String get paid => 'Оплачено';
	@override String get unpaid => 'Не оплачено';
	@override String get free => 'Бесплатно';
}

// Path: finance.filter
class _Translations$finance$filter$ru implements Translations$finance$filter$en {
	_Translations$finance$filter$ru._(this._root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Период';
	@override String get start => 'Начало';
	@override String get end => 'Конец';
	@override String get apply => 'Продолжить';
	@override String get reset => 'Сбросить фильтры';
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
			'edit' => 'Редактировать',
			'delete' => 'Удалить',
			'all' => 'Все',
			'month' => 'Месяц',
			'year' => 'Год',
			'print' => 'Печать',
			'error' => 'Ошибка',
			'noData' => 'Нет данных',
			'noTransactions' => 'Нет операций',
			'pleaseUpdateApp' => 'Пожалуйста, обновите приложение',
			'invalidDate' => 'Некорректная дата',
			'titleWithCount' => ({required Object title, required Object count}) => '${title} [${count}]',
			'errorLoadingData' => ({required Object error}) => 'Ошибка загрузки данных: ${error}',
			'errors.network' => 'Похоже, нет подключения к интернету. Проверьте соединение и попробуйте снова.',
			'errors.timeout' => 'Сервер слишком долго не отвечает. Попробуйте снова.',
			'errors.cancelled' => 'Запрос отменён.',
			'errors.unauthorized' => 'Сессия истекла. Войдите снова.',
			'errors.forbidden' => 'У вас нет прав на это действие.',
			'errors.notFound' => 'Запись, которую вы искали, больше не существует.',
			'errors.conflict' => 'Запрос конфликтует с уже сохранёнными данными.',
			'errors.validation' => 'Запрос отклонён. Проверьте форму и попробуйте снова.',
			'errors.badRequest' => 'Запрос отклонён. Попробуйте снова.',
			'errors.server' => 'Сервер сейчас недоступен. Попробуйте позже.',
			'errors.unknown' => 'Что-то пошло не так. Попробуйте снова.',
			'errors.signingIn' => 'Не удалось войти. Попробуйте снова.',
			'errors.studentNameRequired' => 'Укажите имя ученика.',
			'errors.groupNameRequired' => 'Укажите название группы.',
			'errors.invalidPrice' => 'Укажите корректную цену.',
			'errors.studentNameNotUnique' => 'Ученик с таким именем уже существует.',
			'errors.groupNameNotUnique' => 'Группа с таким названием уже существует.',
			'auth.signInWithGoogle' => 'Войти через Google',
			'auth.agreePrivacyPolicy' => 'Продолжая, вы соглашаетесь с нашей Политикой конфиденциальности',
			'auth.login' => 'Войти',
			'auth.reviewerKey' => 'Ключ ревьюера',
			'groups.title' => 'Группы',
			'groups.emptySubtitle' => 'Групп пока нет',
			'groups.createFirstGroup' => 'Создать первую группу',
			'groups.createGroup' => 'Добавить группу',
			'groups.editGroup' => 'Редактировать группу',
			'groups.noGroup' => 'Без группы',
			'groups.defaultPrice' => 'Стандартная цена',
			'groups.report' => 'Отчет',
			'groups.notFound' => 'Группы не найдены',
			'groups.deleteGroup' => 'Удалить группу?',
			'groups.deleteGroupMessage' => 'Группа будет удалена безвозвратно. Действие нельзя отменить.',
			'lessons.title' => 'Урок',
			'lessons.individualLesson' => 'Индивидуальный урок',
			'lessons.individualLessons' => 'Индивидуальные уроки',
			'lessons.groupLesson' => 'Групповой урок',
			'lessons.groupLessons' => 'Групповые уроки',
			'lessons.date' => 'Дата',
			'lessons.selectAll' => 'Выбрать всех',
			'lessons.deselectAll' => 'Снять выбор',
			'lessons.noStudents' => 'В группе пока нет учеников',
			'lessons.present' => 'Присутствовал',
			'lessons.missed' => 'Пропустил',
			'lessons.absent' => 'Отсутствовал',
			'lessons.excused' => 'Уважительная причина',
			'lessons.unmarked' => 'Без отметки',
			'lessons.notMarked' => 'Не отмечены',
			'lessons.status' => 'Статус',
			'lessons.type' => 'Тип',
			'lessons.regular' => 'Обычный',
			'lessons.free' => 'Бесплатный',
			'lessons.freeLesson' => 'Урок бесплатный',
			'lessons.deleteLesson' => 'Удалить урок?',
			'lessons.deleteLessonMessage' => 'Урок и отметки посещаемости будут удалены безвозвратно. Действие нельзя отменить.',
			'lessons.errorLoading' => ({required Object error}) => 'Ошибка загрузки уроков: ${error}',
			'lessons.emptyDay' => 'В этот день уроков нет.',
			'lessons.forDate' => ({required Object date}) => 'Уроки на ${date}',
			'students.title' => 'Ученики',
			'students.emptySubtitle' => 'Учеников пока нет',
			'students.createFirstStudent' => 'Создать первого ученика',
			'students.createStudent' => 'Добавить ученика',
			'students.editStudent' => 'Редактировать ученика',
			'students.fullName' => 'ФИО',
			'students.birthdate' => 'Дата рождения',
			'students.phone' => 'Телефон',
			'students.group' => 'Группа',
			'students.noStudent' => 'Без ученика',
			'students.free' => 'Учится бесплатно',
			'students.payment' => 'Платёж',
			'students.paymentTitle' => ({required Object name}) => 'Платежи: ${name}',
			'students.noPayments' => 'У студента нет платежей',
			'students.errorLoading' => ({required Object error}) => 'Ошибка загрузки учеников: ${error}',
			'students.deleteStudent' => 'Удалить ученика?',
			'students.deleteStudentMessage' => 'Ученик и его уроки будут удалены безвозвратно. Действие нельзя отменить.',
			'students.filter.title' => 'Фильтры',
			'students.filter.group' => 'Группа',
			'students.filter.status' => 'Статус',
			'students.filter.apply' => 'Применить',
			'students.filter.reset' => 'Сбросить фильтры',
			'students.filter.empty' => 'Ученики не найдены',
			'students.status.inactive' => 'Неактивен',
			'students.status.present' => 'Посетил',
			'students.status.missing' => 'Пропустил',
			'students.status.paid' => 'Оплачено',
			'students.status.unpaid' => 'Не оплачено',
			'students.status.free' => 'Бесплатно',
			'settings.title' => 'Настройки',
			'settings.appearance' => 'Внешний вид',
			'settings.language' => 'Язык',
			'settings.selectLanguage' => 'Выберите язык приложения',
			'settings.account' => 'Аккаунт',
			'settings.logout' => 'Выйти',
			'settings.logoutMessage' => 'Вы уверены, что хотите выйти?',
			'settings.deleteAccount' => 'Удалить аккаунт',
			'settings.deleteAccountMessage' => 'Аккаунт и все связанные данные будут удалены безвозвратно. Действие нельзя отменить.',
			'settings.deleteAccountCountdown' => ({required Object seconds}) => 'Удалить аккаунт можно будет через ${seconds} с',
			'settings.other' => 'Другое',
			'settings.version' => 'Версия',
			'settings.contacts' => 'Контакты',
			'settings.privacyPolicy' => 'Политика конфиденциальности',
			'reports.number' => '№',
			'reports.fullName' => 'ФИО',
			'reports.paid' => 'Оплачено',
			'reports.result' => 'Итог',
			'reports.total' => 'Всего',
			'finance.title' => 'Финансы',
			'finance.createTransaction' => 'Новая транзакция',
			'finance.income' => 'Доходы',
			'finance.expenses' => 'Расходы',
			'finance.lastTransactions' => 'Последние операции',
			'finance.transactionTitle' => 'Транзакция',
			'finance.transactionId' => 'ID операции',
			'finance.date' => 'Дата',
			'finance.amount' => 'Сумма',
			'finance.type' => 'Тип',
			'finance.typeIncome' => 'Доход',
			'finance.typeExpense' => 'Расход',
			'finance.student' => 'Ученик',
			'finance.paidUntil' => 'Оплачено до',
			'finance.createdAt' => 'Создано',
			'finance.deposit' => 'Пополнение',
			'finance.withdrawal' => 'Списание',
			'finance.editTransaction' => 'Редактировать транзакцию',
			'finance.deleteTransaction' => 'Удалить транзакцию?',
			'finance.deleteTransactionMessage' => 'Транзакция будет удалена безвозвратно. Действие нельзя отменить.',
			'finance.filter.title' => 'Период',
			'finance.filter.start' => 'Начало',
			'finance.filter.end' => 'Конец',
			'finance.filter.apply' => 'Продолжить',
			'finance.filter.reset' => 'Сбросить фильтры',
			_ => null,
		};
	}
}
