import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Linking, ScrollView, View } from 'react-native';
import { Divider, List, Text } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { ConfirmDialog, LanguageDialog } from '@/src/components/Dialog';
import { LabeledSection } from '@/src/components/LabeledSection';
import { SettingsItem } from '@/src/components/SettingsItem';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useAuthStore } from '@/src/stores/authStore';

export default function SettingsScreen() {
  const { t } = useTranslation();
  const theme = useAppTheme();
  const logout = useAuthStore(state => state.logout);

  const [logoutDialogVisible, setLogoutDialogVisible] =
    useState<boolean>(false);
  const [languageMenuVisible, setLanguageMenuVisible] =
    useState<boolean>(false);
  const [contactDialogVisible, setContactDialogVisible] =
    useState<boolean>(false);

  const confirmLogout = async () => {
    await logout();
    setLogoutDialogVisible(false);
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
        </LabeledSection>

        <LabeledSection title={t('other')}>
          <SettingsItem
            title={t('version')}
            icon='application-brackets-outline'
            right={() => <Text variant='bodyMedium'>1.0.0</Text>}
          />

          <Divider />

          <SettingsItem
            title={t('contact')}
            icon='account-circle-outline'
            right={() => <List.Icon icon='chevron-right' />}
            onPress={() => setContactDialogVisible(true)}
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
        onConfirm={confirmLogout}
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
        </View>
      </ConfirmDialog>
    </>
  );
}
