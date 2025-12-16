import { StyleSheet, View } from 'react-native';
import { Appbar, Badge, Text, useTheme } from 'react-native-paper';

type Props = {
  title: string;
  badgeCount: number;
};

export function AppbarWithBadge({ title, badgeCount }: Props) {
  const theme = useTheme();

  return (
    <Appbar.Header
      mode='center-aligned'
      elevated
    >
      <Appbar.Content
        title={
          <View>
            <Text variant='titleLarge'>{title}</Text>
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
          </View>
        }
      />
    </Appbar.Header>
  );
}

const styles = StyleSheet.create({
  badge: {
    position: 'absolute',
    top: -8,
    right: -22
  }
});
