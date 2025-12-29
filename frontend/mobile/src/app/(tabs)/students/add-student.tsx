import { useMutation } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { Text, TextInput } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateStudentInput } from '@/src/graphql/__generated__/graphql';
import { GET_STUDENTS } from '@/src/graphql/queries';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const INPUT_THEME = { roundness: 10 };

const parseDate = (value: string): Date | null => {
  const [day, month, year] = value.split('/').map(Number);

  if (
    !day ||
    !month ||
    !year ||
    year < 1900 ||
    year > new Date().getFullYear() ||
    month > 12 ||
    day > 31
  ) {
    return null;
  }

  const date = new Date(year, month - 1, day);

  if (
    date.getFullYear() !== year ||
    date.getMonth() !== month - 1 ||
    date.getDate() !== day
  ) {
    return null;
  }

  return date;
};

const CREATE_STUDENT = graphql(`
    mutation CreateStudent($input: CreateStudentInput!) {
        createStudent(input: $input) {
            ...StudentFields
        }
    }
`);

export default function AddStudentScreen() {
  const theme = useAppTheme();
  const router = useRouter();

  const [fullName, setFullName] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [note, setNote] = useState('');
  const [birthdate, setBirthdate] = useState('');

  const [createStudent, { loading, error }] = useMutation(CREATE_STUDENT, {
    update(cache, { data }) {
      const newStudent = data?.createStudent;
      const existingData = cache.readQuery({ query: GET_STUDENTS });

      if (!newStudent || !existingData) {
        return;
      }

      cache.writeQuery({
        query: GET_STUDENTS,
        data: {
          students: [newStudent, ...existingData.students]
        }
      });
    }
  });

  const handleSubmit = async () => {
    const trimmedFullName = fullName.trim();
    if (!trimmedFullName || loading) {
      return;
    }

    const input: CreateStudentInput = {
      fullName: trimmedFullName,
      phone: phoneNumber?.trim() || null,
      note: note?.trim() || null,
      birthDate: parseDate(birthdate)?.toISOString().split('T')[0] || null
    };

    const { data } = await createStudent({ variables: { input } });

    if (data?.createStudent) {
      router.replace(`/(tabs)/students/${data.createStudent.id}`);
    }
  };

  const formatDateInput = (value: string) => {
    const digits = value.replaceAll(/\D/g, '').slice(0, 8);

    const day = digits.slice(0, 2);
    const month = digits.slice(2, 4);
    const year = digits.slice(4, 8);

    return [day, month, year].filter(Boolean).join('/');
  };

  return (
    <>
      <CustomAppbar
        title='Add Student'
        leftActions={[{ icon: 'arrow-left', onPress: () => router.back() }]}
        rightActions={[
          {
            icon: 'content-save',
            disabled: !fullName || loading,
            onPress: () => {
              void handleSubmit();
            }
          }
        ]}
      />

      <ScrollView
        contentContainerStyle={[
          styles.container,
          { backgroundColor: theme.colors.surfaceVariant }
        ]}
        keyboardShouldPersistTaps='handled'
      >
        <OptionalErrorMessage error={error?.message} />

        <TextInput
          mode='outlined'
          value={fullName}
          theme={INPUT_THEME}
          onChangeText={setFullName}
          maxLength={255}
          label={
            <Text>
              Full Name <Text style={{ color: 'red' }}>*</Text>
            </Text>
          }
          right={<TextInput.Affix text={`${fullName.length}/255`} />}
        />

        <TextInput
          mode='outlined'
          label='Phone number'
          value={phoneNumber}
          theme={INPUT_THEME}
          keyboardType='numeric'
          left={<TextInput.Affix text='+' />}
          maxLength={15}
          onChangeText={text => setPhoneNumber(text.replaceAll(/\D/g, ''))}
        />

        <TextInput
          mode='outlined'
          label='Note'
          value={note}
          theme={INPUT_THEME}
          onChangeText={setNote}
          maxLength={1023}
          multiline
          right={<TextInput.Affix text={`${note.length}/1023`} />}
        />

        <TextInput
          mode='outlined'
          label='Birthday'
          placeholder='31/12/2000'
          value={birthdate}
          theme={INPUT_THEME}
          keyboardType='numeric'
          maxLength={10}
          onChangeText={text => setBirthdate(formatDateInput(text))}
        />
      </ScrollView>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 24,
    gap: 10,
    flex: 1
  }
});
