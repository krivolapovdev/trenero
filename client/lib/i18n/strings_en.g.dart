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

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Month'
	String get month => 'Month';

	/// en: 'Year'
	String get year => 'Year';

	/// en: 'Print'
	String get print => 'Print';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'No data'
	String get noData => 'No data';

	/// en: 'No transactions'
	String get noTransactions => 'No transactions';

	/// en: 'Please, update the app'
	String get pleaseUpdateApp => 'Please, update the app';

	/// en: 'Invalid date'
	String get invalidDate => 'Invalid date';

	/// en: '$title: $count'
	String titleWithCount({required Object title, required Object count}) => '${title}: ${count}';

	/// en: 'Error loading data: $error'
	String errorLoadingData({required Object error}) => 'Error loading data: ${error}';

	late final Translations$errors$en errors = Translations$errors$en._(_root);
	late final Translations$auth$en auth = Translations$auth$en._(_root);
	late final Translations$groups$en groups = Translations$groups$en._(_root);
	late final Translations$lessons$en lessons = Translations$lessons$en._(_root);
	late final Translations$students$en students = Translations$students$en._(_root);
	late final Translations$rosters$en rosters = Translations$rosters$en._(_root);
	late final Translations$settings$en settings = Translations$settings$en._(_root);
	late final Translations$reports$en reports = Translations$reports$en._(_root);
	late final Translations$finance$en finance = Translations$finance$en._(_root);
}

// Path: errors
class Translations$errors$en {
	Translations$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You appear to be offline. Check your connection and try again.'
	String get network => 'You appear to be offline. Check your connection and try again.';

	/// en: 'The server took too long to respond. Please try again.'
	String get timeout => 'The server took too long to respond. Please try again.';

	/// en: 'The request was cancelled.'
	String get cancelled => 'The request was cancelled.';

	/// en: 'Your session has expired. Please sign in again.'
	String get unauthorized => 'Your session has expired. Please sign in again.';

	/// en: 'You do not have permission to do this.'
	String get forbidden => 'You do not have permission to do this.';

	/// en: 'The record you asked for no longer exists.'
	String get notFound => 'The record you asked for no longer exists.';

	/// en: 'This clashes with the data that is already saved.'
	String get conflict => 'This clashes with the data that is already saved.';

	/// en: 'The request was rejected. Check the form and try again.'
	String get validation => 'The request was rejected. Check the form and try again.';

	/// en: 'The request was rejected. Please try again.'
	String get badRequest => 'The request was rejected. Please try again.';

	/// en: 'The server is not available right now. Please try again later.'
	String get server => 'The server is not available right now. Please try again later.';

	/// en: 'Something went wrong. Please try again.'
	String get unknown => 'Something went wrong. Please try again.';

	/// en: 'Signing in failed. Please try again.'
	String get signingIn => 'Signing in failed. Please try again.';

	/// en: 'Student name is required.'
	String get studentNameRequired => 'Student name is required.';

	/// en: 'Group name is required.'
	String get groupNameRequired => 'Group name is required.';

	/// en: 'Enter a valid price.'
	String get invalidPrice => 'Enter a valid price.';

	/// en: 'A student with this name already exists.'
	String get studentNameNotUnique => 'A student with this name already exists.';

	/// en: 'A group with this name already exists.'
	String get groupNameNotUnique => 'A group with this name already exists.';
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in with Google'
	String get signInWithGoogle => 'Sign in with Google';

	/// en: 'By signing in, you agree to our Privacy Policy'
	String get agreePrivacyPolicy => 'By signing in, you agree to our Privacy Policy';

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Reviewer key'
	String get reviewerKey => 'Reviewer key';
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

	/// en: 'No groups found'
	String get notFound => 'No groups found';

	/// en: 'Delete group?'
	String get deleteGroup => 'Delete group?';

	/// en: 'The group will be deleted permanently. This action cannot be undone.'
	String get deleteGroupMessage => 'The group will be deleted permanently. This action cannot be undone.';
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

	/// en: 'Group lesson: $name'
	String groupLessonTitle({required Object name}) => 'Group lesson: ${name}';

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

	/// en: 'Absent'
	String get absent => 'Absent';

	/// en: 'Excused'
	String get excused => 'Excused';

	/// en: 'Unmarked'
	String get unmarked => 'Unmarked';

	/// en: 'Not marked'
	String get notMarked => 'Not marked';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Regular'
	String get regular => 'Regular';

	/// en: 'Free'
	String get free => 'Free';

	/// en: 'The lesson is free'
	String get freeLesson => 'The lesson is free';

	/// en: 'Delete lesson?'
	String get deleteLesson => 'Delete lesson?';

	/// en: 'The lesson and its attendance will be deleted permanently. This action cannot be undone.'
	String get deleteLessonMessage => 'The lesson and its attendance will be deleted permanently. This action cannot be undone.';

	/// en: 'Error loading lessons: $error'
	String errorLoading({required Object error}) => 'Error loading lessons: ${error}';

	/// en: 'No lessons scheduled for this day.'
	String get emptyDay => 'No lessons scheduled for this day.';

