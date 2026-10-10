///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Note'
	String get note => 'Note';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Repeat'
	String get repeat => 'Repeat';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Update'
	String get update => 'Update';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';

	/// en: 'Print'
	String get print => 'Print';

	/// en: 'Error'
	String get error => 'Error';

	late final Translations$auth$en auth = Translations$auth$en._(_root);
	late final Translations$home$en home = Translations$home$en._(_root);
	late final Translations$groups$en groups = Translations$groups$en._(_root);
	late final Translations$lessons$en lessons = Translations$lessons$en._(_root);
	late final Translations$students$en students = Translations$students$en._(_root);
	late final Translations$settings$en settings = Translations$settings$en._(_root);
	late final Translations$reports$en reports = Translations$reports$en._(_root);
	late final Translations$transactions$en transactions = Translations$transactions$en._(_root);
	late final Translations$finance$en finance = Translations$finance$en._(_root);
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in with Apple'
	String get signInWithApple => 'Sign in with Apple';

	/// en: 'Sign in with Google'
	String get signInWithGoogle => 'Sign in with Google';

	/// en: 'By signing in, you agree to our Privacy Policy'
	String get agreePrivacyPolicy => 'By signing in, you agree to our Privacy Policy';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Reviewer key'
	String get reviewerKey => 'Reviewer key';
}

// Path: home
class Translations$home$en {
	Translations$home$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Main'
	String get title => 'Main';
}

// Path: groups
class Translations$groups$en {
	Translations$groups$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Groups'
	String get title => 'Groups';

	/// en: 'No Groups yet'
	String get emptySubtitle => 'No Groups yet';

	/// en: 'Create First Group'
	String get createFirstGroup => 'Create First Group';

	/// en: 'Add Group'
	String get createGroup => 'Add Group';

	/// en: 'Edit Group'
	String get editGroup => 'Edit Group';

	/// en: 'No group'
	String get noGroup => 'No group';

	/// en: 'Price by default'
	String get defaultPrice => 'Price by default';

	/// en: 'Report'
	String get report => 'Report';
}

// Path: lessons
class Translations$lessons$en {
	Translations$lessons$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lesson'
	String get title => 'Lesson';

	/// en: 'Individual lesson'
	String get individualLesson => 'Individual lesson';

	/// en: 'Individual lessons'
	String get individualLessons => 'Individual lessons';

	/// en: 'Group lesson'
	String get groupLesson => 'Group lesson';

	/// en: 'Group lessons'
	String get groupLessons => 'Group lessons';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Select all'
	String get selectAll => 'Select all';

	/// en: 'Deselect all'
	String get deselectAll => 'Deselect all';

	/// en: 'This group has no students yet'
	String get noStudents => 'This group has no students yet';

	/// en: 'Present'
	String get present => 'Present';

	/// en: 'Missed'
	String get missed => 'Missed';

	/// en: 'Delete lesson?'
	String get deleteLesson => 'Delete lesson?';

	/// en: 'The lesson and its attendance will be deleted permanently. This action cannot be undone.'
	String get deleteLessonMessage => 'The lesson and its attendance will be deleted permanently. This action cannot be undone.';
}

// Path: students
class Translations$students$en {
	Translations$students$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Students'
	String get title => 'Students';

	/// en: 'No students yet'
	String get emptySubtitle => 'No students yet';

	/// en: 'Create First Student'
	String get createFirstStudent => 'Create First Student';

	/// en: 'Add Student'
	String get createStudent => 'Add Student';

	/// en: 'Edit Student'
	String get editStudent => 'Edit Student';

	/// en: 'Full name'
	String get fullName => 'Full name';

	/// en: 'Date of birth'
	String get birthdate => 'Date of birth';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Group'
	String get group => 'Group';

	/// en: 'Joined at'
	String get joinedAt => 'Joined at';

	/// en: 'No student'
	String get noStudent => 'No student';

	late final Translations$students$filter$en filter = Translations$students$filter$en._(_root);
	late final Translations$students$status$en status = Translations$students$status$en._(_root);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'Appearance'
	String get appearance => 'Appearance';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Select the application language'
	String get selectLanguage => 'Select the application language';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Log out'
	String get logout => 'Log out';

	/// en: 'Are you sure you want to log out?'
	String get logoutMessage => 'Are you sure you want to log out?';

