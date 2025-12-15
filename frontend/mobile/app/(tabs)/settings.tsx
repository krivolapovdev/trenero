import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { useState } from 'react';
import { Appearance, ScrollView, useColorScheme } from 'react-native';
import {
  Appbar,
  Divider,
  List,
  Switch,
  Text,
  useTheme
} from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ConfirmDialog } from '@/components/ConfirmDialog';
import { LanguageDialog } from '@/components/LanguageDialog';
import { SettingsItem } from '@/components/SettingsItem';
import { SettingsSection } from '@/components/SettingsSection';
import { authService } from '@/services/authService';

export default function SettingsScreen() {
  const theme = useTheme();
  const [isDarkMode, setIsDarkMode] = useState(useColorScheme() === 'dark');
  const [logoutDialogVisible, setLogoutDialogVisible] =
    useState<boolean>(false);
  const [language, setLanguage] = useState<'en' | 'ru'>('en');
  const [languageMenuVisible, setLanguageMenuVisible] =
    useState<boolean>(false);

  const toggleTheme = () => {
    setIsDarkMode(prev => {
      Appearance.setColorScheme(prev ? 'light' : 'dark');
      return !prev;
    });
  };

  const confirmLogout = async () => {
    await GoogleSignin.signOut();
    await authService.logout();
    setLogoutDialogVisible(false);
  };

  return (
    <>
      <Appbar.Header
        mode='center-aligned'
        elevated
        style={{ backgroundColor: theme.colors.surface }}
      >
        <Appbar.Content title='Settings' />
      </Appbar.Header>

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
      </SafeAreaView>
    </>
  );
}
