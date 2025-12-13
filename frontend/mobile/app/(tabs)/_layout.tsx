import { Redirect } from 'expo-router';
import { useState } from 'react';
import { BottomNavigation, useTheme } from 'react-native-paper';
import GroupsScreen from '@/app/(tabs)/index';
import SettingsScreen from '@/app/(tabs)/settings';
import StatisticsScreen from '@/app/(tabs)/statistics';
import StudentsScreen from '@/app/(tabs)/students';
import { useAuthStore } from '@/stores/authStore';

type RouteProps = { route: { key: string } };

const routes = [
  {
    key: 'groups',
    title: 'Groups',
    focusedIcon: 'folder-account',
    unfocusedIcon: 'folder-account-outline'
  },
  {
    key: 'students',
    title: 'Students',
    focusedIcon: 'account-group',
    unfocusedIcon: 'account-group-outline'
  },
  {
    key: 'statistics',
    title: 'Statistics',
    focusedIcon: 'archive',
    unfocusedIcon: 'archive-outline'
  },
  {
    key: 'settings',
    title: 'Settings',
    focusedIcon: 'cog',
    unfocusedIcon: 'cog-outline'
  }
];

export default function TabsLayout() {
  const theme = useTheme();
  const user = useAuthStore(state => state.user);
  const [index, setIndex] = useState(0);

  const renderScene = ({ route }: RouteProps) => {
    switch (route.key) {
      case 'groups':
        return <GroupsScreen />;
      case 'students':
        return <StudentsScreen />;
      case 'statistics':
        return <StatisticsScreen />;
      case 'settings':
        return <SettingsScreen />;
      default:
        return null;
    }
  };

  if (!user) {
    return <Redirect href='/(auth)' />;
  }

  return (
    <BottomNavigation
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
      barStyle={{ backgroundColor: theme.colors.surface }}
      shifting
    />
  );
}
