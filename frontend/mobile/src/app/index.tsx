import { Redirect } from 'expo-router';
import { useEffect, useState } from 'react';
import '@/src/i18n';
import '@/src/helpers/dayjs';
import AsyncStorage from '@react-native-async-storage/async-storage';
import dayjs from 'dayjs';
import { getLocales } from 'expo-localization';
import { LocaleConfig } from 'react-native-calendars';
import { LoadingSpinner } from '@/src/components/LoadingSpinner';
import { initI18n } from '@/src/i18n';

export default function Index() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadLanguages = async () => {
      try {
        setLoading(true);

        const lang =
          (await AsyncStorage.getItem('language')) ??
          getLocales()?.[0]?.languageCode ??
          'en';

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
      } finally {
        setLoading(false);
      }
    };

    void loadLanguages();
  }, []);

  if (loading) {
    return <LoadingSpinner />;
  }

  return <Redirect href='/(auth)' />;
}
