import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, Linking, ScrollView, View } from 'react-native';
import { List, Text } from 'react-native-paper';
import { deleteAccount } from '@/src/api/services/user/userService';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { ConfirmDialog, LanguageDialog } from '@/src/components/Dialog';
import { LabeledSection } from '@/src/components/LabeledSection';
import { SettingsItem } from '@/src/components/SettingsItem';
import { PRIVACY_POLICY_URL } from '@/src/data/constants';
import { extractErrorMessage } from '@/src/helpers/apiError';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useAuthStore } from '@/src/stores/authStore';

export default function SettingsScreen() {
  const { t } = useTranslation();
  const theme = useAppTheme();
  const logout = useAuthStore(state => state.logout);

  const [logoutDialogVisible, setLogoutDialogVisible] = useState(false);
  const [languageMenuVisible, setLanguageMenuVisible] = useState(false);
  const [contactDialogVisible, setContactDialogVisible] = useState(false);
  const [deleteAccountDialogVisible, setDeleteAccountDialogVisible] =
    useState(false);

  const handleLogout = async () => {
    await logout();
    setLogoutDialogVisible(false);
  };

  const handleDeleteAccount = async () => {
    try {
      await deleteAccount();
      await logout();
      setDeleteAccountDialogVisible(false);
    } catch (error) {
      Alert.alert(t('error'), extractErrorMessage(error));
    }
  };

  return (
    <>
      <CustomAppbar
        title={t('settings')}
        mode='center-aligned'
      />

      <ScrollView
        contentContainerStyle={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant,
          padding: 16
        }}
      >
        <LabeledSection title={t('appearance')}>
          <SettingsItem
            title={t('language')}
            icon='flag-outline'
            right={() => <List.Icon icon='chevron-right' />}
            onPress={() => setLanguageMenuVisible(true)}
          />
        </LabeledSection>

        <LabeledSection title={t('account')}>
          <SettingsItem
            title={t('logout')}
            icon='logout'
            right={() => <List.Icon icon='chevron-right' />}
            onPress={() => setLogoutDialogVisible(true)}
          />

          <SettingsItem
            title={t('deleteAccount')}
            icon='trash-can-outline'
            right={() => <List.Icon icon='chevron-right' />}
            onPress={() => setDeleteAccountDialogVisible(true)}
          />
        </LabeledSection>

        <LabeledSection title={t('other')}>
          <SettingsItem
            title={t('version')}
            icon='application-brackets-outline'
            right={() => <Text variant='bodyMedium'>1.0.0</Text>}
          />

          <SettingsItem
            title={t('contact')}
            icon='account-circle-outline'
            right={() => <List.Icon icon='chevron-right' />}
            onPress={() => setContactDialogVisible(true)}
          />

          <SettingsItem
            title={t('privacyPolicy')}
            icon='police-badge-outline'
            right={() => <List.Icon icon='link-variant' />}
            onPress={() => Linking.openURL(PRIVACY_POLICY_URL)}
          />
        </LabeledSection>
      </ScrollView>

      <LanguageDialog
        visible={languageMenuVisible}
        onDismiss={() => setLanguageMenuVisible(false)}
      />

      <ConfirmDialog
        visible={logoutDialogVisible}
        title={t('confirmLogout')}
        onConfirm={handleLogout}
        onCancel={() => setLogoutDialogVisible(false)}
        confirmText={t('logout')}
      >
        <Text variant='bodyMedium'>{t('logoutMessage')}</Text>
      </ConfirmDialog>

      <ConfirmDialog
        visible={contactDialogVisible}
        title={t('contact')}
        onConfirm={() => setContactDialogVisible(false)}
      >
        <View style={{ gap: 10 }}>
          <Text
            variant='bodyMedium'
            style={{ textAlign: 'justify' }}
          >
            {t('contactMessage')}
          </Text>

          <Text
            style={{ fontWeight: '700' }}
            onPress={() => Linking.openURL('https://t.me/krivolapovdev')}
          >
            Telegram: @krivolapovdev
          </Text>

          <Text
            style={{ fontWeight: '700' }}
            onPress={() =>
              Linking.openURL('mailto:KrivolapovVladislav1998@gmail.com')
            }
          >
            Email: KrivolapovVladislav1998@gmail.com
          </Text>
        </View>
      </ConfirmDialog>

      <ConfirmDialog
        visible={deleteAccountDialogVisible}
        title={t('deleteAccount')}
        onConfirm={handleDeleteAccount}
        onCancel={() => setDeleteAccountDialogVisible(false)}
        delay={10}
      >
        <Text
          variant='bodyMedium'
          style={{ textAlign: 'justify' }}
        >
          {t('deleteAccountWarning')}
        </Text>
      </ConfirmDialog>
    </>
  );
}
