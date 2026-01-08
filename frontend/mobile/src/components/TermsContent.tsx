import { useTranslation } from 'react-i18next';
import { Text } from 'react-native-paper';

export const TermsContent = () => {
  const { t } = useTranslation();

  return (
    <>
      <Text
        variant='titleLarge'
        style={{ marginBottom: 12 }}
      >
        {t('termsTitle')}
      </Text>

      <Text
        variant='bodyMedium'
        style={{ textAlign: 'justify', marginBottom: 12 }}
      >
        {t('termsOfServiceTitle')}
        {'\n\n'}
        {t('termsOfServiceText')}
      </Text>

      <Text
        variant='bodyMedium'
        style={{ textAlign: 'justify', marginBottom: 24 }}
      >
        {t('privacyPolicyTitle')}
        {'\n\n'}
        {t('privacyPolicyText')}
      </Text>
    </>
  );
};
