import { useState } from 'react';
import { Linking, ScrollView } from 'react-native';
import { Divider, List, Text } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { ConfirmDialog, LanguageDialog } from '@/src/components/dialogs';
import { SettingsItem } from '@/src/components/SettingsItem';
import { SettingsSection } from '@/src/components/SettingsSection';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useAuthStore } from '@/src/stores/authStore';

export default function SettingsScreen() {
  const theme = useAppTheme();
  const logout = useAuthStore(state => state.logout);

  const [logoutDialogVisible, setLogoutDialogVisible] =
    useState<boolean>(false);
  const [language, setLanguage] = useState<'en' | 'ru'>('en');
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
      <CustomAppbar title='Settings' />

      <SafeAreaView
        style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
      >
        <ScrollView contentContainerStyle={{ padding: 16, paddingTop: 0 }}>
          <SettingsSection title='APPEARANCE'>
            <SettingsItem
              title='Language'
              icon='flag-outline'
              right={() => <List.Icon icon='chevron-right' />}
              onPress={() => setLanguageMenuVisible(true)}
            />
          </SettingsSection>

          <SettingsSection title='ACCOUNT'>
            <SettingsItem
              title='Logout'
              icon='logout'
              right={() => <List.Icon icon='chevron-right' />}
              onPress={() => setLogoutDialogVisible(true)}
            />
          </SettingsSection>

          <SettingsSection title='OTHER'>
            <SettingsItem
              title='Version'
              icon='application-brackets-outline'
              right={() => <Text variant='bodyMedium'>1.0.0</Text>}
            />

            <Divider />

            <SettingsItem
              title='Contact'
              icon='account-circle-outline'
              right={() => <List.Icon icon='chevron-right' />}
              onPress={() => setContactDialogVisible(true)}
            />
          </SettingsSection>
        </ScrollView>

        <LanguageDialog
          visible={languageMenuVisible}
          language={language}
          setLanguage={setLanguage}
          onDismiss={() => setLanguageMenuVisible(false)}
        />

        <ConfirmDialog
          visible={logoutDialogVisible}
          title='Confirm Logout'
          onConfirm={confirmLogout}
          onCancel={() => setLogoutDialogVisible(false)}
          confirmText='Logout'
        >
          <Text variant='bodyMedium'>Are you sure you want to logout?</Text>
        </ConfirmDialog>

        <ConfirmDialog
          visible={contactDialogVisible}
          title='Contact'
          onConfirm={() => setContactDialogVisible(false)}
        >
          <Text
            variant='bodyMedium'
            style={{ textAlign: 'justify' }}
          >
            Do you have questions regarding our services or suggestions for
            future improvements? We are committed to providing the best
            experience possible and welcome your communication. Please use the
            following contact information to get in touch with our team:
            {'\n\n'}
            <Text
              style={{ fontWeight: '700' }}
              onPress={() => Linking.openURL('https://t.me/krivolapovdev')}
            >
              Telegram: @krivolapovdev
            </Text>
          </Text>
        </ConfirmDialog>
      </SafeAreaView>
    </>
  );
}
