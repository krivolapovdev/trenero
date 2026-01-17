import { useQuery } from '@apollo/client/react';
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, StyleSheet } from 'react-native';
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
  defaultPrice?: number | null;
  note?: string | null;
  studentIds: string[];
};

type Props = {
  title: string;
  queryLoading: boolean;
  mutationLoading?: boolean;
  initialData?: Partial<GetGroupQuery['group']> | null;
  onSubmit: (values: GroupFormValues) => void;
  onBack: () => void;
};

export const GroupForm = ({
  title,
  queryLoading,
  mutationLoading = false,
  initialData,
  onSubmit,
  onBack
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const [name, setName] = useState('');
  const [defaultPrice, setDefaultPrice] = useState('');
  const [note, setNote] = useState('');
  const [selectedStudents, setSelectedStudents] = useState<ListItem[]>([]);

  const { data: studentsData, loading: studentsLoading } = useQuery(
    GET_STUDENTS,
    {
      fetchPolicy: 'cache-first'
    }
  );

  const isLoading =
    queryLoading || (mutationLoading ?? false) || studentsLoading;

  const studentItems: ListItem[] = useMemo(() => {
    const list = studentsData?.students ?? [];
    const currentStudentIds = new Set(initialData?.students?.map(s => s.id));

    return list
      .filter(s => !s.group || currentStudentIds.has(s.id))
      .map(s => ({ _id: s.id, value: s.fullName }));
  }, [studentsData, initialData?.students]);

  const handleSubmit = () => {
    const trimmedName = name.trim();

    if (!trimmedName || isLoading) {
      return;
    }

    const values: GroupFormValues = {
      name: trimmedName,
      defaultPrice: Number(defaultPrice) || null,
      studentIds: selectedStudents.map(s => s._id),
      note: note?.trim() || null
    };

    onSubmit(values);
  };

  useEffect(() => {
    if (initialData) {
      setName(initialData.name ?? '');
      setDefaultPrice(initialData.defaultPrice?.toString() ?? '');
      setNote(initialData.note ?? '');
      if (initialData.students) {
        setSelectedStudents(
          initialData.students.map(s => ({ _id: s.id, value: s.fullName }))
        );
      }
    }
  }, [initialData]);

  return (
    <>
      <CustomAppbar
        title={title}
        leftActions={[
          {
            icon: 'arrow-left',
            onPress: onBack,
            disabled: mutationLoading
          }
        ]}
        rightActions={[
          {
            icon: 'content-save',
            disabled: !name.trim() || isLoading,
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
        refreshControl={<RefreshControl refreshing={isLoading} />}
      >
        <CustomTextInput
          label={`${t('name')} *`}
          value={name}
          onChangeText={setName}
          maxLength={255}
          right={<TextInput.Affix text={`${name.length}/255`} />}
          disabled={isLoading}
        />

        <CustomTextInput
          label={t('defaultPrice')}
          placeholder='123.45'
          value={defaultPrice}
          onChangeText={text => setDefaultPrice(formatPriceInput(text))}
          keyboardType='decimal-pad'
          disabled={isLoading}
        />

        <CustomTextInput
          label={t('note')}
          value={note}
          onChangeText={setNote}
          maxLength={1023}
          multiline={true}
          right={<TextInput.Affix text={`${note.length}/1023`} />}
          disabled={isLoading}
        />

        <PaperSelect
          label={t('students')}
          textInputMode='outlined'
          value={
            selectedStudents.length > 0
              ? `${selectedStudents.length} selected`
              : ''
          }
          arrayList={studentItems}
          selectedArrayList={selectedStudents}
          textInputOutlineStyle={{ borderRadius: 10, borderWidth: 0 }}
          searchText={t('search')}
          selectAllText={t('selectAll')}
          dialogCloseButtonText={t('close')}
          dialogDoneButtonText={t('ok')}
          multiEnable={true}
          disabled={isLoading}
          onSelection={value => setSelectedStudents(value.selectedList)}
        />
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
