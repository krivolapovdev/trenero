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
  onPress?: (student: Student) => void;
};

export function StudentItem({ student, onPress = () => {} }: Readonly<Props>) {
  const theme = useAppTheme();

  const { fullName, groups, isAttending, isPaid } = student;

  return (
    <Card
      mode='contained'
      style={{ backgroundColor: theme.colors.surface }}
      onPress={() => onPress(student)}
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
                  ? theme.colors.green40
                  : theme.colors.tertiaryContainer
              }}
              textStyle={{
                color: isAttending
                  ? theme.colors.onSecondaryContainer
                  : theme.colors.onTertiaryContainer
              }}
            >
              {isAttending ? 'Ходит' : 'Не ходит'}
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
                Не оплатил
              </Chip>
            )}
          </View>
        </Card.Content>
      </TouchableRipple>
    </Card>
  );
}

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
  scheduleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10
  },
  verticalLine: {
    width: 4,
    height: '100%',
    minHeight: 20,
    marginRight: 10,
    borderRadius: 2
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: 4
  }
});
