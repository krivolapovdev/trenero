import { Pressable, View } from 'react-native';
import { Divider, Text } from 'react-native-paper';
import type { components } from '@/src/api/generated/openapi';
import { StatusBadges } from '@/src/components/StatusBadges';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import { useStudentBadges } from '@/src/hooks/useStudentBadges';

type Props = {
  student: components['schemas']['StudentOverviewResponse'];
  index: number;
  onPress: () => void;
};

export const StudentListItem = ({ student, index, onPress }: Props) => {
  const theme = useAppTheme();
  const badges = useStudentBadges(student.statuses);

  return (
    <Pressable
      onPress={onPress}
      style={{ padding: 16 }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
        <Text
          variant='bodyMedium'
          style={{ color: theme.colors.onSurfaceVariant }}
        >
          {index + 1}.
        </Text>
        <Text variant='bodyLarge'>{student.fullName}</Text>
      </View>

      <Divider style={{ marginVertical: 8 }} />

      <StatusBadges badges={badges} />
    </Pressable>
  );
};
