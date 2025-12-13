import { useState } from 'react';
import { Appearance, ScrollView, useColorScheme } from 'react-native';
import { List, Switch, Text, useTheme } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { ConfirmDialog } from '@/components/ConfirmDialog';
import { SettingsItem } from '@/components/SettingsItem';
import { SettingsSection } from '@/components/SettingsSection';
import { authService } from '@/services/authService';

export default function SettingsScreen() {
  const theme = useTheme();
  const [isDarkMode, setIsDarkMode] = useState(useColorScheme() === 'dark');
  const [logoutDialogVisible, setLogoutDialogVisible] = useState(false);

  const toggleTheme = () => {
    setIsDarkMode(prev => !prev);
    Appearance.setColorScheme(isDarkMode ? 'light' : 'dark');
  };

  const confirmLogout = () => {
    authService.logout();
    setLogoutDialogVisible(false);
  };

  return (
    <SafeAreaView
      style={{ flex: 1, backgroundColor: theme.colors.surfaceVariant }}
    >
      <ScrollView contentContainerStyle={{ padding: 16 }}>
        <SettingsSection title='APPEARANCE'>
          <SettingsItem
            title='Dark Mode'
            icon='moon-waning-crescent'
            right={() => (
              <Switch
                value={isDarkMode}
                onValueChange={toggleTheme}
              />
            )}
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
            icon='application-brackets'
            right={() => <Text variant='bodyMedium'>1.0.0</Text>}
          />
        </SettingsSection>
      </ScrollView>

      <ConfirmDialog
        visible={logoutDialogVisible}
        title='Confirm Logout'
        message='Are you sure you want to logout?'
        onConfirm={confirmLogout}
        onCancel={() => setLogoutDialogVisible(false)}
        confirmText='Logout'
      />
    </SafeAreaView>
  );
}
