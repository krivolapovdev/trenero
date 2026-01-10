import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

const resources = {
  en: {
    translation: {
      search: 'Search',
      signInWithApple: 'Sign in with Apple',
      signInWithGoogle: 'Sign in with Google',
      payments: 'Payments',
      statistics: 'Statistics',
      groups: 'Groups',
      addGroup: 'Add Group',
      editGroup: 'Edit Group',
      name: 'Name *',
      defaultPrice: 'Default price',
      note: 'Note',
      students: 'Students',
      group: 'Group',
      error: 'Error',
      deleteGroup: 'Delete Group',
      deleteGroupConfirmation: 'Are you sure you want to delete this group?',
      cancel: 'Cancel',
      delete: 'Delete',
      addLesson: 'Add Lesson',
      unassigned: 'Unassigned',
      addStudent: 'Add Student',
      fullName: 'Full name *',
      phoneNumber: 'Phone number',
      birthday: 'Birthday',
      student: 'Student',
      deleteStudent: 'Delete student',
      deleteStudentConfirmation:
        'Are you sure you want to delete this student?',
      groupLabel: 'Group',
      phoneLabel: 'Phone',
      birthdateLabel: 'Birthdate',
      noteLabel: 'Note',
      termsTitle: 'Terms & Privacy Policy',
      agreeText: 'By continuing, you agree to our',
      termsPrivacy: 'Terms & Privacy Policy',
      termsOfServiceTitle: 'Terms of Service',
      termsOfServiceText:
        'By accessing or using this application, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service. The application is provided on an “as is” and “as available” basis, without warranties of any kind, whether express, implied, or statutory, including but not limited to implied warranties of merchantability, fitness for a particular purpose, and non-infringement.',
      privacyPolicyTitle: 'Privacy Policy',
      privacyPolicyText:
        'We collect and process only the information necessary to provide and maintain the application. Personal data is not sold, rented, or otherwise disclosed to third parties except as required by law. Reasonable administrative, technical, and organizational measures are implemented to protect personal data from unauthorized access, use, or disclosure.',
      addPayment: 'Add Payment',
      amount: 'Amount *',
      lessonsPerPayment: 'Lessons per payment *',
      date: 'Date *',
      enterLessonsError: 'Please enter the number of lessons',
      invalidDateError: 'Invalid date format',
      studentStatus: {
        no_activity: 'No activity',
        present: 'Present',
        missing: 'Missing',
        paid: 'Paid',
        unpaid: 'Unpaid'
      },
      selectAll: 'Select All',
      unselectAll: 'Unselect All',
      ok: 'OK',
      close: 'Close',
      settings: 'Settings',
      appearance: 'APPEARANCE',
      account: 'ACCOUNT',
      other: 'OTHER',
      language: 'Language',
      logout: 'Logout',
      version: 'Version',
      contact: 'Contact',
      confirmLogout: 'Confirm Logout',
      logoutMessage: 'Are you sure you want to logout?',
      contactMessage:
        'Do you have questions regarding our services or suggestions for future improvements? We are committed to providing the best experience possible and welcome your communication. Please use the following contact information to get in touch with our team:'
    }
  },
  ru: {
    translation: {
      signInWithApple: 'Войти через Apple',
      signInWithGoogle: 'Войти через Google',
      search: 'Поиск',
      statistics: 'Статистика',
      payments: 'Платежи',
      groups: 'Группы',
      addGroup: 'Добавить группу',
      editGroup: 'Редактировать группу',
      name: 'Имя *',
      defaultPrice: 'Цена по умолчанию',
      note: 'Заметка',
      students: 'Ученики',
      group: 'Группа',
      error: 'Ошибка',
      deleteGroup: 'Удалить группу',
      cancel: 'Отмена',
      delete: 'Удалить',
      addLesson: 'Добавить урок',
      unassigned: 'Не назначен',
      addStudent: 'Добавить студента',
      fullName: 'ФИО *',
      phoneNumber: 'Номер телефона',
      birthday: 'Дата рождения',
      student: 'Студент',
      deleteStudent: 'Удалить студента',
      deleteStudentConfirmation:
        'Вы уверены, что хотите удалить этого студента?',
      groupLabel: 'Группа',
      phoneLabel: 'Телефон',
      birthdateLabel: 'Дата рождения',
      noteLabel: 'Заметка',
      agreeText: 'Продолжая, вы соглашаетесь с нашими',
      termsPrivacy: 'Правилами и Политикой конфиденциальности',
      termsTitle: 'Правила и Политика конфиденциальности',
      termsOfServiceTitle: 'Условия использования',
      termsOfServiceText:
        'Используя это приложение, вы подтверждаете, что прочитали, поняли и соглашаетесь соблюдать данные Условия использования. Приложение предоставляется «как есть» и «по мере доступности» без каких-либо гарантий, явных или подразумеваемых, включая, помимо прочего, подразумеваемые гарантии товарной пригодности, соответствия определённой цели и отсутствия нарушения прав третьих лиц.',
      privacyPolicyTitle: 'Политика конфиденциальности',
      privacyPolicyText:
        'Мы собираем и обрабатываем только ту информацию, которая необходима для предоставления и поддержки работы приложения. Персональные данные не продаются, не передаются в аренду и не раскрываются третьим лицам, за исключением случаев, предусмотренных законом. Для защиты персональных данных от несанкционированного доступа, использования или раскрытия применяются разумные административные, технические и организационные меры.',
      addPayment: 'Добавить платёж',
      amount: 'Сумма *',
      lessonsPerPayment: 'Количество оплаченных занятий *',
      date: 'Дата *',
      enterLessonsError: 'Пожалуйста, введите количество занятий',
      invalidDateError: 'Неверный формат даты',
      studentStatus: {
        no_activity: 'Нет активности',
        present: 'Посетил',
        missing: 'Пропустил',
        paid: 'Оплачено',
        unpaid: 'Не оплачено'
      },
      selectAll: 'Выбрать всех',
      unselectAll: 'Снять всех',
      ok: 'ОК',
      close: 'Закрыть',
      settings: 'Настройки',
      appearance: 'Внешний вид',
      account: 'Аккаунт',
      other: 'Другое',
      language: 'Язык',
      logout: 'Выйти',
      version: 'Версия',
      contact: 'Контакты',
      confirmLogout: 'Подтвердите выход',
      logoutMessage: 'Вы уверены, что хотите выйти?',
      contactMessage:
        'Есть вопросы по нашим услугам или предложения по улучшению? Мы стремимся предоставить наилучший опыт и приветствуем ваше сообщение. Пожалуйста, используйте следующую контактную информацию для связи с нашей командой:'
    }
  }
} as const;

export const initI18n = async (lang?: string) => {
  await i18n.use(initReactI18next).init({
    lng: lang ?? 'en',
    fallbackLng: 'en',
    interpolation: { escapeValue: false },
    react: { useSuspense: false },
    resources
  });
};

export default i18n;
