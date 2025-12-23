import { useLocalSearchParams } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { RefreshControl, ScrollView } from 'react-native';
import { Text } from 'react-native-paper';
import { CustomAppbar } from '@/components/CustomAppbar';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import { useAppTheme } from '@/hooks/useAppTheme';
import type { StudentResponse } from '@/services/student';
import { studentService } from '@/services/student/studentService';

export default function StudentByIdScreen() {
  const [student, setStudent] = useState<StudentResponse | null>(null);
  const [refreshing, setRefreshing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const { id } = useLocalSearchParams();
  const theme = useAppTheme();

  const fetchGroupById = useCallback(async () => {
    try {
      setRefreshing(true);
      setError(null);
      const data = await studentService.getStudentById(id as string);
      setStudent(data);
    } catch (err) {
      console.error(err);
      setError(`Failed to load student: ${id}`);
    } finally {
      setRefreshing(false);
    }
  }, [id]);

  const handleEditPress = () => {
    console.log('Edit pressed');
  };

  const handleDeletePress = () => {
    console.log('Delete pressed');
  };

  useEffect(() => {
    void fetchGroupById();
  }, [fetchGroupById]);

  return (
    <>
      <CustomAppbar
        title='Student'
        showBackButton={true}
        onEditPress={handleEditPress}
        onDeletePress={handleDeletePress}
      />

      <ScrollView
        contentContainerStyle={{ padding: 16 }}
        showsVerticalScrollIndicator={false}
        style={{
          flex: 1,
          backgroundColor: theme.colors.surfaceVariant
        }}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={fetchGroupById}
          />
        }
      >
        <OptionalErrorMessage error={error} />
        <Text>{id}</Text>
        <Text>{JSON.stringify(student, null, 2)}</Text>
      </ScrollView>
    </>
  );
}
