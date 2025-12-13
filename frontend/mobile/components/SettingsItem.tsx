import type { ReactNode } from 'react';
import { List } from 'react-native-paper';

type SettingsItemProps = {
  title: string;
  icon: string;
  right?: () => ReactNode;
  onPress?: () => void;
};

export function SettingsItem({
  title,
  icon,
  right,
  onPress
}: Readonly<SettingsItemProps>) {
  return (
    <List.Item
      title={title}
      left={props => (
        <List.Icon
          {...props}
          icon={icon}
        />
      )}
      right={right}
      onPress={onPress}
    />
  );
}
