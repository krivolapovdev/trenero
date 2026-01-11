import { useQuery } from '@apollo/client/react';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { PaperSelect } from 'react-native-paper-select';
import type { ListItem } from 'react-native-paper-select/src/interface/paperSelect.interface';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import type { GetGroupQuery } from '@/src/graphql/__generated__/graphql';
import { GET_STUDENTS } from '@/src/graphql/queries';
import { formatPriceInput } from '@/src/helpers/formatPriceInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type GroupFormValues = {
  name: string;
  defaultPrice?: string | null;
  note?: string | null;
  studentIds: string[];
};

type Props = {
  title: string;
  initialData?: Partial<GetGroupQuery['group']> | null;
  onSubmit: (values: GroupFormValues) => void;
  onBack: () => void;
  loading: boolean;
};

export const GroupForm = ({
  title,
  initialData,
  onSubmit,
  onBack,
  loading
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const [name, setName] = useState(initialData?.name ?? '');
  const [defaultPrice, setDefaultPrice] = useState(
    initialData?.defaultPrice ?? ''
  );
  const [note, setNote] = useState(initialData?.note ?? '');

  const { data } = useQuery(GET_STUDENTS, {
    fetchPolicy: 'cache-first'
  });

  const studentItems: ListItem[] = useMemo(() => {
    const list = data?.students ?? [];
    const currentStudentIds = new Set(initialData?.students?.map(s => s.id));

    return list
      .filter(s => !s.group || currentStudentIds.has(s.id))
      .map(s => ({ _id: s.id, value: s.fullName }));
  }, [data, initialData?.students]);

  const [students, setStudents] = useState({
    list: studentItems,
    value: initialData?.students
      ? `${initialData.students.length} selected`
      : '',
    selectedList: studentItems.filter(s =>
      initialData?.students?.some(i => i.id === s._id)
    )
  });

  const handleSubmit = () => {
    const trimmedName = name.trim();

    if (!trimmedName || loading) {
      return;
    }

    const values: GroupFormValues = {
      name: trimmedName,
      defaultPrice: defaultPrice.trim() || null,
      studentIds: students.selectedList.map(s => s._id),
      note: note?.trim() || null
    };

    onSubmit(values);
  };

  return (
    <>
      <CustomAppbar
        title={title}
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: onBack,
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
        <CustomTextInput
          label={t('name')}
          value={name}
          onChangeText={setName}
          maxLength={255}
          right={<TextInput.Affix text={`${name.length}/255`} />}
          disabled={loading}
        />

        <CustomTextInput
          label={t('defaultPrice')}
          placeholder='123.45'
          value={defaultPrice}
          onChangeText={text => setDefaultPrice(formatPriceInput(text))}
          keyboardType='decimal-pad'
          disabled={loading}
        />

        <CustomTextInput
          label={t('note')}
          value={note}
          onChangeText={setNote}
          maxLength={1023}
          multiline={true}
          right={<TextInput.Affix text={`${note.length}/1023`} />}
          disabled={loading}
        />

        {studentItems.length > 0 && (
          <PaperSelect
            label={t('students')}
            textInputMode='outlined'
            value={students.value}
            arrayList={students.list}
            textInputOutlineStyle={{ borderRadius: 10, borderWidth: 0 }}
            selectedArrayList={students.selectedList}
            searchText={t('search')}
            selectAllText={t('selectAll')}
            dialogCloseButtonText={t('close')}
            dialogDoneButtonText={t('ok')}
            multiEnable={true}
            disabled={loading}
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
};

const styles = StyleSheet.create({
  container: {
    padding: 24,
    gap: 10,
    flex: 1
  }
});
