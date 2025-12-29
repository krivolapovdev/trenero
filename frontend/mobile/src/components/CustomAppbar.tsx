import { nanoid } from 'nanoid/non-secure';
import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import { Appbar, Badge, Text } from 'react-native-paper';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type AppbarAction = {
  icon: string;
  onPress: () => void;
  color?: string;
  disabled?: boolean;
};

type Props = {
  title: string;
  badgeCount?: number;
  leftActions?: AppbarAction[];
  rightActions?: AppbarAction[];
};

export const CustomAppbar = memo(
  ({
    title,
    badgeCount,
    leftActions = [],
    rightActions = []
  }: Readonly<Props>) => {
    const theme = useAppTheme();

    const renderActions = (actions: AppbarAction[]) =>
      actions.map(action => (
        <Appbar.Action
          key={nanoid()}
          icon={action.icon}
          onPress={action.onPress}
          color={action.color}
          disabled={action.disabled}
        />
      ));

    return (
      <Appbar.Header mode='center-aligned'>
        {renderActions(leftActions)}

        <Appbar.Content
          title={
            <View>
              <Text variant='titleLarge'>{title}</Text>
              {!!badgeCount && badgeCount > 0 && (
                <Badge
                  style={[
                    styles.badge,
                    {
                      backgroundColor: theme.colors.secondaryContainer,
                      color: theme.colors.onSecondaryContainer
                    }
                  ]}
                >
                  {badgeCount}
                </Badge>
              )}
            </View>
          }
        />

        {renderActions(rightActions)}
      </Appbar.Header>
    );
  }
);

const styles = StyleSheet.create({
  badge: {
    position: 'absolute',
    top: -8,
    right: -22
  }
});
