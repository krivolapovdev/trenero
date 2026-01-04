import { useMutation, useQuery } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { Alert, ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { PaperSelect } from 'react-native-paper-select';
import type { ListItem } from 'react-native-paper-select/src/interface/paperSelect.interface';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateGroupInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS, GET_STUDENTS } from '@/src/graphql/queries';
import { formatPrice } from '@/src/helpers/formatPrice';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const CREATE_GROUP = graphql(`
    mutation CreateGroup($input: CreateGroupInput!) {
        createGroup(input: $input) {
            ...GroupFields
        }
    }
`);

export default function CreateGroupScreen() {
  const router = useRouter();
  const theme = useAppTheme();

  const { data } = useQuery(GET_STUDENTS, {
    fetchPolicy: 'cache-first'
  });

  const studentItems = useMemo(
    () =>
      data?.students
        ?.filter(student => !student.group)
        .map(student => ({
          _id: student.id,
          value: student.fullName
        })) ?? [],
    [data]
  );

  const [name, setName] = useState('');
  const [defaultPrice, setDefaultPrice] = useState('');
  const [students, setStudents] = useState({
    value: '',
    list: studentItems,
    selectedList: [] as ListItem[]
  });

  const [createGroup, { loading, error }] = useMutation(CREATE_GROUP, {
    update(cache, { data }) {
      const newGroup = data?.createGroup;
      const existingData = cache.readQuery({
        query: GET_GROUPS
      });

      if (!newGroup || !existingData) {
        return;
      }

      cache.writeQuery({
        query: GET_GROUPS,
        data: {
          groups: [newGroup, ...existingData.groups]
        }
      });

      students.selectedList.forEach(student => {
        cache.modify({
          id: cache.identify({ __typename: 'Student', id: student._id }),
          fields: {
            group: () => newGroup
          }
        });
      });
    },

    onCompleted: data => {
      router.replace(`/(tabs)/groups/${data.createGroup.id}`);
    },

    onError: err => {
      Alert.alert('Error', err.message);
    }
  });

  const handleSubmit = () => {
    const trimmedName = name.trim();

    if (!trimmedName || loading) {
      return;
    }

    const input: CreateGroupInput = {
      name: trimmedName,
      defaultPrice: Number.isNaN(Number(defaultPrice?.trim()))
        ? null
        : Number(defaultPrice.trim()).toString(),
      studentIds:
        students.selectedList.length > 0
          ? students.selectedList.map(s => s._id)
          : null
    };

    void createGroup({ variables: { input } });
  };

  return (
    <>
      <CustomAppbar
        title='Add Group'
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
            disabled: !name.trim() || loading,
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
        <OptionalErrorMessage error={error?.message} />

        <CustomTextInput
          label='Name *'
          value={name}
          onChangeText={setName}
          maxLength={255}
          right={<TextInput.Affix text={`${name.length}/255`} />}
        />

        <CustomTextInput
          label='Default price'
          placeholder={'123.45'}
          value={defaultPrice}
          onChangeText={text => setDefaultPrice(formatPrice(text))}
          keyboardType='decimal-pad'
        />

        {studentItems.length > 0 && (
          <PaperSelect
            label={'Students'}
            textInputMode={'outlined'}
            value={students.value}
            arrayList={students.list}
            textInputOutlineStyle={{ borderRadius: 10, borderWidth: 0 }}
            selectedArrayList={students.selectedList}
            searchText={'Search'}
            multiEnable={true}
            onSelection={value =>
              setStudents({
                ...students,
                value: value.text,
                selectedList: value.selectedList
              })
            }
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
