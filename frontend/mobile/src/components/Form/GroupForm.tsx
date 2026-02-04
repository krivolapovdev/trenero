import { memo, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { RefreshControl, ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { formatPriceInput } from '@/src/helpers/formatPriceInput';
import { useAppTheme } from '@/src/hooks/useAppTheme';
import type { GroupDetails } from '@/src/types/group';

export type GroupFormValues = {
  name: string;
  defaultPrice?: number;
  note?: string;
};

type GroupFormInitialData = {
  group?: GroupDetails;
};

type Props = {
  title: string;
  queryLoading?: boolean;
  mutationLoading?: boolean;
  initialData?: GroupFormInitialData | null;
  onSubmit: (values: GroupFormValues) => void;
  onBack: () => void;
};

export const GroupForm = memo(
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

    const [name, setName] = useState('');
    const [defaultPrice, setDefaultPrice] = useState('');
    const [note, setNote] = useState('');

    const isLoading = queryLoading || mutationLoading;

    const handleSubmit = () => {
      const trimmedName = name.trim();

      if (!trimmedName || isLoading) {
        return;
      }

      const values: GroupFormValues = {
        name: trimmedName,
        defaultPrice: Number(defaultPrice) || undefined,
        note: note?.trim() || undefined
      };

      onSubmit(values);
    };

    useEffect(() => {
      if (initialData) {
        setName(initialData.group?.name ?? '');
        setDefaultPrice(initialData.group?.defaultPrice?.toString() ?? '');
        setNote(initialData.group?.note ?? '');
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
