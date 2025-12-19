import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { useState } from 'react';
import { Appearance, Linking, ScrollView, useColorScheme } from 'react-native';
import { Divider, List, Switch, Text, useTheme } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ConfirmDialog } from '@/components/ConfirmDialog';
import { CustomAppbar } from '@/components/CustomAppbar';
import { LanguageDialog } from '@/components/LanguageDialog';
import { SettingsItem } from '@/components/SettingsItem';
import { SettingsSection } from '@/components/SettingsSection';
import { useAuthStore } from '@/stores/authStore';

export default function SettingsScreen() {
  const theme = useTheme();
  const logout = useAuthStore(state => state.logout);

  const [isDarkMode, setIsDarkMode] = useState(useColorScheme() === 'dark');
  const [logoutDialogVisible, setLogoutDialogVisible] =
    useState<boolean>(false);
  const [language, setLanguage] = useState<'en' | 'ru'>('en');
  const [languageMenuVisible, setLanguageMenuVisible] =
    useState<boolean>(false);
  const [contactDialogVisible, setContactDialogVisible] =
    useState<boolean>(false);

  const toggleTheme = () => {
    setIsDarkMode(prev => {
      Appearance.setColorScheme(prev ? 'light' : 'dark');
      return !prev;
    });
  };

  const confirmLogout = async () => {
    await logout();
    await GoogleSignin.signOut();
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
              title='Dark Mode'
              icon='weather-sunset-down'
              right={() => (
                <Switch
                  value={isDarkMode}
                  onValueChange={toggleTheme}
                />
              )}
            />

            <Divider />

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
          message='Are you sure you want to logout?'
          onConfirm={confirmLogout}
          onCancel={() => setLogoutDialogVisible(false)}
          confirmText='Logout'
        />

        <ConfirmDialog
          visible={contactDialogVisible}
          title='Contact'
          message={
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
          }
          onConfirm={() => setContactDialogVisible(false)}
        />
      </SafeAreaView>
    </>
  );
}
