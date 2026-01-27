import { Redirect } from 'expo-router';
import { useEffect, useState } from 'react';
import { initI18n } from '@/src/i18n';
import '@/src/helpers/dayjs';
import AsyncStorage from '@react-native-async-storage/async-storage';
import dayjs from 'dayjs';
import { getLocales } from 'expo-localization';
import { LocaleConfig } from 'react-native-calendars';
import { en, registerTranslation, ru } from 'react-native-paper-dates';
import { LoadingSpinner } from '@/src/components/LoadingSpinner';

registerTranslation('en', en);
registerTranslation('ru', ru);

export default function Index() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadLanguages = async () => {
      try {
        setLoading(true);

        const storedLang = await AsyncStorage.getItem('language');
        const lang = storedLang ?? getLocales()?.[0]?.languageCode ?? 'en';

        dayjs.locale(lang);

        LocaleConfig.locales[lang] = {
          monthNames: dayjs.months(),
          monthNamesShort: dayjs.monthsShort(),
          dayNames: dayjs.weekdays(),
          dayNamesShort: dayjs.weekdaysShort(),
          today: lang === 'ru' ? 'Сегодня' : 'Today'
        };

        LocaleConfig.defaultLocale = lang;

        await initI18n(lang);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    void loadLanguages();
  }, []);

  if (loading) {
    return <LoadingSpinner />;
  }

  return <Redirect href='/auth' />;
}
