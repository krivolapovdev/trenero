import { Redirect } from 'expo-router';
import { useState } from 'react';
import { BottomNavigation } from 'react-native-paper';
import GroupsScreen from '@/app/(tabs)/groups';
import StudentsScreen from '@/app/(tabs)/index';
import SettingsScreen from '@/app/(tabs)/settings';
import StatisticsScreen from '@/app/(tabs)/statistics';
import { useAuthStore } from '@/stores/authStore';

const routes = [
  {
    key: 'students',
    title: 'Students',
    focusedIcon: 'account-group',
    unfocusedIcon: 'account-group-outline'
  },
  {
    key: 'groups',
    title: 'Groups',
    focusedIcon: 'folder-account',
    unfocusedIcon: 'folder-account-outline'
  },
  {
    key: 'statistics',
    title: 'Statistics',
    focusedIcon: 'chart-box',
    unfocusedIcon: 'chart-box-outline'
  },
  {
    key: 'settings',
    title: 'Settings',
    focusedIcon: 'cog',
    unfocusedIcon: 'cog-outline'
  }
];

export default function TabsLayout() {
  const user = useAuthStore(state => state.user);
  const [index, setIndex] = useState(0);

  const renderScene = BottomNavigation.SceneMap({
    students: StudentsScreen,
    groups: GroupsScreen,
    statistics: StatisticsScreen,
    settings: SettingsScreen
  });

  if (!user) {
    return <Redirect href='/(auth)' />;
  }

  return (
    <BottomNavigation
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
      keyboardHidesNavigationBar={false}
      sceneAnimationType='opacity'
      sceneAnimationEnabled
      shifting
    />
  );
}
