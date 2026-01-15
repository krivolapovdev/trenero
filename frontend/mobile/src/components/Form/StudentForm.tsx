import { useQuery } from '@apollo/client/react';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ScrollView, StyleSheet } from 'react-native';
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
  initialData?: GetStudentQuery['student'] | null;
  onSubmit: (values: StudentFormValues) => void;
  onBack: () => void;
  loading: boolean;
};

export const StudentForm = ({
  title,
  initialData,
  onSubmit,
  onBack,
  loading
}: Readonly<Props>) => {
  const { t } = useTranslation();
  const theme = useAppTheme();

  const [fullName, setFullName] = useState(initialData?.fullName ?? '');
  const [phoneNumber, setPhoneNumber] = useState(initialData?.phone ?? '');
  const [note, setNote] = useState(initialData?.note ?? '');
  const [birthdate, setBirthdate] = useState(
    initialData?.birthdate ? formatDateInput(initialData.birthdate) : ''
  );
  const [groupId, setGroupId] = useState(initialData?.group?.id ?? '');

  const { data } = useQuery<GetGroupsQuery>(GET_GROUPS, {
    fetchPolicy: 'cache-first'
  });

  const groupItems: ListItem[] = useMemo(
    () =>
      data?.groups?.map(group => ({
        _id: group.id,
        value: group.name
      })) ?? [],
    [data]
  );

  const handleSubmit = () => {
    if (!fullName.trim() || loading) {
      return;
    }

    const values: StudentFormValues = {
      fullName: fullName.trim(),
      phone: phoneNumber.trim() || null,
      note: note.trim() || null,
      birthdate:
        parsePastOrTodayDateFromInput(birthdate)?.format('YYYY-MM-DD') || null,
      groupId: groupId || null
    };

    onSubmit(values);
  };

  return (
    <>
      <CustomAppbar
        title={title}
        leftActions={[
          { icon: 'arrow-left', onPress: onBack, disabled: loading }
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
          label={`${t('fullName')} *`}
          value={fullName}
          onChangeText={setFullName}
          maxLength={255}
          right={<TextInput.Affix text={`${fullName.length}/255`} />}
          disabled={loading}
        />

        <CustomTextInput
          label={t('phoneNumber')}
          value={phoneNumber}
          placeholder='88005553535'
          onChangeText={text => setPhoneNumber(text.replaceAll(/\D/g, ''))}
          maxLength={15}
          keyboardType='numeric'
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

        <CustomTextInput
          label={t('birthday')}
          value={birthdate}
          placeholder='31/12/1999'
          keyboardType='numeric'
          maxLength={10}
          onChangeText={text => setBirthdate(formatDateInput(text))}
          disabled={loading}
        />

        {groupItems.length > 0 && (
          <PaperSelect
            label={t('group')}
            textInputMode='outlined'
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
            disabled={loading}
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
};

const styles = StyleSheet.create({
  container: {
    padding: 24,
    gap: 10,
    flex: 1
  }
});
