import { useState } from 'react';
import { Appearance, ScrollView } from 'react-native';
import { List, Switch, Text, useTheme } from 'react-native-paper';
import { SafeAreaView } from 'react-native-safe-area-context';
import { SettingsItem } from '@/components/SettingsItem';
import { SettingsSection } from '@/components/SettingsSection';
import { authService } from '@/services/authService';

export default function SettingsScreen() {
  const theme = useTheme();
  const [isDarkMode, setIsDarkMode] = useState(
    Appearance.getColorScheme() === 'dark'
  );

  const toggleTheme = () => {
    setIsDarkMode(prev => !prev);
    Appearance.setColorScheme(isDarkMode ? 'light' : 'dark');
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
            onPress={() => authService.logout()}
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
    </SafeAreaView>
  );
}
