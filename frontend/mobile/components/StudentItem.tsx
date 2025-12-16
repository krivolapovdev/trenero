import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import { Card, Chip, Divider, Text, TouchableRipple } from 'react-native-paper';
import { useAppTheme } from '@/hooks/useAppTheme';

type Student = {
  id: string;
  fullName: string;
  groups: string[];
  isAttending: boolean;
  isPaid: boolean;
};

type Props = {
  student: Student;
};

export const StudentItem = memo(({ student }: Readonly<Props>) => {
  const theme = useAppTheme();

  const { fullName, groups, isAttending, isPaid } = student;

  const handlePress = () => {
    console.log(student.id);
  };

  return (
    <Card
      mode='contained'
      style={{ backgroundColor: theme.colors.surface }}
      onPress={() => handlePress()}
    >
      <TouchableRipple
        onPress={() => console.log('Pressed:', student.id)}
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
    </Card>
  );
});

const styles = StyleSheet.create({
  touchable: {
    borderRadius: 8,
    padding: 16
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
