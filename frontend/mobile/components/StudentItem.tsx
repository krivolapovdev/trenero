import { Link } from 'expo-router';
import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import { Card, Chip, Divider, Text, TouchableRipple } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';
import type { StudentResponse } from '@/services/student';

type Props = StudentResponse & {
  groups: string[];
  isAttending: boolean;
  isPaid: boolean;
};

export const StudentItem = memo(
  ({ id, fullName, groups, isAttending, isPaid }: Readonly<Props>) => {
    const theme = useAppTheme();

    return (
      <Card
        mode='contained'
        style={{ backgroundColor: theme.colors.surface }}
      >
        <Link
          href={{
            pathname: '/(tabs)/students/[id]',
            params: { id }
          }}
        >
          <TouchableRipple
            borderless
            style={styles.touchable}
          >
            <Card.Content>
              <View style={styles.headerContainer}>
                <Text variant='titleMedium'>{fullName}</Text>
              </View>

              <Text variant='bodySmall'>{groups.join(' • ')}</Text>

              <Divider style={styles.divider} />

              <View style={styles.statusContainer}>
                <Chip
                  compact={true}
                  style={{
                    borderRadius: 16,
                    backgroundColor: isAttending
                      ? theme.colors.green
                      : theme.colors.tertiaryContainer
                  }}
                  textStyle={{
                    color: isAttending
                      ? theme.colors.onSecondaryContainer
                      : theme.colors.onTertiaryContainer
                  }}
                >
                  <Text>{isAttending ? 'Ходит' : 'Не ходит'}</Text>
                </Chip>

                {!isPaid && (
                  <Chip
                    compact={true}
                    style={{
                      borderRadius: 16,
                      backgroundColor: theme.colors.errorContainer
                    }}
                    textStyle={{
                      color: theme.colors.onErrorContainer
                    }}
                  >
                    <Text>Не оплатил</Text>
                  </Chip>
                )}
              </View>
            </Card.Content>
          </TouchableRipple>
        </Link>
      </Card>
    );
  }
);

const styles = StyleSheet.create({
  touchable: {
    borderRadius: 8,
    padding: 16,
    width: '100%'
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 4
  },
  divider: {
    marginVertical: 10,
    height: 1
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: 4
  }
});
