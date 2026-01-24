import { CommonActions } from '@react-navigation/native';
import { Redirect, Tabs } from 'expo-router';
import { useTranslation } from 'react-i18next';
import { BottomNavigation, Icon } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useAuthStore } from '@/src/stores/authStore';

export default function TabsLayout() {
  const user = useAuthStore(state => state.user);
  const theme = useAppTheme();
  const { t } = useTranslation();

  if (!user) {
    return <Redirect href='/auth' />;
  }

  const TabConfig = [
    {
      name: 'index',
      title: t('statistics'),
      icon: 'chart-box',
      iconOutline: 'chart-box-outline'
    },
    {
      name: 'groups',
      title: t('groups'),
      icon: 'folder-account',
      iconOutline: 'folder-account-outline'
    },
    {
      name: 'students',
      title: t('students'),
      icon: 'account-group',
      iconOutline: 'account-group-outline'
    },
    {
      name: 'settings',
      title: t('settings'),
      icon: 'cog',
      iconOutline: 'cog-outline'
    }
  ];

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        popToTopOnBlur: true,
        animation: 'fade',
        transitionSpec: {
          animation: 'timing',
          config: { duration: 200 }
        }
      }}
      tabBar={({ navigation, state, descriptors, insets }) => (
        <BottomNavigation.Bar
          navigationState={state}
          safeAreaInsets={insets}
          shifting={true}
          keyboardHidesNavigationBar={false}
          onTabPress={({ route, preventDefault }) => {
            const event = navigation.emit({
              type: 'tabPress',
              target: route.key,
              canPreventDefault: true
            });

            if (event.defaultPrevented) {
              preventDefault();
              return;
            }

            navigation.dispatch({
              ...CommonActions.navigate(route.name, route.params),
              target: state.key
            });
          }}
          renderIcon={({ route, focused, color }) => {
            const { options } = descriptors[route.key];
            if (options.tabBarIcon) {
              return options.tabBarIcon({ focused, color, size: 24 });
            }
            return null;
          }}
          getLabelText={({ route }) => descriptors[route.key].options.title}
          style={{
            backgroundColor: theme.colors.surface
          }}
        />
      )}
    >
      {TabConfig.map(({ name, title, icon, iconOutline }) => (
        <Tabs.Screen
          key={name}
          name={name}
          options={{
            title,
            popToTopOnBlur: true,
            tabBarIcon: ({ color, focused, size }) => (
              <Icon
                source={focused ? icon : iconOutline}
                size={size}
                color={color}
              />
            )
          }}
        />
      ))}
    </Tabs>
  );
}
