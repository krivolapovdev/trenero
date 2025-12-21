import { Link } from 'expo-router';
import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import { Card, Text, TouchableRipple, useTheme } from 'react-native-paper';
import type { GroupResponse } from '@/services/group';

type Props = GroupResponse & {};

export const GroupItem = memo(({ id, name }: Readonly<Props>) => {
  const theme = useTheme();

  return (
    <Card
      mode='contained'
      style={{ backgroundColor: theme.colors.surface }}
    >
      <Link
        href={{
          pathname: '/(tabs)/groups/[id]',
          params: { id }
        }}
      >
        <TouchableRipple
          borderless
          style={styles.touchable}
        >
          <View style={styles.row}>
            <View style={styles.info}>
              <Text variant='titleMedium'>{name}</Text>
              <Text
                variant='bodySmall'
                style={{ color: theme.colors.outline }}
              >
                {id}
              </Text>
            </View>

            <View
              style={[
                styles.countBadge,
                { backgroundColor: theme.colors.secondaryContainer }
              ]}
            >
              <Text
                variant='labelMedium'
                style={{ color: theme.colors.onSecondaryContainer }}
              >
                {42} Students
              </Text>
            </View>
          </View>
        </TouchableRipple>
      </Link>
    </Card>
  );
});

const styles = StyleSheet.create({
  touchable: {
    borderRadius: 8,
    padding: 16,
    width: '100%'
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between'
  },
  info: {
    flex: 1
  },
  countBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16
  }
});
