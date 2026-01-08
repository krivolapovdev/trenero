import AsyncStorage from '@react-native-async-storage/async-storage';
import dayjs from 'dayjs';
import { memo } from 'react';
import { useTranslation } from 'react-i18next';
import { LocaleConfig } from 'react-native-calendars';
import { Dialog, Portal, RadioButton } from 'react-native-paper';

const languages = ['en', 'ru'];

type Props = {
  visible: boolean;
  onDismiss: () => void;
};

export const LanguageDialog = memo(
  ({ visible, onDismiss }: Readonly<Props>) => {
    const { i18n } = useTranslation();

    const handleLanguageChange = async (lang: string) => {
      dayjs.locale(lang);

      LocaleConfig.locales[lang] = {
        monthNames: dayjs.months(),
        monthNamesShort: dayjs.monthsShort(),
        dayNames: dayjs.weekdays(),
        dayNamesShort: dayjs.weekdaysShort(),
        today: lang === 'ru' ? 'Сегодня' : 'Today'
      };
      LocaleConfig.defaultLocale = lang;

      await i18n.changeLanguage(lang);

      await AsyncStorage.setItem('language', lang);

      onDismiss();
    };

    return (
      <Portal>
        <Dialog
          visible={visible}
          onDismiss={onDismiss}
        >
          <Dialog.Title>Language</Dialog.Title>
          <Dialog.Content>
            <RadioButton.Group
              onValueChange={handleLanguageChange}
              value={i18n.language}
            >
              {languages.map(lng => (
                <RadioButton.Item
                  key={lng}
                  label={lng.toUpperCase()}
                  value={lng}
                />
              ))}
            </RadioButton.Group>
          </Dialog.Content>
        </Dialog>
      </Portal>
    );
  }
);
