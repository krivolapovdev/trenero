import { useMutation, useQuery } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { Alert, ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { PaperSelect } from 'react-native-paper-select';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { graphql } from '@/src/graphql/__generated__';
import {
  type CreateStudentInput,
  StudentFieldsFragmentDoc
} from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS } from '@/src/graphql/queries';
import { formatDate } from '@/src/helpers/formatDate';
import { useAppTheme } from '@/src/hooks/useAppTheme';

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

export default function CreateStudentScreen() {
  const theme = useAppTheme();
  const router = useRouter();

  const [fullName, setFullName] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [note, setNote] = useState('');
  const [birthdate, setBirthdate] = useState('');
  const [groupId, setGroupId] = useState('');

  const { data } = useQuery(GET_GROUPS, {
    fetchPolicy: 'cache-first'
  });

  const groupItems = useMemo(
    () =>
      data?.groups?.map(group => ({
        _id: group.id,
        value: group.name
      })) ?? [],
    [data]
  );

  const [createStudent, { loading }] = useMutation(CREATE_STUDENT, {
    update(cache, { data }) {
      const newStudent = data?.createStudent;

      if (!newStudent) {
        return;
      }

      const newStudentRef = cache.writeFragment({
        data: newStudent,
        fragment: StudentFieldsFragmentDoc
      });

      cache.modify({
        fields: {
          students: (existingStudents = []) => [
            newStudentRef,
            ...existingStudents
          ]
        }
      });
    },

    onCompleted: data => {
      router.replace(`/(tabs)/students/${data.createStudent.id}`);
    },

    onError: err => {
      Alert.alert('Error', err.message);
    }
  });

  const handleSubmit = () => {
    if (!fullName.trim() || loading) {
      return;
    }

    const input: CreateStudentInput = {
      fullName: fullName.trim(),
      phone: phoneNumber?.trim() || null,
      note: note?.trim() || null,
      birthDate: parseDate(birthdate)?.toISOString().split('T')[0] || null,
      groupId: groupId || null
    };

    void createStudent({ variables: { input } });
  };

  return (
    <>
      <CustomAppbar
        title='Add Student'
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: () => router.back(),
            disabled: loading
          }
        ]}
        rightActions={[
          {
            icon: 'content-save',
            disabled: !fullName.trim() || loading,
            onPress: handleSubmit
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
        <CustomTextInput
          label='Full name *'
          value={fullName}
          onChangeText={setFullName}
          maxLength={255}
          right={<TextInput.Affix text={`${fullName.length}/255`} />}
        />

        <CustomTextInput
          label='Phone number'
          value={phoneNumber}
          placeholder='88005553535'
          onChangeText={text => setPhoneNumber(text.replaceAll(/\D/g, ''))}
          maxLength={15}
          keyboardType='numeric'
        />

        <CustomTextInput
          label='Note'
          value={note}
          onChangeText={setNote}
          maxLength={1023}
          multiline
          right={<TextInput.Affix text={`${note.length}/1023`} />}
        />

        <CustomTextInput
          label='Birthday'
          placeholder='31/12/1999'
          keyboardType='numeric'
          maxLength={10}
          value={birthdate}
          onChangeText={text => setBirthdate(formatDate(text))}
        />

        {groupItems.length > 0 && (
          <PaperSelect
            label={'Group'}
            textInputMode={'outlined'}
            value={groupItems.find(g => g._id === groupId)?.value ?? ''}
            arrayList={groupItems}
            textInputOutlineStyle={{ borderRadius: 10, borderWidth: 0 }}
            selectedArrayList={[
              {
                _id: groupId,
                value: groupItems.find(g => g._id === groupId)?.value ?? ''
              }
            ]}
            searchText={'Search'}
            multiEnable={false}
            onSelection={value => {
              if (value?.selectedList?.length > 0) {
                setGroupId(value.selectedList[0]._id);
              }
            }}
          />
        )}
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