	/// en: 'Lessons for $date'
	String forDate({required Object date}) => 'Lessons for ${date}';
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

	/// en: 'No student'
	String get noStudent => 'No student';

	/// en: 'Studies for free'
	String get free => 'Studies for free';

	/// en: 'Payment'
	String get payment => 'Payment';

	/// en: 'Payments: $name'
	String paymentTitle({required Object name}) => 'Payments: ${name}';

	/// en: 'The student has no payments yet'
	String get noPayments => 'The student has no payments yet';

	/// en: 'Error loading students: $error'
	String errorLoading({required Object error}) => 'Error loading students: ${error}';

	/// en: 'Delete student?'
	String get deleteStudent => 'Delete student?';

	/// en: 'The student and their lessons will be deleted permanently. This action cannot be undone.'
	String get deleteStudentMessage => 'The student and their lessons will be deleted permanently. This action cannot be undone.';

	late final Translations$students$filter$en filter = Translations$students$filter$en._(_root);
	late final Translations$students$status$en status = Translations$students$status$en._(_root);
}

// Path: rosters
class Translations$rosters$en {
	Translations$rosters$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Temporary rosters'
	String get title => 'Temporary rosters';

	/// en: 'Temporary rosters'
	String get temporaryRosters => 'Temporary rosters';

	/// en: 'No temporary rosters yet'
	String get emptySubtitle => 'No temporary rosters yet';

	/// en: 'Create First Roster'
	String get createFirstRoster => 'Create First Roster';

	/// en: 'Add Roster'
	String get createRoster => 'Add Roster';

	/// en: 'Edit Roster'
	String get editRoster => 'Edit Roster';

	/// en: 'Delete roster?'
	String get deleteRoster => 'Delete roster?';

	/// en: 'The roster will be deleted permanently. This action cannot be undone.'
	String get deleteRosterMessage => 'The roster will be deleted permanently. This action cannot be undone.';

	/// en: 'No rosters found'
	String get notFound => 'No rosters found';

	/// en: '$count students'
	String studentsCount({required Object count}) => '${count} students';

	/// en: 'No students in this roster yet'
	String get noStudents => 'No students in this roster yet';

	/// en: 'Add students'
	String get addStudents => 'Add students';

	/// en: 'Remove from roster'
	String get removeStudent => 'Remove from roster';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Note'
	String get note => 'Note';

	/// en: 'Open'
	String get open => 'Open';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Search rosters...'
	String get search => 'Search rosters...';

	/// en: 'Error loading rosters: $error'
	String errorLoading({required Object error}) => 'Error loading rosters: ${error}';
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

// Path: finance
class Translations$finance$en {
	Translations$finance$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finance'
	String get title => 'Finance';

	/// en: 'New transaction'
	String get createTransaction => 'New transaction';

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

	late final Translations$finance$filter$en filter = Translations$finance$filter$en._(_root);
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

	/// en: 'Free'
	String get free => 'Free';
}

// Path: finance.filter
class Translations$finance$filter$en {
	Translations$finance$filter$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Period'
	String get title => 'Period';

	/// en: 'Start'
	String get start => 'Start';

	/// en: 'End'
	String get end => 'End';

