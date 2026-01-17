import { useQuery } from '@apollo/client/react';
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { PaperSelect } from 'react-native-paper-select';
import type { ListItem } from 'react-native-paper-select/src/interface/paperSelect.interface';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import type {
  GetGroupsQuery,
  GetStudentQuery
} from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS } from '@/src/graphql/queries';
import { formatDateInput } from '@/src/helpers/formatDateInput';
import { parsePastOrTodayDateFromInput } from '@/src/helpers/parsePastOrTodayDateFromInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';

export type StudentFormValues = {
  fullName: string;
  phone?: string | null;
  note?: string | null;
  birthdate?: string | null;
  groupId?: string | null;
};

type Props = {
  title: string;
  queryLoading: boolean;
  mutationLoading?: boolean;
  initialData?: GetStudentQuery['student'] | null;
  onSubmit: (values: StudentFormValues) => void;
  onBack: () => void;
};

export const StudentForm = ({
  title,
  queryLoading,
  mutationLoading = false,
  initialData,
  onSubmit,
  onBack
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [note, setNote] = useState('');
  const [birthdate, setBirthdate] = useState('');
  const [groupId, setGroupId] = useState<string | null>(null);

  const { data: groupsData, loading: groupsLoading } = useQuery<GetGroupsQuery>(
    GET_GROUPS,
    {
      fetchPolicy: 'cache-first'
    }
  );

  const handleSubmit = () => {
    const trimmedName = fullName.trim();

    if (!trimmedName || isLoading) {
      return;
    }

    const values: StudentFormValues = {
      fullName: trimmedName,
      phone: phone.trim() || null,
      note: note.trim() || null,
      birthdate:
        parsePastOrTodayDateFromInput(birthdate)?.format('YYYY-MM-DD') || null,
      groupId: groupId || null
    };

    onSubmit(values);
  };

  const isLoading = queryLoading || mutationLoading || groupsLoading;

  const groupItems: ListItem[] = useMemo(
    () =>
      groupsData?.groups?.map(group => ({
        _id: group.id,
        value: group.name
      })) ?? [],
    [groupsData]
  );

  const selectedGroupItems = useMemo(
    () => groupItems.filter(g => g._id === groupId),
    [groupItems, groupId]
  );

  useEffect(() => {
    if (initialData) {
      setFullName(initialData.fullName ?? '');
      setPhone(initialData.phone ?? '');
      setNote(initialData.note ?? '');
      setBirthdate(
        initialData.birthdate ? formatDateInput(initialData.birthdate) : ''
      );
      setGroupId(initialData.group?.id ?? null);
    }
  }, [initialData]);

  return (
    <>
      <CustomAppbar
        title={title}
        leftActions={[
          { icon: 'arrow-left', onPress: onBack, disabled: mutationLoading }
        ]}
        rightActions={[
          {
            icon: 'content-save',
            disabled: !fullName.trim() || isLoading,
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
          label={`${t('fullName')} *`}
          value={fullName}
          onChangeText={setFullName}
          maxLength={255}
          right={<TextInput.Affix text={`${fullName.length}/255`} />}
          disabled={isLoading}
        />

        <CustomTextInput
          label={t('phoneNumber')}
          value={phone}
          placeholder='88005553535'
          onChangeText={text => setPhone(text.replaceAll(/\D/g, ''))}
          maxLength={15}
          keyboardType='numeric'
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

        <CustomTextInput
          label={t('birthday')}
          value={birthdate}
          placeholder='31/12/1999'
          keyboardType='numeric'
          maxLength={10}
          onChangeText={text => setBirthdate(formatDateInput(text))}
          disabled={isLoading}
        />

        <PaperSelect
          label={t('group')}
          textInputMode='outlined'
          value={groupItems.find(g => g._id === groupId)?.value ?? ''}
          arrayList={groupItems}
          textInputOutlineStyle={{ borderRadius: 10, borderWidth: 0 }}
          selectedArrayList={selectedGroupItems}
          searchText={t('search')}
          selectAllText={t('selectAll')}
          dialogCloseButtonText={t('close')}
          dialogDoneButtonText={t('ok')}
          multiEnable={false}
          disabled={isLoading}
          onSelection={value => {
            if (value?.selectedList?.length > 0) {
              setGroupId(value.selectedList[0]._id);
            }
          }}
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