	/// en: 'Delete account'
	String get deleteAccount => 'Delete account';

	/// en: 'The account and all its data will be deleted permanently. This action cannot be undone.'
	String get deleteAccountMessage => 'The account and all its data will be deleted permanently. This action cannot be undone.';

	/// en: 'You will be able to delete the account in $seconds s'
	String deleteAccountCountdown({required Object seconds}) => 'You will be able to delete the account in ${seconds} s';

	/// en: 'Other'
	String get other => 'Other';

	/// en: 'Version'
	String get version => 'Version';

	/// en: 'Contacts'
	String get contacts => 'Contacts';

	/// en: 'Privacy Policy'
	String get privacyPolicy => 'Privacy Policy';
}

// Path: reports
class Translations$reports$en {
	Translations$reports$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reports'
	String get title => 'Reports';

	/// en: 'Attendance and financial analytics'
	String get subtitle => 'Attendance and financial analytics';

	/// en: '№'
	String get number => '№';

	/// en: 'Full name'
	String get fullName => 'Full name';

	/// en: 'Paid'
	String get paid => 'Paid';

	/// en: 'Result'
	String get result => 'Result';

	/// en: 'Total'
	String get total => 'Total';
}

// Path: transactions
class Translations$transactions$en {
	Translations$transactions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transactions'
	String get title => 'Transactions';

	/// en: 'Income and expenses'
	String get subtitle => 'Income and expenses';
}

// Path: finance
class Translations$finance$en {
	Translations$finance$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finance'
	String get title => 'Finance';

	/// en: 'Income'
	String get income => 'Income';

	/// en: 'Expenses'
	String get expenses => 'Expenses';

	/// en: 'Last transactions'
	String get lastTransactions => 'Last transactions';

	/// en: 'Transaction'
	String get transactionTitle => 'Transaction';

	/// en: 'Transaction ID'
	String get transactionId => 'Transaction ID';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Income'
	String get typeIncome => 'Income';

	/// en: 'Expense'
	String get typeExpense => 'Expense';

	/// en: 'Student'
	String get student => 'Student';

	/// en: 'Paid until'
	String get paidUntil => 'Paid until';

	/// en: 'Created at'
	String get createdAt => 'Created at';

	/// en: 'Deposit'
	String get deposit => 'Deposit';

	/// en: 'Withdrawal'
	String get withdrawal => 'Withdrawal';

	/// en: 'Edit transaction'
	String get editTransaction => 'Edit transaction';

	/// en: 'Delete transaction?'
	String get deleteTransaction => 'Delete transaction?';

	/// en: 'The transaction will be deleted permanently. This action cannot be undone.'
	String get deleteTransactionMessage => 'The transaction will be deleted permanently. This action cannot be undone.';
}

// Path: students.filter
class Translations$students$filter$en {
	Translations$students$filter$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Filters'
	String get title => 'Filters';

	/// en: 'Group'
	String get group => 'Group';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Apply'
	String get apply => 'Apply';

	/// en: 'Reset filters'
	String get reset => 'Reset filters';

	/// en: 'No students found'
	String get empty => 'No students found';
}

// Path: students.status
class Translations$students$status$en {
	Translations$students$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Inactive'
	String get inactive => 'Inactive';

	/// en: 'Present'
	String get present => 'Present';

	/// en: 'Missing'
	String get missing => 'Missing';

	/// en: 'Paid'
	String get paid => 'Paid';

