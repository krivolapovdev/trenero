import { useRouter } from 'expo-router';
import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import { Appbar, Badge, Text } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';

type Props = {
  title: string;
  badgeCount?: number;
  showBackButton?: boolean;
  onAddPress?: () => void;
  onEditPress?: () => void;
  onDeletePress?: () => void;
};

export const CustomAppbar = memo(
  ({
    title,
    badgeCount,
    showBackButton,
    onAddPress,
    onEditPress,
    onDeletePress
  }: Readonly<Props>) => {
    const theme = useAppTheme();
    const router = useRouter();

    return (
      <Appbar.Header mode='center-aligned'>
        {showBackButton && <Appbar.BackAction onPress={() => router.back()} />}

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

        {onDeletePress && (
          <Appbar.Action
            icon='trash-can'
            onPress={onEditPress}
          />
        )}
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
