import { gql } from '@apollo/client';
import { useMutation } from '@apollo/client/react';
import { memo, useState } from 'react';
import { Text, View } from 'react-native';
import { TextInput } from 'react-native-paper';
import { ConfirmDialog } from '@/components/dialogs/ConfirmDialog';
import { OptionalErrorMessage } from '@/components/OptionalErrorMessage';
import type { CreateGroupInput } from '@/graphql/inputs';
import { GET_GROUPS } from '@/graphql/quries';
import type { Group } from '@/graphql/types';

const INPUT_THEME = { roundness: 10 };

const MUTATION = gql`
    mutation ($input: CreateGroupInput!) {
        createGroup(input: $input) {
            id
            name
            defaultPrice
            students {
                id
            }
        }
    }
`;

type Props = {
  visible: boolean;
  onDismiss: () => void;
  onGroupAdded: () => void;
};

export const AddGroupDialog = memo(
  ({ visible, onDismiss, onGroupAdded }: Readonly<Props>) => {
    const [name, setName] = useState<string>('');
    const [defaultPrice, setDefaultPrice] = useState<string>('');

    const [createGroup, { loading, error }] = useMutation<
      { createGroup: Group },
      { input: CreateGroupInput }
    >(MUTATION, {
      update(cache, { data }) {
        const newGroup = data?.createGroup;

        const existingData = cache.readQuery<{ groups: Group[] }>({
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

    const handlePriceChange = (text: string) => {
      const cleaned = text.replaceAll(/[^0-9.]/g, '');
      const [integerPart, decimalPart] = cleaned.split('.');
      const formatted =
        decimalPart === undefined
          ? integerPart
          : `${integerPart}.${decimalPart.slice(0, 2)}`;
      setDefaultPrice(formatted);
    };

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

      if (!data?.createGroup) {
        return;
      }

      onGroupAdded();

      setName('');
      setDefaultPrice('');
    };

    return (
      <ConfirmDialog
        visible={visible}
        title='Add group'
        onConfirm={handleSubmit}
        onDismiss={loading ? undefined : onDismiss}
        disabledConfirm={!name.trim() || loading}
        loading={loading}
      >
        <View style={{ gap: 16 }}>
          <OptionalErrorMessage error={error?.message} />

          <TextInput
            mode='outlined'
            value={name}
            theme={INPUT_THEME}
            onChangeText={setName}
            maxLength={255}
            right={<TextInput.Affix text={`${name.length}/255`} />}
            label={
              <Text>
                Name <Text style={{ color: 'red' }}>*</Text>
              </Text>
            }
          />

          <TextInput
            mode='outlined'
            label='Default Price'
            value={defaultPrice}
            theme={INPUT_THEME}
            keyboardType='decimal-pad'
            onChangeText={handlePriceChange}
          />
        </View>
      </ConfirmDialog>
    );
  }
);
