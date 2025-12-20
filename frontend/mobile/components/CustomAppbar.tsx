import { StyleSheet, View } from 'react-native';
import { Appbar, Badge, Text } from 'react-native-paper';
import { modeAppbarHeight } from 'react-native-paper/src/components/Appbar/utils';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAppTheme } from '@/hooks/useAppTheme';

const mode = 'center-aligned';

type Props = {
  title: string;
  badgeCount?: number;
  onAddPress?: () => void;
  onEditPress?: () => void;
};

export const CustomAppbar = ({
  title,
  badgeCount,
  onAddPress,
  onEditPress
}: Readonly<Props>) => {
  const theme = useAppTheme();
  const insets = useSafeAreaInsets();

  return (
    <Appbar
      safeAreaInsets={insets}
      mode={mode}
      style={{
        backgroundColor: theme.colors.elevation.level2,
        height: modeAppbarHeight[mode] + insets.top,
        zIndex: 100
      }}
    >
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
      {onAddPress && (
        <Appbar.Action
          icon='plus'
          onPress={onAddPress}
        />
      )}

      {onEditPress && (
        <Appbar.Action
          icon='pencil'
          onPress={onEditPress}
        />
      )}
    </Appbar>
  );
};

const styles = StyleSheet.create({
  badge: {
    position: 'absolute',
    top: -8,
    right: -22
  }
});
