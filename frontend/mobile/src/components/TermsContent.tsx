import { useTranslation } from 'react-i18next';
import { View } from 'react-native';
import { Text } from 'react-native-paper';

export const TermsContent = () => {
  const { t } = useTranslation();

  return (
    <View style={{ gap: 14, paddingVertical: 10 }}>
      <Text
        variant='titleLarge'
        style={{ textAlign: 'center' }}
      >
        {t('termsTitle')}
      </Text>

      <Text
        variant='bodyMedium'
        style={{ textAlign: 'justify' }}
      >
        {t('termsOfServiceTitle')}
      </Text>

      <Text
        variant='bodyMedium'
        style={{ textAlign: 'justify' }}
      >
        {t('termsOfServiceText')}
      </Text>

      <Text
        variant='bodyMedium'
        style={{ textAlign: 'justify' }}
      >
        {t('privacyPolicyTitle')}
      </Text>

      <Text
        variant='bodyMedium'
        style={{ textAlign: 'justify' }}
      >
        {t('privacyPolicyText')}
      </Text>
    </View>
  );
};
