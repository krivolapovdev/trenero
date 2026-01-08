import { useMutation, useQuery } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { PaperSelect } from 'react-native-paper-select';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateStudentInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS } from '@/src/graphql/queries';
import { formatDateInput } from '@/src/helpers/formatDateInput';
import { parsePastOrTodayDateFromInput } from '@/src/helpers/parsePastOrTodayDateFromInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const CREATE_STUDENT = graphql(`
    mutation CreateStudent($input: CreateStudentInput!) {
        createStudent(input: $input) {
            ...StudentFields
            group {
                id
                students {
                    id
                }
            }
        }
    }
`);

export default function CreateStudentScreen() {
  const theme = useAppTheme();
  const router = useRouter();
  const { t } = useTranslation();

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

      const newStudentRef = {
        __ref: cache.identify(newStudent)
      };

      cache.modify({
        fields: {
          students: (existingRefs = []) => [newStudentRef, ...existingRefs]
        }
      });
    },

    onCompleted: data =>
      router.replace(`/(tabs)/students/${data.createStudent.id}`),

    onError: err => Alert.alert(t('error'), err.message)
  });

  const handleSubmit = () => {
    if (!fullName.trim() || loading) {
      return;
    }

    const input: CreateStudentInput = {
      fullName: fullName.trim(),
      phone: phoneNumber?.trim() || null,
      note: note?.trim() || null,
      birthdate:
        parsePastOrTodayDateFromInput(birthdate)?.format('YYYY-MM-DD') || null,
      groupId: groupId || null
    };

    void createStudent({ variables: { input } });
  };

  return (
    <>
      <CustomAppbar
        title={t('addStudent')}
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
          label={t('fullName')}
          value={fullName}
          onChangeText={setFullName}
          maxLength={255}
          right={<TextInput.Affix text={`${fullName.length}/255`} />}
        />

        <CustomTextInput
          label={t('phoneNumber')}
          value={phoneNumber}
          placeholder='88005553535'
          onChangeText={text => setPhoneNumber(text.replaceAll(/\D/g, ''))}
          maxLength={15}
          keyboardType='numeric'
        />

        <CustomTextInput
          label={t('note')}
          value={note}
          onChangeText={setNote}
          maxLength={1023}
          multiline
          right={<TextInput.Affix text={`${note.length}/1023`} />}
        />

        <CustomTextInput
          label={t('birthday')}
          placeholder='31/12/1999'
          keyboardType='numeric'
          maxLength={10}
          value={birthdate}
          onChangeText={text => setBirthdate(formatDateInput(text))}
        />

        {groupItems.length > 0 && (
          <PaperSelect
            label={t('group')}
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
            searchText={t('search')}
            selectAllText={t('selectAll')}
            dialogCloseButtonText={t('close')}
            dialogDoneButtonText={t('ok')}
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
