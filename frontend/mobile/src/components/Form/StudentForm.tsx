import { memo, useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { PaperSelect } from 'react-native-paper-select';
import type { ListItem } from 'react-native-paper-select/src/interface/paperSelect.interface';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { formatDateInput } from '@/src/helpers/formatDateInput';
import { parsePastOrTodayDateFromInput } from '@/src/helpers/parsePastOrTodayDateFromInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import type { GroupOverview } from '@/src/types/group';
import type { StudentDetails } from '@/src/types/student';

export type StudentFormValues = {
  fullName: string;
  phone?: string;
  note?: string;
  birthdate?: string;
  groupId?: string;
};

type StudentFormInitialData = {
  student?: StudentDetails;
  allGroups?: Record<string, GroupOverview>;
};

type Props = {
  title: string;
  queryLoading?: boolean;
  mutationLoading?: boolean;
  initialData?: StudentFormInitialData | null;
  onSubmit: (values: StudentFormValues) => void;
  onBack: () => void;
};

export const StudentForm = memo(
  ({
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

    const handleSubmit = () => {
      const trimmedName = fullName.trim();

      if (!trimmedName || isLoading) {
        return;
      }

      const values: StudentFormValues = {
        fullName: trimmedName,
        phone: phone.trim() || undefined,
        note: note.trim() || undefined,
        birthdate:
          parsePastOrTodayDateFromInput(birthdate)?.format('YYYY-MM-DD') ||
          undefined,
        groupId: groupId || undefined
      };

      onSubmit(values);
    };

    const isLoading = queryLoading || mutationLoading;

    const groupItems: ListItem[] = useMemo(() => {
      if (!initialData?.allGroups) {
        return [];
      }

      return Object.values(initialData.allGroups).map(group => ({
        _id: group.id,
        value: group.name
      }));
    }, [initialData?.allGroups]);

    const selectedGroupItems = useMemo(
      () => groupItems.filter(g => g._id === groupId),
      [groupItems, groupId]
    );

    useEffect(() => {
      if (initialData) {
        setFullName(initialData.student?.fullName ?? '');
        setPhone(initialData.student?.phone ?? '');
        setNote(initialData.student?.note ?? '');
        setBirthdate(
          initialData.student?.birthdate
            ? formatDateInput(initialData.student?.birthdate)
            : ''
        );
        setGroupId(initialData.student?.studentGroup?.id ?? null);
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
              const selectedId = value.selectedList?.[0]?._id ?? null;
              setGroupId(selectedId === groupId ? null : selectedId);
            }}
          />
        </ScrollView>
      </>
    );
  }
);

const styles = StyleSheet.create({
  container: {
    padding: 24,
    gap: 10,
    flex: 1
  }
});