	/// en: 'Continue'
	String get apply => 'Continue';
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
			'reset' => 'Reset',
			'edit' => 'Edit',
			'delete' => 'Delete',
			'all' => 'All',
			'add' => 'Add',
			'month' => 'Month',
			'year' => 'Year',
			'print' => 'Print',
			'error' => 'Error',
			'noData' => 'No data',
			'noTransactions' => 'No transactions',
			'pleaseUpdateApp' => 'Please, update the app',
			'invalidDate' => 'Invalid date',
			'titleWithCount' => ({required Object title, required Object count}) => '${title}: ${count}',
			'errorLoadingData' => ({required Object error}) => 'Error loading data: ${error}',
			'errors.network' => 'You appear to be offline. Check your connection and try again.',
			'errors.timeout' => 'The server took too long to respond. Please try again.',
			'errors.cancelled' => 'The request was cancelled.',
			'errors.unauthorized' => 'Your session has expired. Please sign in again.',
			'errors.forbidden' => 'You do not have permission to do this.',
			'errors.notFound' => 'The record you asked for no longer exists.',
			'errors.conflict' => 'This clashes with the data that is already saved.',
			'errors.validation' => 'The request was rejected. Check the form and try again.',
			'errors.badRequest' => 'The request was rejected. Please try again.',
			'errors.server' => 'The server is not available right now. Please try again later.',
			'errors.unknown' => 'Something went wrong. Please try again.',
			'errors.signingIn' => 'Signing in failed. Please try again.',
			'errors.studentNameRequired' => 'Student name is required.',
			'errors.groupNameRequired' => 'Group name is required.',
			'errors.invalidPrice' => 'Enter a valid price.',
			'errors.studentNameNotUnique' => 'A student with this name already exists.',
			'errors.groupNameNotUnique' => 'A group with this name already exists.',
			'auth.signInWithGoogle' => 'Sign in with Google',
			'auth.agreePrivacyPolicy' => 'By signing in, you agree to our Privacy Policy',
			'auth.login' => 'Login',
			'auth.reviewerKey' => 'Reviewer key',
			'groups.title' => 'Groups',
			'groups.emptySubtitle' => 'No Groups yet',
			'groups.createFirstGroup' => 'Create First Group',
			'groups.createGroup' => 'Add Group',
			'groups.editGroup' => 'Edit Group',
			'groups.noGroup' => 'No group',
			'groups.defaultPrice' => 'Price by default',
			'groups.report' => 'Report',
			'groups.notFound' => 'No groups found',
			'groups.deleteGroup' => 'Delete group?',
			'groups.deleteGroupMessage' => 'The group will be deleted permanently. This action cannot be undone.',
			'lessons.title' => 'Lesson',
			'lessons.individualLesson' => 'Individual lesson',
			'lessons.individualLessons' => 'Individual lessons',
			'lessons.groupLesson' => 'Group lesson',
			'lessons.groupLessonTitle' => ({required Object name}) => 'Group lesson: ${name}',
			'lessons.groupLessons' => 'Group lessons',
			'lessons.date' => 'Date',
			'lessons.selectAll' => 'Select all',
			'lessons.deselectAll' => 'Deselect all',
			'lessons.noStudents' => 'This group has no students yet',
			'lessons.present' => 'Present',
			'lessons.missed' => 'Missed',
			'lessons.absent' => 'Absent',
			'lessons.excused' => 'Excused',
			'lessons.unmarked' => 'Unmarked',
			'lessons.notMarked' => 'Not marked',
			'lessons.status' => 'Status',
			'lessons.type' => 'Type',
			'lessons.regular' => 'Regular',
			'lessons.free' => 'Free',
			'lessons.freeLesson' => 'The lesson is free',
			'lessons.deleteLesson' => 'Delete lesson?',
			'lessons.deleteLessonMessage' => 'The lesson and its attendance will be deleted permanently. This action cannot be undone.',
			'lessons.errorLoading' => ({required Object error}) => 'Error loading lessons: ${error}',
			'lessons.emptyDay' => 'No lessons scheduled for this day.',
			'lessons.forDate' => ({required Object date}) => 'Lessons for ${date}',
			'students.title' => 'Students',
			'students.emptySubtitle' => 'No students yet',
			'students.createFirstStudent' => 'Create First Student',
			'students.createStudent' => 'Add Student',
			'students.editStudent' => 'Edit Student',
			'students.fullName' => 'Full name',
			'students.birthdate' => 'Date of birth',
			'students.phone' => 'Phone',
			'students.group' => 'Group',
			'students.noStudent' => 'No student',
			'students.free' => 'Studies for free',
			'students.payment' => 'Payment',
			'students.paymentTitle' => ({required Object name}) => 'Payments: ${name}',
			'students.noPayments' => 'The student has no payments yet',
			'students.errorLoading' => ({required Object error}) => 'Error loading students: ${error}',
			'students.deleteStudent' => 'Delete student?',
			'students.deleteStudentMessage' => 'The student and their lessons will be deleted permanently. This action cannot be undone.',
			'students.filter.title' => 'Filters',
			'students.filter.group' => 'Group',
			'students.filter.status' => 'Status',
			'students.filter.apply' => 'Apply',
			'students.filter.empty' => 'No students found',
			'students.status.inactive' => 'Inactive',
			'students.status.present' => 'Present',
			'students.status.missing' => 'Missing',
			'students.status.paid' => 'Paid',
			'students.status.unpaid' => 'Unpaid',
			'students.status.free' => 'Free',
			'rosters.title' => 'Temporary rosters',
			'rosters.temporaryRosters' => 'Temporary rosters',
			'rosters.emptySubtitle' => 'No temporary rosters yet',
			'rosters.createFirstRoster' => 'Create First Roster',
			'rosters.createRoster' => 'Add Roster',
			'rosters.editRoster' => 'Edit Roster',
			'rosters.deleteRoster' => 'Delete roster?',
			'rosters.deleteRosterMessage' => 'The roster will be deleted permanently. This action cannot be undone.',
			'rosters.notFound' => 'No rosters found',
			'rosters.studentsCount' => ({required Object count}) => '${count} students',
			'rosters.noStudents' => 'No students in this roster yet',
			'rosters.addStudents' => 'Add students',
			'rosters.removeStudent' => 'Remove from roster',
			'rosters.date' => 'Date',
			'rosters.note' => 'Note',
			'rosters.open' => 'Open',
			'rosters.preview' => 'Preview',
			'rosters.search' => 'Search rosters...',
			'rosters.errorLoading' => ({required Object error}) => 'Error loading rosters: ${error}',
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
			'reports.number' => '№',
			'reports.fullName' => 'Full name',
			'reports.paid' => 'Paid',
			'reports.result' => 'Result',
			'reports.total' => 'Total',
			'finance.title' => 'Finance',
			'finance.createTransaction' => 'New transaction',
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
			'finance.filter.title' => 'Period',
			'finance.filter.start' => 'Start',
			'finance.filter.end' => 'End',
			'finance.filter.apply' => 'Continue',
			_ => null,
		};
	}
}
