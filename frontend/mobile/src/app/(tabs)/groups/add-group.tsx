import { useMutation } from '@apollo/client/react';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { TextInput } from 'react-native-paper';
import { CustomAppbar } from '@/src/components/CustomAppbar';
import { CustomTextInput } from '@/src/components/CustomTextInput';
import { OptionalErrorMessage } from '@/src/components/OptionalErrorMessage';
import { graphql } from '@/src/graphql/__generated__';
import type { CreateGroupInput } from '@/src/graphql/__generated__/graphql';
import { GET_GROUPS } from '@/src/graphql/queries';
import { formatPrice } from '@/src/helpers/formatPrice';
import { useAppTheme } from '@/src/hooks/useAppTheme';

const CREATE_GROUP = graphql(`
    mutation CreateGroup($input: CreateGroupInput!) {
        createGroup(input: $input) {
            ...GroupFields
        }
    }
`);

export default function AddGroupScreen() {
  const router = useRouter();
  const theme = useAppTheme();

  const [name, setName] = useState('');
  const [defaultPrice, setDefaultPrice] = useState('');

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
    }
  });

  const handleSubmit = async () => {
    const trimmedName = name.trim();

    if (!trimmedName || loading) {
      return;
    }

    const input: CreateGroupInput = {
      name: trimmedName,
      defaultPrice: Number.isNaN(Number(defaultPrice?.trim()))
        ? null
        : Number(defaultPrice.trim()).toString()
    };

    const { data } = await createGroup({ variables: { input } });

    if (data?.createGroup) {
      router.replace(`/(tabs)/groups/${data.createGroup.id}`);
    }
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

        <CustomTextInput
          label='Name *'
          value={name}
          onChangeText={setName}
          maxLength={255}
          right={<TextInput.Affix text={`${name.length}/255`} />}
        />

        <CustomTextInput
          label='Default price'
          value={defaultPrice}
          onChangeText={text => setDefaultPrice(formatPrice(text))}
          keyboardType='decimal-pad'
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