	/// en: 'Unpaid'
	String get unpaid => 'Unpaid';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'name' => 'Name',
			'note' => 'Note',
			'cancel' => 'Cancel',
			'repeat' => 'Repeat',
			'create' => 'Create',
			'update' => 'Update',
			'edit' => 'Edit',
			'delete' => 'Delete',
			'all' => 'All',
			'today' => 'Today',
			'yesterday' => 'Yesterday',
			'print' => 'Print',
			'error' => 'Error',
			'auth.signInWithApple' => 'Sign in with Apple',
			'auth.signInWithGoogle' => 'Sign in with Google',
			'auth.agreePrivacyPolicy' => 'By signing in, you agree to our Privacy Policy',
			'auth.login' => 'Login',
			'auth.reviewerKey' => 'Reviewer key',
			'home.title' => 'Main',
			'groups.title' => 'Groups',
			'groups.emptySubtitle' => 'No Groups yet',
			'groups.createFirstGroup' => 'Create First Group',
			'groups.createGroup' => 'Add Group',
			'groups.editGroup' => 'Edit Group',
			'groups.noGroup' => 'No group',
			'groups.defaultPrice' => 'Price by default',
			'groups.report' => 'Report',
			'lessons.title' => 'Lesson',
			'lessons.individualLesson' => 'Individual lesson',
			'lessons.individualLessons' => 'Individual lessons',
			'lessons.groupLesson' => 'Group lesson',
			'lessons.groupLessons' => 'Group lessons',
			'lessons.date' => 'Date',
			'lessons.selectAll' => 'Select all',
			'lessons.deselectAll' => 'Deselect all',
			'lessons.noStudents' => 'This group has no students yet',
			'lessons.present' => 'Present',
			'lessons.missed' => 'Missed',
			'lessons.deleteLesson' => 'Delete lesson?',
			'lessons.deleteLessonMessage' => 'The lesson and its attendance will be deleted permanently. This action cannot be undone.',
			'students.title' => 'Students',
			'students.emptySubtitle' => 'No students yet',
			'students.createFirstStudent' => 'Create First Student',
			'students.createStudent' => 'Add Student',
			'students.editStudent' => 'Edit Student',
			'students.fullName' => 'Full name',
			'students.birthdate' => 'Date of birth',
			'students.phone' => 'Phone',
			'students.group' => 'Group',
			'students.joinedAt' => 'Joined at',
			'students.noStudent' => 'No student',
			'students.filter.title' => 'Filters',
			'students.filter.group' => 'Group',
			'students.filter.status' => 'Status',
			'students.filter.apply' => 'Apply',
			'students.filter.reset' => 'Reset filters',
			'students.filter.empty' => 'No students found',
			'students.status.inactive' => 'Inactive',
			'students.status.present' => 'Present',
			'students.status.missing' => 'Missing',
			'students.status.paid' => 'Paid',
			'students.status.unpaid' => 'Unpaid',
			'settings.title' => 'Settings',
			'settings.appearance' => 'Appearance',
			'settings.language' => 'Language',
			'settings.selectLanguage' => 'Select the application language',
			'settings.account' => 'Account',
			'settings.logout' => 'Log out',
			'settings.logoutMessage' => 'Are you sure you want to log out?',
			'settings.deleteAccount' => 'Delete account',
			'settings.deleteAccountMessage' => 'The account and all its data will be deleted permanently. This action cannot be undone.',
			'settings.deleteAccountCountdown' => ({required Object seconds}) => 'You will be able to delete the account in ${seconds} s',
			'settings.other' => 'Other',
			'settings.version' => 'Version',
			'settings.contacts' => 'Contacts',
			'settings.privacyPolicy' => 'Privacy Policy',
			'reports.title' => 'Reports',
			'reports.subtitle' => 'Attendance and financial analytics',
			'reports.number' => '№',
			'reports.fullName' => 'Full name',
			'reports.paid' => 'Paid',
			'reports.result' => 'Result',
			'reports.total' => 'Total',
			'transactions.title' => 'Transactions',
			'transactions.subtitle' => 'Income and expenses',
			'finance.title' => 'Finance',
			'finance.income' => 'Income',
			'finance.expenses' => 'Expenses',
			'finance.lastTransactions' => 'Last transactions',
			'finance.transactionTitle' => 'Transaction',
			'finance.transactionId' => 'Transaction ID',
			'finance.date' => 'Date',
			'finance.amount' => 'Amount',
			'finance.type' => 'Type',
			'finance.typeIncome' => 'Income',
			'finance.typeExpense' => 'Expense',
			'finance.student' => 'Student',
			'finance.paidUntil' => 'Paid until',
			'finance.createdAt' => 'Created at',
			'finance.deposit' => 'Deposit',
			'finance.withdrawal' => 'Withdrawal',
			'finance.editTransaction' => 'Edit transaction',
			'finance.deleteTransaction' => 'Delete transaction?',
			'finance.deleteTransactionMessage' => 'The transaction will be deleted permanently. This action cannot be undone.',
			_ => null,
		};
	}
}
